// supabase/functions/discard_session/index.ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type Body = { session_id: string; product_id?: string };

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
    const { session_id, product_id } = body;
    if (!session_id) return new Response(JSON.stringify({ error: "invalid_body" }), { status: 400, headers: corsHeaders });

    const authClient = createClient(url, anon, { global: { headers: { Authorization: req.headers.get("Authorization")! } } });
    const { data: auth, error: authErr } = await authClient.auth.getUser();
    if (authErr || !auth?.user) return new Response(JSON.stringify({ error: "unauthorized" }), { status: 401, headers: corsHeaders });
    const userId = auth.user.id;

    const admin = createClient(url, service);

    // 1) Delete storage files under prefix
    const prefix = `${userId}/${session_id}`;
    const { data: listed, error: listErr } = await admin.storage.from(BUCKET).list(prefix, { limit: 1000 });
    if (listErr) return new Response(JSON.stringify({ error: "storage_list_failed" }), { status: 500, headers: corsHeaders });

    if (listed && listed.length > 0) {
      const fullPaths = listed.map((f) => `${prefix}/${f.name}`);
      const { error: rmErr } = await admin.storage.from(BUCKET).remove(fullPaths);
      if (rmErr) return new Response(JSON.stringify({ error: "storage_remove_failed" }), { status: 500, headers: corsHeaders });
    }

    // 2) Optionally delete the draft product if still owned and unused
    if (product_id) {
      // ensure ownership
      const { data: prod, error: prodErr } = await admin
        .from("products")
        .select("id,seller_id")
        .eq("id", product_id)
        .single();
      if (!prodErr && prod && prod.seller_id === userId) {
        // is it linked to a post?
        const { data: posts, error: postErr } = await admin
          .from("feed_post")
          .select("id")
          .eq("product_id", product_id)
          .limit(1);
        if (!postErr && (!posts || posts.length === 0)) {
          await admin.from("products").delete().eq("id", product_id);
        }
      }
    }

    return new Response(JSON.stringify({ ok: true }), { status: 200, headers: corsHeaders });
  } catch (e) {
    return new Response(JSON.stringify({ error: "unexpected", details: `${e}` }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
