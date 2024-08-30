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
