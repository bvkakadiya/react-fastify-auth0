export default async function (fastify, opts) {
  fastify.get('/', {
    preValidation: async (req, reply) => await fastify.authenticate(req, reply),
    handler: async function (request, reply) {
      return 'this is an example wow'
    }
  })
}
