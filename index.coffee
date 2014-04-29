express  = require 'express'
assets   = require 'connect-assets'
template = require 'express-webapp-view'

module.exports = (options) ->

    (req, res, next) ->

      app = express()

      app.locals.title = "Reco Backend"

      StatsHandler = (req, res, next) ->
        Reco.client.info (err, result) ->
          res.locals.stats = result unless err
          next err

      CountHandler = (req, res, next) ->
          models = Reco.getModels()
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

      app.configure ->
        app.set 'view engine', 'jade'
        app.set 'views', "#{__dirname}/../views"

        app.use express.favicon "#{__dirname}/../public/images/favicon.png"
        app.use express.compress()
        app.use express.methodOverride()
        app.use express.json strict: false
        app.use express.urlencoded()
        app.use express.cookieParser()
        app.use express.static "#{__dirname}/../public"

        app.use app.router

      app.on 'mount', (parent) ->

        parent.record_backend = app
        app.locals.base_uri = app.path()
        app.locals.models = JSON.stringify Object.keys Reco.getModels()

        app.use assets
          src: "#{__dirname}/../public"
          helperContext: app.locals
          servePath: app.path()

        app.use Reco.connect
          url: "/validator.js"
          namespace: 'validator'

        template.setup "app", prefix: "#{app.path()}/templates"
        template.attach app

        app.use "/templates", template.connect()

      app.get "/schema/:name", (req, res) ->
        return res.status 404 unless req.params.name
        schema = {}
        model = Reco.getModels()[req.params.name]
        ins = new model
        for name, def of ins.properties
          def.type = def.type.toString() if typeof def.type is "function"
          def.defaultValue = def.defaultValue.toString() if typeof def.defaultValue is "function"

          schema[name] =
            type: def.type
            index: def.index
            unique: def.unique
            default: def.defaultValue

        res.send JSON.stringify name: req.params.name, schema: schema

      app.get "/record/:model/page/:page", (req, res) ->
        return res.status 404 unless req.params.model
        page = req.params.page or 1
        number_per_page = 30
        model = Reco.getModels()[req.params.name]
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
