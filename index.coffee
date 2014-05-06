express      = require 'express'
favicon      = require 'serve-favicon'
compress     = require 'compression'
bodyParser   = require 'body-parser'
cookieParser = require 'cookie-parser'
errorHandler = require 'errorhandler'
logger       = require 'morgan'
assets       = require 'connect-assets'
webapp_view  = require 'express-webapp-view'
static_view  = require 'express-static-view'

assert   = require 'assert'

exports.connect = (options) ->
    Recore = options.recore
    assert Recore, "recore instance required"

    app = express()

    app.locals.title = "Recore Backend"
    app.locals.subtitle = options.title
    app.locals.models = JSON.stringify Object.keys Recore.getModels()

    app.set 'view engine', 'jade'
    app.set 'views', "#{__dirname}/views"

    app.use favicon "#{__dirname}/public/images/favicon.png"
    app.use compress()
    app.use express.static "#{__dirname}/public"

    app.use bodyParser.json()
    app.use bodyParser.urlencoded()
    app.use cookieParser()

    app.use Recore.connect
      url: "/validator.js"
      namespace: 'validator'

    app.use logger("dev")

    StatsHandler = (req, res, next) ->
      Recore.client.info (err, result) ->
        res.locals.stats = result unless err
        next err

    CountHandler = (req, res, next) ->
        models = Recore.getModels()
        total = Object.keys(models).length
        output = {}
        counter = 0
        _count = (name) ->
          model.count (err, count) ->
            counter += 1
            return next err if err
            output[name] = count
            if counter is total
              res.locals.count = output
              next()
        _count name for name, model of models

    app.get "/schema/:model", (req, res) ->
      return res.status 404 unless req.params.model
      properties = {}
      model = Recore.getModel req.params.model
      ins = new model

      for name, def of ins.properties
        type = ""
        default_value = ""

        if typeof def.defaultValue is "function"
          default_value = def.defaultValue.toString()
          def.defaultValue = "[Function]"

        if typeof def.type is 'function'
          type = def.type.toString()
          def.type = "[Function]"

        properties[name] =
          type: def.type ? "string"
          _type: type
          index: def.index
          unique: def.unique
          default_value: def.defaultValue
          _default_value: default_value

      if typeof ins.idGenerator is 'function'
        id_generator = '[Function]'
        _id_generator = ins.idGenerator.toString()
      else
        id_generator = ins.idGenerator

      res.send JSON.stringify
        name: req.params.model
        id_generator: id_generator
        _id_generator: _id_generator ? ""
        properties: properties

    app.get "/model/:model/page/:page", (req, res) ->
      return res.status 404 unless req.params.model
      page = req.params.page or 1
      number_per_page = 30
      model = Recore.getModels()[req.params.name]
      model.sort
        field: 'created_at'
        direction: 'DESC'
        start: (page - 1) * number_per_page
        limit: number_per_page
      , (err, ids) ->
        return res.status 500 if err
        all = []
        counter = 0
        total = ids.length
        ids.forEach (id) ->
          model.load id, (err, props) ->
            counter += 1
            return if err

    app.get "/", static_view 'layout'

    app.use errorHandler()

    app.on 'mount', (parent) ->
      app.locals.base_uri = app.path()

      app.use assets
        src: "#{__dirname}/public"
        helperContext: app.locals
        servePath: app.path()

      app.use "/templates", webapp_view.connect
        apps: 'app', webroot: "#{__dirname}/public/javascripts"

    return app
