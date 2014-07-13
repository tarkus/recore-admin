express      = require 'express'
compress     = require 'compression'
bodyParser   = require 'body-parser'
cookieParser = require 'cookie-parser'
errorHandler = require 'errorhandler'
logger       = require 'morgan'
assert       = require 'assert'
routes       = require './routes'
Socket       = require './lib/socket'

class RecoreAdmin

  constructor: (@options) ->
    assert @options.recore, "recore instance required"
    assert @options.title, "title required"
    @recore = @options.recore

    @app = app = express()

    @app.socket = new Socket @app

    @routes = routes.use @recore

    @app.locals.title = @options.title
    @app.locals.base_uri = '/'
    @app.locals.tasks = []
    @app.locals.models = {}

    for name, model of @recore.getModels()
      @app.locals.models[name] = name: name, collection: model.isCollection
      locals = @app.locals
      do (name, model) ->
        model.count (error, count) ->
          locals.models[name].count = count unless error

    @app.use logger("dev") if @app.get('env') isnt 'production'

    @app.use compress()
    @app.use bodyParser.json()
    @app.use bodyParser.urlencoded extended: true
    @app.use cookieParser()

    @app.use @recore.connect url: "/validator.js", namespace: 'validator'
    @app.use '/bootstrap.js', (req, res, next) ->
      res.type 'text/javascript'
      res.send """
        var base_uri = "#{req.app.locals.base_uri}";
        var title = "#{req.app.locals.title}";
        var models = #{JSON.stringify(req.app.locals.models)};
      """

    @app.use express.static "#{__dirname}/node_modules/recore-admin-ui/public"


    # Routes
    @app.get "/record/:model/page/:page", routes.records.retrieve

    @app.post "/record/:model", routes.records.update
    @app.put  "/record/:model", routes.records.update

    @app.del "/record/:model/:id", routes.records.destroy
    @app.post "/record", routes.records.create

    @app.get "/schema/:model", routes.schemas.index

    @app.get "/stats", routes.stats.index
    @app.get "/stats/:node", routes.stats.node

    @app.post "/util/finder", routes.misc.finder
    @app.get  "/util/loader", routes.misc.loader

    @app.get "/create_index/:model/:property", routes.operations.create_index
    @app.get "/remove_index/:model/:property", routes.operations.remove_index
    @app.get "/remove_property/:model/:property", routes.operations.remove_property

    @app.get "/task/stop/:id", routes.tasks.stop
    @app.get "/task/pause/:id", routes.tasks.pause
    @app.get "/task/resume/:id", routes.tasks.resume
    @app.get "/task/dump/:id", routes.tasks.dump

    @app.get "/", (req, res, next) ->
      res.sendfile "#{__dirname}/node_modules/recore-admin-ui/public/index.html"

    @app.use errorHandler() unless @app.get 'env' is 'deveopment'

    @app.on 'mount', (parent) ->
      app.locals.base_uri = app.path()

    return @app


module.exports = RecoreAdmin
