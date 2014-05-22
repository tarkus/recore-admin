express      = require 'express'
favicon      = require 'serve-favicon'
compress     = require 'compression'
bodyParser   = require 'body-parser'
cookieParser = require 'cookie-parser'
errorHandler = require 'errorhandler'
session      = require 'express-session'
logger       = require 'morgan'
assets       = require 'connect-assets'
webapp_view  = require 'express-webapp-view'
static_view  = require 'express-static-view'
assert       = require 'assert'

socket = exports.socket = require './lib/socket'

exports.connect = (options) ->
  Recore = options.recore
  assert Recore, "recore instance required"

  app = express()
  socket.bind app

  routes = require './routes'
  mod.setRecore Recore for name, mod of routes

  app.locals.tasks = []
  app.locals.title = "Recore Backend"
  app.locals.subtitle = options.title

  app.locals.models = {}

  for name, model of Recore.getModels()
    app.locals.models[name] = { name: name, collection: model.isCollection }
    do (name, model) ->
      model.count (err, count) ->
        return if err
        app.locals.models[name].count = count

  app.set 'view engine', 'jade'
  app.set 'views', "#{__dirname}/views"

  app.use favicon "#{__dirname}/public/images/favicon.png"
  app.use compress()
  app.use express.static "#{__dirname}/public"

  app.use bodyParser.json()
  app.use bodyParser.urlencoded()
  app.use cookieParser()

  app.use session secret: "lj2l34j;2l1jofupojlk12n34"

  app.use Recore.connect
    url: "/validator.js"
    namespace: 'validator'

  app.use logger("dev")

  app.get  "/record/:model/page/:page", routes.records.retrieve

  app.post "/record/:model", routes.records.update
  app.put  "/record/:model", routes.records.update

  app.del  "/record/:model/:id", routes.records.destroy
  app.post "/record", routes.records.create

  app.get  "/schema/:model", routes.schemas.index

  app.get  "/stats", routes.stats.index
  app.get  "/stats/:node", routes.stats.node

  app.post "/util/key_finder", routes.misc.key_finder
  app.get  "/util/collection_loader", routes.misc.collection_loader

  app.get "/create_index/:model/:property", routes.operations.create_index
  app.get "/remove_index/:model/:property", routes.operations.remove_index
  app.get "/remove_property/:model/:property", routes.operations.remove_property

  app.get "/task/stop/:id", routes.tasks.stop
  app.get "/task/pause/:id", routes.tasks.pause
  app.get "/task/resume/:id", routes.tasks.resume
  app.get "/task/dump/:id", routes.tasks.dump

  app.get "/", static_view 'layout', filter: (html) ->
    html.replace '{models}', JSON.stringify app.locals.models

  app.use errorHandler()

  app.on 'mount', (parent) ->
    app.locals.base_uri = app.path()

    app.use assets
      src: "#{__dirname}/public"
      helperContext: app.locals
      servePath: app.path()

    app.use "/templates", webapp_view.connect
      apps: 'app', webroot: "#{__dirname}/public/javascripts"
      context: app.locals

  return app
