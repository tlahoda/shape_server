express = require 'express'
app = module.exports = express.createServer()

Shapefile = require('./shapefile/shapefile').Shapefile
shapes = new Shapefile './shapefiles/northamerica_adm0'

app.configure ->
  app.use app.router

app.configure 'development', ->
  app.use express.errorHandler
    dumpExceptions: true,
    showStack: true

app.configure 'production', ->
  app.use express.errorHandler()

app.get '/number_of_shapes', (req, res) ->
  body = shapes.header.numShapes
  res.json body

app.get '/:shape', (req, res) ->
  if req.params.shape < 0 or req.params.shape > shapes.header.numShapes - 1
    body = {error: 'You have specified a shape that does not exist.'}
  else
    body = shapes.shapes[req.params.shape]
  res.json body

app.listen 4000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env

