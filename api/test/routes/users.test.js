import { test } from 'node:test'
import assert from 'node:assert'
import Fastify from 'fastify'
// import usersRoutes from '../../routes/users/index.js' // Adjust the path as needed
// import userIdRoutes from '../../routes/users/_id/index.js' // Adjust the path as needed

import path from 'path'
import AutoLoad from '@fastify/autoload'
import { fileURLToPath } from 'url'

const filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(filename)

// Mock Supabase client
const mockSupabase = {
  from: () => ({
    select: () => ({
      data: [{ id: 1, name: 'John Doe', email: 'email', created_at: new Date().toISOString() }],
      eq: () => ({
        single: async () => ({ data: { id: 1, name: 'John Doe', email: 'john.doe@example.com', created_at: new Date().toISOString() }, error: null })
      })
    }),
    insert: () => ({
      single: async () => ({ data: { id: 1, name: 'John Doe', email: 'john.doe@example.com', created_at: new Date().toISOString() }, error: null })
    }),
    update: () => ({
      eq: () => ({
        single: async () => ({ data: { id: 1, name: 'Jane Doe', email: 'jane.doe@example.com', created_at: new Date().toISOString() }, error: null })
      })
    }),
    delete: () => ({
      eq: () => ({
        single: async () => ({ data: null, error: null })
      })
    })
  })
}

// Helper function to build Fastify instance
const buildFastify = (t) => {
  const fastify = Fastify()
  fastify.decorate('supabase', mockSupabase)
  fastify.register(AutoLoad, {
    dir: path.join(__dirname, '..', '..', 'routes'),
    options: { prefix: '/api' },
    routeParams: true
  })
  t.after(() => fastify.close())
  // fastify.register(userIdRoutes, { prefix: '/api/users' })
  return fastify
}

test('GET /api/users', async (t) => {
  const fastify = buildFastify(t)
  const response = await fastify.inject({
    method: 'GET',
    url: '/api/users'
  })

  assert.strictEqual(response.statusCode, 200)
  const data = JSON.parse(response.payload)

  assert.strictEqual(data.length, 1)
  assert.strictEqual(data[0].name, 'John Doe')
})

test('POST /api/users', async (t) => {
  const fastify = buildFastify(t)
  const response = await fastify.inject({
    method: 'POST',
    url: '/api/users',
    payload: { name: 'John Doe', email: 'john.doe@example.com' }
  })
  assert.strictEqual(response.statusCode, 201)
  const data = JSON.parse(response.payload)
  assert.strictEqual(data.name, 'John Doe')
})

test('GET /api/users/:id', async (t) => {
  const fastify = buildFastify(t)
  const response = await fastify.inject({
    method: 'GET',
    url: '/api/users/1'
  })
  assert.strictEqual(response.statusCode, 200)
  const data = JSON.parse(response.payload)
  assert.strictEqual(data.name, 'John Doe')
})

test('PUT /api/users/:id', async (t) => {
  const fastify = buildFastify(t)
  const response = await fastify.inject({
    method: 'PUT',
    url: '/api/users/1',
    payload: { name: 'Jane Doe', email: 'jane.doe@example.com' }
  })
  assert.strictEqual(response.statusCode, 200)
  const data = JSON.parse(response.payload)
  assert.strictEqual(data.name, 'Jane Doe')
})

test('DELETE /api/users/:id', async (t) => {
  const fastify = buildFastify(t)
  const response = await fastify.inject({
    method: 'DELETE',
    url: '/api/users/1'
  })
  assert.strictEqual(response.statusCode, 204)
})
