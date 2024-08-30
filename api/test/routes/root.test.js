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
