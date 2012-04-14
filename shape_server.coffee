express = require 'express'
app = module.exports = express.createServer()

Shapefile = require('./shapefile/shapefile').Shapefile
countries = new Shapefile './shapefiles/northamerica_adm0'

app.configure ->
  app.use app.router

app.configure 'development', ->
  app.use express.errorHandler
    dumpExceptions: true,
    showStack: true

app.configure 'production', ->
  app.use express.errorHandler()

app.get '/number_of_shapes', (req, res) ->
  body = JSON.stringify countries.header.numShapes
  res.writeHead 200, {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*"
    'Content-Length': body.length
  }
  res.end body

app.get '/:shape', (req, res) ->
  if req.params.shape < 0
    body = JSON.stringify {error: 'You have specified a shape that does not exist.'}
  else if req.params.shape > countries.header.numShapes - 1
    body = JSON.stringify {error: 'You have specified a shape that does not exist.'}
  else
    body = JSON.stringify countries.shapes[req.params.shape]
  res.writeHead 200, {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*"
    'Content-Length': body.length
  }
  res.end body

app.listen 4000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env

