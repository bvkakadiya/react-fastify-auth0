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
