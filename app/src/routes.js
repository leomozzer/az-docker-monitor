const routes = require('express').Router()
const client = require('prom-client')

// // Create a Registry which registers the metrics
const register = new client.Registry()

routes.get('/', (req, res) => {
    res.send("Hello World")
})

//Create a route to expose metrics
routes.get('/metrics', async (req, res) => {
    res.setHeader('Content-Type', client.register.contentType);
    res.send(await client.register.metrics());
});

module.exports = routes