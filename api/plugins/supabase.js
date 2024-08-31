import fp from 'fastify-plugin'
import { createClient } from '@supabase/supabase-js'

async function supabasePlugin (fastify, options) {
  const supabase = createClient(process.env.SUPABASE_URL, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY)

  fastify.decorate('supabase', supabase)

  fastify.addHook('onClose', async (instance, done) => {
    // Perform any necessary cleanup here
    done()
  })
}

export default fp(supabasePlugin)
