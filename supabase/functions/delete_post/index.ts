import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type Body = {
  post_id: string;
  mode?: "soft" | "hard";        // default "soft"
  delete_product?: boolean;      // only used if mode = "hard"
};

const BUCKET = "media";

function cors(req: Request) {
  const origin = req.headers.get("origin") ?? "*";
  return {
    "Access-Control-Allow-Origin": origin,
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  };
}

function extractStoragePathFromUrl(url: string): string | null {
  // Works for public or signed URLs:
  // .../object/public/media/<path>
  // .../object/sign/<bucket>/<path>?token=...
  try {
    const u = new URL(url);
    const parts = u.pathname.split("/");
    // Find 'media' and join the rest
    const idx = parts.findIndex((p) => p === "media");
    if (idx >= 0 && idx + 1 < parts.length) {
      const pathWithMaybeToken = parts.slice(idx + 1).join("/");
      return pathWithMaybeToken; // token is in search, so path is clean
    }
    return null;
  } catch {
    return null;
  }
}

serve(async (req) => {
  const headers = cors(req);
  if (req.method === "OPTIONS") return new Response("ok", { headers });

  try {
    const url = Deno.env.get("SUPABASE_URL")!;
    const anon = Deno.env.get("SUPABASE_ANON_KEY")!;
    const service = Deno.env.get("SERVICE_ROLE_KEY")!;

    const body = (await req.json()) as Body;
    const mode = body.mode ?? "soft";
    const deleteProduct = !!body.delete_product;

    if (!body.post_id) {
      return new Response(JSON.stringify({ error: "invalid_body" }), { status: 400, headers });
    }

    // Caller identity
    const userClient = createClient(url, anon, { global: { headers: { Authorization: req.headers.get("Authorization")! } } });
    const { data: auth, error: authErr } = await userClient.auth.getUser();
    if (authErr || !auth?.user) return new Response(JSON.stringify({ error: "unauthorized" }), { status: 401, headers });
    const userId = auth.user.id;

    const admin = createClient(url, service);

    // Load post & ownership
    const { data: post, error: postErr } = await admin
      .from("feed_post")
      .select("id, creator_id, product_id, deleted_at")
      .eq("id", body.post_id)
      .single();

    if (postErr || !post) return new Response(JSON.stringify({ error: "post_not_found" }), { status: 404, headers });
    if (post.creator_id !== userId) return new Response(JSON.stringify({ error: "forbidden" }), { status: 403, headers });

    if (mode === "soft") {
      if (post.deleted_at) return new Response(JSON.stringify({ ok: true, already: "deleted" }), { status: 200, headers });
      const { error: updErr } = await admin
        .from("feed_post")
        .update({ deleted_at: new Date().toISOString() })
        .eq("id", post.id);
      if (updErr) return new Response(JSON.stringify({ error: "soft_delete_failed" }), { status: 500, headers });
      return new Response(JSON.stringify({ ok: true, mode: "soft" }), { status: 200, headers });
    }

    // HARD DELETE:
    // 1) Collect media attached to this product
    let storagePaths: string[] = [];
    if (post.product_id) {
      // media joined through product_media
      const { data: pm, error: pmErr } = await admin
        .from("product_media")
        .select("media(id, media_url)")
        .eq("product_id", post.product_id);

      if (pmErr) return new Response(JSON.stringify({ error: "load_product_media_failed" }), { status: 500, headers });

      const mediaIds: string[] = [];
      for (const row of (pm ?? [])) {
        const m = row.media;
        if (!m) continue;
        mediaIds.push(m.id);
        const path = extractStoragePathFromUrl(m.media_url);
        if (path) storagePaths.push(path);
      }

      // 2) Delete Storage files (best-effort)
      if (storagePaths.length) {
        const { error: rmErr } = await admin.storage.from(BUCKET).remove(storagePaths);
        if (rmErr) {
          // continue; we will still clean DB
          console.warn("storage_remove_failed", rmErr.message);
        }
      }

      // 3) Clean DB rows: product_media, media (only those collected), post_tags, feed_post, (optional product)
      if (mediaIds.length) {
        await admin.from("product_media").delete().eq("product_id", post.product_id);
        await admin.from("media").delete().in("id", mediaIds);
      }
    }

    // delete post_tags
    await admin.from("post_tags").delete().eq("post_id", post.id);
    // delete feed_post
    await admin.from("feed_post").delete().eq("id", post.id);

    if (deleteProduct && post.product_id) {
      // Ensure no other posts reference this product
      const { data: otherPosts } = await admin
        .from("feed_post")
        .select("id")
        .eq("product_id", post.product_id)
        .limit(1);
      if (!otherPosts || otherPosts.length === 0) {
        await admin.from("products").delete().eq("id", post.product_id);
      }
    }

    return new Response(JSON.stringify({ ok: true, mode: "hard" }), { status: 200, headers });
  } catch (e) {
    return new Response(JSON.stringify({ error: "unexpected", details: String(e) }), { status: 500, headers: { ...headers, "Content-Type": "application/json" } });
  }
});
