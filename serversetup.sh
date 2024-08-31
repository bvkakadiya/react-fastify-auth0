#!/bin/bash

# Install necessary dependencies
npx fastify-cli generate api --esm --standardlint
cd api
npm install fastify-auth0-verify dotenv @supabase/supabase-js
npm i -D @fastify/swagger @fastify/swagger-ui nodemon
rm app.js

cat <<EOL > package.json
{
  "type": "module",
  "name": "api",
  "version": "1.0.0",
  "description": "This project was bootstrapped with Fastify-CLI.",
  "main": "app.js",
  "directories": {
    "test": "test"
  },
  "scripts": {
    "test": "node --test test/**/*.test.js",
    "start": "node index.js",
    "dev": "nodemon index.js",
    "pretest": "standard",
    "lint": "standard --fix"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "@fastify/autoload": "^5.0.0",
    "@fastify/sensible": "^5.0.0",
    "@supabase/supabase-js": "^2.45.3",
    "close-with-grace": "^2.1.0",
    "dotenv": "^16.4.5",
    "fastify": "^4.26.1",
    "fastify-auth0-verify": "^2.1.1",
    "fastify-plugin": "^4.0.0",
    "nodemon": "^3.1.4"
  },
  "devDependencies": {
    "@fastify/swagger": "^8.15.0",
    "@fastify/swagger-ui": "^4.1.0",
    "c8": "^10.1.2",
    "standard": "^17.0.0"
  }
}
EOL

npm install 


# Create .env file with Auth0 credentials
cat <<EOL > .env.example
VITE_AUTH0_DOMAIN= '<YOUR_AUTH0_DOMAIN>'
VITE_AUTH0_CLIENT_ID='<YOUR_AUTH0_CLIENT_ID>'
VITE_AUTH0_SECRET='<YOUR_AUTH0_SECRET>'
AUTH0_AUDIENCE='api'
SUPABASE_URL='https://<YOUR_SUPABASE_URL>.supabase.co'
NEXT_PUBLIC_SUPABASE_ANON_KEY='<YOUR_SUPAB>'
EOL

# Create index.js file with Fastify server setup
cat <<EOL > index.js
import Fastify from 'fastify'
import path from 'path'
import AutoLoad from '@fastify/autoload'
import fastifySwagger from '@fastify/swagger'
import fastifySwaggerUI from '@fastify/swagger-ui'
import { fileURLToPath } from 'url'
import closeWithGrace from 'close-with-grace'
import fastifyAuth0Verify from 'fastify-auth0-verify'
import dotenv from 'dotenv'
dotenv.config()

const filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(filename)

export const init = () => {

  const app = Fastify({
    logger: true
  })

  app.register(fastifySwagger, {
    mode: 'dynamic',
    swagger: {
      info: {
        title: 'Demo API',
        description: 'API documentation for Demo endpoints',
        version: '1.0.0'
      },
      schemes: ['http'],
      consumes: ['application/json'],
      produces: ['application/json']
    }
  })

  app.register(fastifySwaggerUI, {
    uiConfig: {
      docExpansion: 'full',
      deepLinking: true,
    },
    uiHooks: {
      onRequest: function (request, reply, next) {
        next()
      },
      preHandler: function (request, reply, next) {
        next()
      },
    },
    staticCSP: true,
    transformStaticCSP: (header) => header,
  })

  app.register(AutoLoad, {
    dir: path.join(__dirname, 'routes'),
    options: { prefix: '/api' },
    routeParams: true
  })

  app.register(AutoLoad, {
    dir: path.join(__dirname, 'plugins'),
    options: {}
  })

  app.register(fastifyAuth0Verify, {
    domain: process.env.VITE_AUTH0_DOMAIN,
    secret: process.env.VITE_AUTH0_SECRET
  })
  // app.addHook('preValidation', async (request, reply) => {
  //   app.log.info('preValidation hook authenticate')
  //   await app.authenticate(request, reply)

  // })
  // console.log(app.authenticate, 'app.authenticate');

  // delay is the number of milliseconds for the graceful close to finish
  closeWithGrace(
    { delay: process.env.FASTIFY_CLOSE_GRACE_DELAY || 500 },
    async function ({ signal, err, manual }) {
      if (err) {
        app.log.error(err)
      }
      await app.close()
    }
  )
  return app
}
if (import.meta.url === 'file://' + process.argv[1]) {
  const app = init()
  // called directly i.e. "node app"
  app.listen({ port: 3000 }, (err) => {
    if (err) console.error(err)
    console.log('server listening on 3000')
  })
  await app.ready()
  app.swagger()
}
export default async function handler (req, reply) {
  const app = init()
  await app.ready()
  app.swagger()
  app.server.emit('request', req, reply)
}
EOL

cat <<EOL > routes/example/index.js
export default async function (fastify, opts) {
  fastify.get('/', {
    preValidation: async (req, reply) => await fastify.authenticate(req, reply),
    handler: async function (request, reply) {
      return 'this is an example wow'
    }
  })
}
EOL

cat <<EOL > test/routes/example.test.js
import { test } from 'node:test'
import * as assert from 'node:assert'
import { build } from '../helper.js'
import exampleRoute from '../../routes/example/index.js'
const opts = {
  decorate: {
    authenticate: async (req, reply) => {
    }
  },
  plugin: {}
}
test('example is loaded and protected', async (t) => {
  const app = await build(t, exampleRoute, opts)
  const res = await app.inject({
    method: 'GET',
    url: '/'
  })
  assert.equal(res.statusCode, 200, 'returns a status code of 200')
  assert.equal(res.payload, 'this is an example wow', 'returns the expected payload')
})
EOL

cat <<EOL > test/routes/root.test.js
import { test } from 'node:test'
import * as assert from 'node:assert'
import { build } from '../helper.js'
import rootRoute from '../../routes/root.js'

test('default root route', async (t) => {
  const app = await build(t, rootRoute)
  const res = await app.inject({
    url: '/'
  })
  assert.deepStrictEqual(JSON.parse(res.payload), { root: true })
})
EOL

cat <<EOL > test/helper.js
import Fastify from 'fastify'

// automatically build and tear down our instance
async function build (
  t,
  route,
  opts = { decorate: { }, plugin: {} }
) {
  const app = Fastify()
  app.register(route)
  Object.keys(opts.decorate).forEach((key) => {
    app.decorate(key, opts.decorate[key])
  })
  await app.ready()
  // fastify-plugin ensures that all decorators
  // are exposed for testing purposes, this is
  // different from the production setup

  // tear down our app after we are done
  t.after(() => app.close())

  return app
}

export { build }
EOL

cat <<EOL > plugins/supabase.js
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
EOL

cat <<EOL > test/plugins/supabase.test.js
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
EOL

echo "Fastify server setup with authentication is complete."


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