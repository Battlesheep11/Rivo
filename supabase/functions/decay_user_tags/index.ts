import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// הסוד שאת מגדירה - את יכולה לשנות אותו
const SECRET_KEY = 'kldfgFDGfgssdfDF543gffhDFFDGfdgderferfFfse54erttwe45ERGFsetw4etwrgsd'

serve(async (req) => {
  const url = new URL(req.url)
  const key = url.searchParams.get('key')

  if (key !== SECRET_KEY) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 })
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  const { error } = await supabase.rpc('decay_user_tags_internal')

  if (error) {
    return new Response(JSON.stringify({ success: false, error }), { status: 500 })
  }

  return new Response(JSON.stringify({ success: true }), { status: 200 })
})
