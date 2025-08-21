import { serve } from 'https://deno.land/std/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { user_id, limit = 20, offset = 0 } = await req.json()
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  if (!user_id) {
    return new Response(JSON.stringify({ error: 'Missing user_id' }), { status: 400 })
  }

  // 1. Get user tags
  const { data: userTags, error: tagError } = await supabase
    .from('user_tags')
    .select('tag_id')
    .eq('user_id', user_id)

  if (tagError) {
    return new Response(JSON.stringify({ error: tagError.message }), { status: 500 })
  }

  let postIdsQuery

  if (userTags.length > 0) {
    // 2. Fetch posts by tag match
    const tagIds = userTags.map(t => t.tag_id)

    const { data: postTags, error: postError } = await supabase
      .from('post_tags')
      .select('post_id')
      .in('tag_id', tagIds)

    if (postError) {
      return new Response(JSON.stringify({ error: postError.message }), { status: 500 })
    }

    // Shuffle and slice to simulate basic scoring
    const shuffled = postTags.sort(() => 0.5 - Math.random())
    postIdsQuery = shuffled.slice(offset, offset + limit).map(pt => ({ post_id: pt.post_id }))
  } else {
    // Fallback: get random recent posts
    const { data: fallbackPosts, error: fallbackError } = await supabase
      .from('feed_post')
      .select('id')
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1)
      .is('deleted_at', null)

    if (fallbackError) {
      return new Response(JSON.stringify({ error: fallbackError.message }), { status: 500 })
    }

    postIdsQuery = fallbackPosts.map(p => ({ post_id: p.id }))
  }

  return new Response(JSON.stringify(postIdsQuery), {
    headers: { 'Content-Type': 'application/json' },
    status: 200,
  })
})
