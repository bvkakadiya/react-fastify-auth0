import { test } from 'node:test'
import * as assert from 'node:assert'
import Fastify from 'fastify'
import supabasePlugin from '../../plugins/supabase.js'

process.env.SUPABASE_URL = 'https://example.supabase.co'
process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY = 'examplekey'
test('supabase works standalone', async (t) => {
  const fastify = Fastify()
  fastify.register(supabasePlugin)

  await fastify.ready()
  assert.ok(fastify.supabase)
})
