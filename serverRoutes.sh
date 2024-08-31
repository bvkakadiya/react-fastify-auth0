
# users routes
cd api
mkdir -p routes/users/_id
mkdir -p test/routes
cat <<EOL > routes/users/index.js
export default async function (fastify, opts) {
  fastify.get('/', {
    schema: {
      response: {
        200: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              id: { type: 'integer' },
              name: { type: 'string' },
              email: { type: 'string' },
              created_at: { type: 'string', format: 'date-time' }
            }
          }
        }
      }
    },
    handler: async function (request, reply) {
      const { data, error } = await fastify.supabase.from('user').select('*')

      if (error) {
        reply.internalServerError(error.message)
      } else {
        reply.send(data)
      }
    }
  })

  fastify.post('/', {
    schema: {
      body: {
        type: 'object',
        required: ['name', 'email'],
        properties: {
          name: { type: 'string' },
          email: { type: 'string' }
        }
      },
      response: {
        201: {
          type: 'object',
          properties: {
            id: { type: 'integer' },
            name: { type: 'string' },
            email: { type: 'string' },
            created_at: { type: 'string', format: 'date-time' }
          }
        }
      }
    },
    handler: async function (request, reply) {
      const { name, email } = request.body
      fastify.log.info({ name, email })
      const { data, error } = await fastify.supabase.from('user').insert([{ name, email }]).single()
      if (error) {
        reply.internalServerError(error.message)
      } else {
        reply.code(201).send(data)
      }
    }
  })
}

EOL
# User routes
cat <<EOL > routes/users/_id/index.js
export default async function (fastify, opts) {
  fastify.get('/', {
    schema: {
      params: {
        type: 'object',
        properties: {
          id: { type: 'integer' }
        },
        required: ['id']
      },
      response: {
        200: {
          type: 'object',
          properties: {
            id: { type: 'integer' },
            name: { type: 'string' },
            email: { type: 'string' },
            created_at: { type: 'string', format: 'date-time' }
          }
        }
      }
    },
    handler: async function (request, reply) {
      const { id } = request.params
      const { data, error } = await fastify.supabase.from('user').select('*').eq('id', id).single()
      if (error) {
        reply.internalServerError(error.message)
      } else {
        reply.send(data)
      }
    }
  })

  fastify.put('/', {
    schema: {
      params: {
        type: 'object',
        properties: {
          id: { type: 'integer' }
        },
        required: ['id']
      },
      body: {
        type: 'object',
        properties: {
          name: { type: 'string' },
          email: { type: 'string' }
        }
      },
      response: {
        200: {
          type: 'object',
          properties: {
            id: { type: 'integer' },
            name: { type: 'string' },
            email: { type: 'string' },
            created_at: { type: 'string', format: 'date-time' }
          }
        }
      }
    },
    handler: async function (request, reply) {
      const { id } = request.params
      const { name, email } = request.body
      const { data, error } = await fastify.supabase.from('user').update({ name, email }).eq('id', id).single()
      if (error) {
        reply.internalServerError(error.message)
      } else {
        reply.send(data)
      }
    }
  })

  fastify.delete('/', {
    schema: {
      params: {
        type: 'object',
        properties: {
          id: { type: 'integer' }
        },
        required: ['id']
      },
      response: {
        204: {
          type: 'null'
        }
      }
    },
    handler: async function (request, reply) {
      const { id } = request.params
      const { error } = await fastify.supabase.from('user').delete().eq('id', id)
      if (error) {
        reply.internalServerError(error.message)
      } else {
        reply.code(204).send()
      }
    }
  })
}
EOL
cat <<EOL > test/routes/users.test.js
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
EOL

npm run lint
echo "Done setting up routes"