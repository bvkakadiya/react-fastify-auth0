import Fastify from 'fastify'
import path from 'path'
import AutoLoad from '@fastify/autoload'
import { fileURLToPath } from 'url'
import closeWithGrace from 'close-with-grace'

const filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(filename)

const app = Fastify({
  logger: true,
})
app.register(AutoLoad, {
  dir: path.join(__dirname, 'routes'),
  options: { prefix: '/api' },
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

app.get('/hello', async (req, reply) => {
  return reply.status(200).send({ html: 'Hello World' })
})

// app.listen({ port: 3000 }, (err, address) => {
//   if (err) {
//     app.log.error(err)
//     process.exit(1)
//   }
//   app.log.info(`Server listening at ${address}`)
// })
export default async function handler(req, reply) {
  await app.ready()
  app.server.emit('request', req, reply)
}
