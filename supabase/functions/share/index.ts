import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const APP_SCHEME = "rivo"; // your custom scheme (client-side work later)
const PLAY_STORE_URL = "https://play.google.com/store/apps/details?id=com.rivo.app";  // TODO when live
const APP_STORE_URL  = "https://apps.apple.com/app/id0000000000";                      // TODO when live

function cors(req: Request) {
  const origin = req.headers.get("origin") ?? "*";
  return {
    "Access-Control-Allow-Origin": origin,
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "GET, OPTIONS",
  };
}

function htmlPage({ title, description, image, deepLink, webFallback }: {
  title: string;
  description: string;
  image?: string | null;
  deepLink: string;
  webFallback: string;
}) {
  const imgTag = image ? `<meta property="og:image" content="${image}"/>` : "";
  return `<!doctype html>
<html lang="en"><head>
<meta charset="utf-8"/>
<title>${title}</title>
<meta name="viewport" content="width=device-width, initial-scale=1" />
<meta property="og:title" content="${title}" />
<meta property="og:description" content="${description}" />
${imgTag}
<meta property="og:type" content="website" />
<meta name="twitter:card" content="summary_large_image" />
</head>
<body>
<p>Opening RIVO…</p>
<script>
  (function(){
    var deep = "${deepLink}";
    var fallback = "${webFallback}";
    var start = Date.now();
    window.location = deep;
    setTimeout(function(){
      if (Date.now() - start < 1500) {
        window.location = fallback;
      }
    }, 1200);
  })();
</script>
</body></html>`;
}

serve(async (req) => {
  const headers = cors(req);
  if (req.method === "OPTIONS") return new Response("ok", { headers });

  try {
    const url = Deno.env.get("SUPABASE_URL")!;
    const service = Deno.env.get("SERVICE_ROLE_KEY")!;
    const admin = createClient(url, service);

    // Shared fallback decision by UA
    const ua = req.headers.get("user-agent") ?? "";
    const webFallback = /android/i.test(ua) ? PLAY_STORE_URL : APP_STORE_URL;

    // Parse query: ?type=product&id=... OR ?type=user&id=... OR ?type=user&username=...
    const u = new URL(req.url);
    const type = u.searchParams.get("type");
    const id = u.searchParams.get("id");
    const username = u.searchParams.get("username");

    // PRODUCT SHARE
    if (type === "product" && id) {
      const { data: product, error: prodErr } = await admin
        .from("products")
        .select("id, title, description")
        .eq("id", id)
        .single();
      if (prodErr || !product) {
        return new Response("Not found", { status: 404, headers });
      }

      const { data: mediaList } = await admin
        .from("product_media")
        .select("sort_order, media(media_url)")
        .eq("product_id", id)
        .order("sort_order", { ascending: true })
        .limit(1);

      const firstImg = mediaList?.[0]?.media?.media_url ?? null;

      const title = product.title ?? "RIVO Product";
      const desc = product.description ?? "See this item on RIVO";
      const deepLink = `${APP_SCHEME}://product/${product.id}`;

      const page = htmlPage({ title, description: desc, image: firstImg, deepLink, webFallback });
      return new Response(page, { status: 200, headers: { ...headers, "Content-Type": "text/html; charset=utf-8" } });
    }

    // USER SHARE
    if (type === "user" && (id || username)) {
      let profile: any = null;
      if (id) {
        const { data, error } = await admin
          .from("profiles")
          .select("id, username, first_name, last_name, avatar_url")
          .eq("id", id)
          .single();
        if (!error) profile = data;
      } else if (username) {
        const { data, error } = await admin
          .from("profiles")
          .select("id, username, first_name, last_name, avatar_url")
          .eq("username", username)
          .single();
        if (!error) profile = data;
      }
      if (!profile) {
        return new Response("Not found", { status: 404, headers });
      }

      const display = (profile.first_name && profile.last_name)
        ? `${profile.first_name} ${profile.last_name}`
        : (profile.username ?? "RIVO User");

      const title = `${display} on RIVO`;
      const desc = `Explore ${display}'s items and style on RIVO`;
      const img = profile.avatar_url ?? null;
      const deepLink = `${APP_SCHEME}://user/${profile.id}`;

      const page = htmlPage({ title, description: desc, image: img, deepLink, webFallback });
      return new Response(page, { status: 200, headers: { ...headers, "Content-Type": "text/html; charset=utf-8" } });
    }

    return new Response("Bad request", { status: 400, headers });
  } catch (e) {
    return new Response(String(e), { status: 500, headers });
  }
});
