import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  )

  const {
    data: { user },
    error: authError
  } = await supabase.auth.getUser()

  if (authError || !user) {
    return new Response("Unauthorized", { status: 401 })
  }

  const userId = user.id
  console.log(`Deleting user: ${userId}`)

  // Fetch media URLs related to this user’s products
  const { data: mediaItems, error: mediaError } = await supabase
    .from("media")
    .select("media_url")
    .in("id",
      (
        await supabase
          .from("product_media")
          .select("media_id")
          .in("product_id",
            (
              await supabase
                .from("products")
                .select("id")
                .eq("seller_id", userId)
            ).data?.map(p => p.id) || []
          )
      ).data?.map(m => m.media_id) || []
    )

  if (mediaError) {
    console.error("Failed to fetch media:", mediaError.message)
  }

  const filesToDelete: string[] = []

  if (mediaItems) {
    for (const item of mediaItems) {
      try {
        const url = new URL(item.media_url)
        const parts = url.pathname.split("/")
        const mediaIndex = parts.findIndex(p => p === "media")
        const path = parts.slice(mediaIndex + 1).join("/")
        filesToDelete.push(path)
      } catch {
        console.warn("Could not parse media_url:", item.media_url)
      }
    }
  }

  // Delete files from storage
  if (filesToDelete.length > 0) {
    const { error: storageError } = await supabase
      .storage
      .from("media")
      .remove(filesToDelete)

    if (storageError) {
      console.error("Failed to delete media from storage:", storageError.message)
    } else {
      console.log(`Deleted ${filesToDelete.length} media files`)
    }
  }

  // Call the DB-level cascade function to delete the user
  const { error: deleteError } = await supabase.rpc("fn_delete_user_cascade", {
    p_user_id: userId
  })

  if (deleteError) {
    console.error("Failed to delete user:", deleteError.message)
    return new Response(JSON.stringify({ error: deleteError.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" }
    })
  }

  return new Response(JSON.stringify({ success: true }), {
    status: 200,
    headers: { "Content-Type": "application/json" }
  })
})
