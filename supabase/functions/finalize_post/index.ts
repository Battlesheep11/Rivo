// supabase/functions/finalize_post/index.ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type Body = {
  session_id: string;
  product_id: string;
  caption?: string;
  tags?: string[];           // tag names
  expected_files: string[];  // filenames only, e.g. ["0.jpg","1.mp4"]
};

const BUCKET = "media";

serve(async (req) => {
  const origin = req.headers.get("origin") ?? "*";
  const corsHeaders = {
    "Access-Control-Allow-Origin": origin,
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  };
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    // replace these three lines at the top of each function
    const url = Deno.env.get("SUPABASE_URL")!;           // auto-injected (keep)
    const anon = Deno.env.get("SUPABASE_ANON_KEY")!;     // auto-injected (keep)
    const service = Deno.env.get("SERVICE_ROLE_KEY")!;   // <-- change to this (not SUPABASE_SERVICE_ROLE_KEY)

    const body = (await req.json()) as Body;
    const { session_id, product_id, caption, tags = [], expected_files } = body;
    if (!session_id || !product_id || !Array.isArray(expected_files))
      return new Response(JSON.stringify({ error: "invalid_body" }), { status: 400, headers: corsHeaders });

    // 1) Auth: get user from the caller's JWT
    const authClient = createClient(url, anon, { global: { headers: { Authorization: req.headers.get("Authorization")! } } });
    const { data: auth, error: authErr } = await authClient.auth.getUser();
    if (authErr || !auth?.user) return new Response(JSON.stringify({ error: "unauthorized" }), { status: 401, headers: corsHeaders });
    const userId = auth.user.id;

    // 2) Admin client for DB/Storage (we'll still validate ownership)
    const admin = createClient(url, service);

    // Verify product belongs to user
    const { data: prod, error: prodErr } = await admin
      .from("products")
      .select("id,seller_id")
      .eq("id", product_id)
      .single();
    if (prodErr || !prod || prod.seller_id !== userId)
      return new Response(JSON.stringify({ error: "forbidden_product" }), { status: 403, headers: corsHeaders });

    // 3) Check storage objects under prefix
    const prefix = `${userId}/${session_id}`;
    const { data: listed, error: listErr } = await admin.storage.from(BUCKET).list(prefix, { limit: 1000 });
    if (listErr) return new Response(JSON.stringify({ error: "storage_list_failed" }), { status: 500, headers: corsHeaders });

    const foundNames = new Set((listed ?? []).map((f) => f.name));
    const missing = expected_files.filter((f) => !foundNames.has(f));
    if (missing.length > 0) {
      return new Response(JSON.stringify({ status: "pending", missing }), { status: 202, headers: corsHeaders });
    }

    // 4) All files present → insert media + links in the order of expected_files
    // Build absolute storage paths by order
    const paths = expected_files.map((name, idx) => ({
      idx,
      name,
      path: `${prefix}/${name}`, // relative to bucket
    }));

    // Insert feed_post first (so we have post_id for tags)
    const { data: postRow, error: postErr } = await admin
      .from("feed_post")
      .insert({ creator_id: userId, product_id, caption: caption ?? null })
      .select("id")
      .single();
    if (postErr) return new Response(JSON.stringify({ error: "create_post_failed", details: postErr.message }), { status: 500, headers: corsHeaders });
    const postId = postRow.id as string;

    for (const p of paths) {
      const isVideo = p.name.toLowerCase().endsWith(".mp4");
      // Get public URL
      const { data: pub } = admin.storage.from(BUCKET).getPublicUrl(p.path);
      const mediaType = isVideo ? "video" : "image";

      // media
      const { data: mediaRow, error: mediaErr } = await admin
        .from("media")
        .insert({ media_url: pub.publicUrl, media_type: mediaType })
        .select("id")
        .single();
      if (mediaErr) {
        return new Response(JSON.stringify({ error: "insert_media_failed", details: mediaErr.message }), { status: 500, headers: corsHeaders });
      }
      const mediaId = mediaRow.id as string;

      // link to product_media preserving order
      const { error: linkErr } = await admin
        .from("product_media")
        .insert({ product_id, media_id: mediaId, sort_order: p.idx });
      if (linkErr) {
        return new Response(JSON.stringify({ error: "link_product_media_failed", details: linkErr.message }), { status: 500, headers: corsHeaders });
      }
    }

    // 5) Upsert tags and link to post
    for (const t of tags) {
      const tagName = `${t}`.trim();
      if (!tagName) continue;

      const { data: existing, error: tagSelErr } = await admin
        .from("tags")
        .select("id")
        .eq("name", tagName)
        .limit(1);
      if (tagSelErr) return new Response(JSON.stringify({ error: "tags_select_failed" }), { status: 500, headers: corsHeaders });

      let tagId: string | null = null;
      if (existing && existing.length > 0) {
        tagId = existing[0].id as string;
      } else {
        const { data: created, error: tagInsErr } = await admin
          .from("tags")
          .insert({ name: tagName, is_visible: true })
          .select("id")
          .single();
        if (tagInsErr) return new Response(JSON.stringify({ error: "tag_insert_failed" }), { status: 500, headers: corsHeaders });
        tagId = created.id as string;
      }
      const { error: ptErr } = await admin.from("post_tags").insert({ post_id: postId, tag_id: tagId });
      if (ptErr) return new Response(JSON.stringify({ error: "post_tags_insert_failed" }), { status: 500, headers: corsHeaders });
    }

    // (Optional) TODO: push notification here that post is live

    return new Response(JSON.stringify({ post_id: postId }), { status: 200, headers: corsHeaders });
  } catch (e) {
    return new Response(JSON.stringify({ error: "unexpected", details: `${e}` }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
