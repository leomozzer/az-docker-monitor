const express = require('express')
const app = express()
const client = require('prom-client');
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics({ timeout: 5000 });

const PORT = process.PORT || 8080

const routes = require('./routes')

app.use(routes)

app.listen(PORT, () => { console.log(`App running in ${PORT}`) })