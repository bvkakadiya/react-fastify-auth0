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
