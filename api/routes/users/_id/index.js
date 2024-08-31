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
