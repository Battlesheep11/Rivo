// supabase/functions/apply_tags/index.ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("URL")!;
const SERVICE_KEY  = Deno.env.get("SERVICE_ROLE_KEY")!;
const SHARED       = Deno.env.get("MAKE_SHARED_SECRET")!;



type Body = { productId?: string; postId?: string; tags: string[] };

serve(async (req) => {
  if (req.method !== "POST") return new Response("Method Not Allowed", { status: 405 });

  // Simple bearer auth so we never expose the service key to external tools
  const auth = req.headers.get("authorization") ?? "";
  if (auth !== `Bearer ${SHARED}`) return new Response("Unauthorized", { status: 401 });

  try {
    const { productId, postId, tags } = (await req.json()) as Body;

    if ((!productId && !postId) || !Array.isArray(tags) || tags.length === 0) {
      return new Response(JSON.stringify({ error: "invalid_input" }), {
        status: 400, headers: { "content-type": "application/json" }
      });
    }

    const supabase = createClient(SUPABASE_URL, SERVICE_KEY);
    const unique = Array.from(new Set(tags.map(t => t?.toString().trim().toLowerCase()).filter(Boolean)));
    if (unique.length === 0) {
      return new Response(JSON.stringify({ tags: [] }), { status: 200, headers: { "content-type": "application/json" } });
    }

    // 1) Upsert tag names (ensure they are visible)
    const { data: tagRows, error: tagErr } = await supabase
      .from("tags")
      .upsert(unique.map(name => ({ name, is_visible: true })), { onConflict: "name" })
      .select();
    if (tagErr) throw tagErr;

    const tagIds = (tagRows ?? []).map(r => r.id);

    // 2) Link to product or post (idempotent by composite PK)
    if (productId && tagIds.length) {
      const { error } = await supabase
        .from("product_tags")
        .upsert(tagIds.map(tag_id => ({ product_id: productId, tag_id })), { onConflict: "product_id,tag_id" });
      if (error) throw error;
    }

    if (postId && tagIds.length) {
      const { error } = await supabase
        .from("post_tags")
        .upsert(tagIds.map(tag_id => ({ post_id: postId, tag_id })), { onConflict: "post_id,tag_id" });
      if (error) throw error;
    }

    return new Response(JSON.stringify({ tags: unique }), {
      status: 200, headers: { "content-type": "application/json" }
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: "server_error", details: String(e) }), {
      status: 500, headers: { "content-type": "application/json" }
    });
  }
});
