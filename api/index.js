import Fastify from 'fastify'
import path from 'path'
import AutoLoad from '@fastify/autoload'
import { fileURLToPath } from 'url'
import closeWithGrace from 'close-with-grace'

const init = () => {
  const filename = fileURLToPath(import.meta.url)
  const __dirname = path.dirname(filename)

  const app = Fastify({
    logger: true,
  })
  app.register(AutoLoad, {
    dir: path.join(__dirname, 'routes'),
    options: { prefix: '/api' },
  })
  
  app.register(AutoLoad, {
    dir: path.join(__dirname, 'plugins'),
    options: {}
  })

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
if (import.meta.url === `file://${process.argv[1]}`) {
  const app = init()
  // called directly i.e. "node app"
  app.listen({ port: 3000 }, (err) => {
    if (err) console.error(err)
    console.log('server listening on 3000')
  })
}
export default async function handler(req, reply) {
  const app = init()
  await app.ready()
  app.server.emit('request', req, reply)
}
