import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const body = await req.json()
    const user_id = body.user_id
    const limit = body.limit ?? 20
    const offset = body.offset ?? 0

    if (!user_id) {
      return new Response(JSON.stringify({ error: 'Missing user_id' }), { status: 400 })
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const { data, error } = await supabase.rpc('fn_beta_feed_for_user', {
      user_id,
      limit_count: limit,
      offset_count: offset
    })

    if (error) {
      console.error('RPC error:', error)
      return new Response(JSON.stringify({ error: error.message }), { status: 500 })
    }

    return new Response(JSON.stringify(data), {
      headers: { 'Content-Type': 'application/json' },
      status: 200
    })
  } catch (e) {
    console.error('Unexpected error:', e)
    return new Response(JSON.stringify({ error: 'Unexpected error' }), { status: 500 })
  }
})
