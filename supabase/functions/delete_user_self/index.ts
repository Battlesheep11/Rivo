import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  // Step 1: Load env vars
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY');
  const supabaseUrl = Deno.env.get('SUPABASE_URL');

  if (!serviceRoleKey || !anonKey || !supabaseUrl) {
    return new Response("Missing env vars", { status: 500 });
  }

  // Step 2: Extract JWT from Authorization header
  const authHeader = req.headers.get('Authorization');
  const jwt = authHeader?.replace('Bearer ', '');

  if (!jwt) {
    return new Response("Missing or invalid Authorization header", { status: 401 });
  }

  // Step 3: Create user-level client with JWT
  const userClient = createClient(supabaseUrl, anonKey, {
    global: {
      headers: {
        Authorization: `Bearer ${jwt}`,
      },
    },
  });

  const {
    data: { user },
    error: authError,
  } = await userClient.auth.getUser();

  if (authError || !user) {
    return new Response("Unauthorized", { status: 401 });
  }

  const userId = user.id;
  console.log(`Deleting user: ${userId}`);

  // Step 4: Get media paths
  const { data: mediaItems, error: mediaError } = await userClient
    .from("media")
    .select("media_url")
    .in(
      "id",
      (
        await userClient
          .from("product_media")
          .select("media_id")
          .in(
            "product_id",
            (
              await userClient
                .from("products")
                .select("id")
                .eq("seller_id", userId)
            ).data?.map((p) => p.id) || []
          )
      ).data?.map((m) => m.media_id) || []
    );

  if (mediaError) {
    console.error("Failed to fetch media:", mediaError.message);
  }

  const filesToDelete: string[] = [];

  if (mediaItems) {
    for (const item of mediaItems) {
      try {
        const url = new URL(item.media_url);
        const parts = url.pathname.split("/");
        const mediaIndex = parts.findIndex((p) => p === "media");
        const path = parts.slice(mediaIndex + 1).join("/");
        filesToDelete.push(path);
      } catch {
        console.warn("Could not parse media_url:", item.media_url);
      }
    }
  }

  if (filesToDelete.length > 0) {
    const { error: storageError } = await userClient.storage.from("media").remove(filesToDelete);

    if (storageError) {
      console.error("Failed to delete media from storage:", storageError.message);
    } else {
      console.log(`Deleted ${filesToDelete.length} media files`);
    }
  }

  // Step 5: Call RPC to delete app-level data
  const { error: cascadeError } = await userClient.rpc("fn_delete_user_cascade", {
    p_user_id: userId,
  });

  if (cascadeError) {
    console.error("Cascade delete failed:", cascadeError.message);
    return new Response(JSON.stringify({ error: cascadeError.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  // Step 6: Delete user from auth.users using admin client
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    global: {
      headers: {
        Authorization: `Bearer ${serviceRoleKey}`,
      },
    },
  });

  const { error: userDeleteError } = await adminClient.auth.admin.deleteUser(userId);

  if (userDeleteError) {
    console.error("Failed to delete user from auth.users:", userDeleteError.message);
    return new Response(JSON.stringify({ error: userDeleteError.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  return new Response(JSON.stringify({ success: true }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
});
