#!/bin/bash

# Install necessary dependencies
npx fastify-cli generate api --esm --standardlint 
cd api
npm install fastify-auth0-verify dotenv @supabase/supabase-js

# Create .env file with Auth0 credentials
cat <<EOL > .env.example
VITE_AUTH0_DOMAIN=<your-auth0-domain>
VITE_AUTH0_CLIENT_ID=<your-client-id>
VITE_AUTH0_SECRET=<your-client-secret>
AUTH0_AUDIENCE=api
SUPABASE_URL='https://<YOUR_SUPABASE_URL>.supabase.co'
NEXT_PUBLIC_SUPABASE_ANON_KEY='<YOUR_SUPAB>'
EOL

# Create index.js file with Fastify server setup
cat <<EOL > index.js
import Fastify from 'fastify'
import path from 'path'
import AutoLoad from '@fastify/autoload'
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
  app.register(AutoLoad, {
    dir: path.join(__dirname, 'routes'),
    options: { prefix: '/api' }
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
if (import.meta.url === 'file://'+ process.argv[1]) {
  const app = init()
  // called directly i.e. "node app"
  app.listen({ port: 3000 }, (err) => {
    if (err) console.error(err)
    console.log('server listening on 3000')
  })
}
export default async function handler (req, reply) {
  const app = init()
  await app.ready()
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
  console.log(fastify.supabase, 'fastify.supabase')

  assert.ok(fastify.supabase)
})
EOL

echo "Fastify server setup with authentication is complete."