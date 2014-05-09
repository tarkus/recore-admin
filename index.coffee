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
url          = require 'url'

assert   = require 'assert'

exports.connect = (options) ->
    Recore = options.recore
    assert Recore, "recore instance required"

    app = express()

    app.locals.title = "Recore Backend"
    app.locals.subtitle = options.title

    app.locals.count = {}
    app.locals.models = []

    for name, model of Recore.getModels()
      do (name, model) ->
        app.locals.models.push name
        model.count (err, count) ->
          return if err
          app.locals.count[name] = count

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

    app.get "/stats", (req, res) ->
      stats = []
      redism = Recore.getClient()
      nodes = redism.client_list.length
      server_list = Object.keys(redism.server_list)
      servers = server_list.length

      stats.push
        name: 'Nodes'
        group: '2'
        content:
          nodes: nodes
          servers: servers

      random_index = Math.floor(Math.random() * (servers - 1))
      random_server = server_list[random_index]
      random_client = redism.clients[random_server]
      random_client.info (err, raw) ->
        return res.status 500 if err
        serverparts = url.parse(random_server)
        keys = 0
        info = {}
        _info = {}
        rows = raw.match /(\w+):(.*)/g
        for row in rows
          [key, value] = row.split(":")
          if key.match /db(\d+)/
            keys += parseInt(value.split(',')[0].split("=")[1])
          _info[key] = value

        info['Keys'] = keys
        info['Memory Used'] = _info['used_memory_human']
        info['Memory Peak'] = _info['used_memory_peak_human']
        info['Connections'] = _info['connected_clients']
        info['Uptime'] = "#{_info['uptime_in_days']} days"
        info['AOF Status'] = _info['aof_last_write_status']
        info['RDB Status'] = _info['rdb_last_bgsave_status']
        info['Redis Version'] = _info['redis_version']

        stats.push
          name: "Info of #{serverparts.host}"
          group: '2'
          content: info

        random_client.slowlog 'get', 10, (err, slowlogs) ->
          return res.send 500 if err
          logs = []
          for log in slowlogs
            logs.push
              date: new Date(log[1] * 1000).toISOString()
              time: "#{log[2] / 1000}ms"
              command: log[3].join(" ")

          stats.push
            name: "Slowlogs from #{serverparts.host}"
            size: 2
            group: 1
            content: logs

          res.send stats

    app.get "/stats/:node", (req, res) ->
      res.send []

    app.get "/schema/:model", (req, res) ->
      return res.status 404 unless req.params.model
      properties = {}
      model = Recore.getModel req.params.model
      ins = new model
      sortables = []
      _sortables = []

      for name, def of ins.properties
        score = 0
        type = ""
        default_value = ""

        if typeof def.defaultValue is "function"
          default_value = def.defaultValue.toString()
          def.defaultValue = "[Function]"

        if typeof def.type is 'function'
          type = def.type.toString()
          def.type = "[Function]"

        if def.__numericIndex
          score = 10

          if def.type is 'timestamp'
            score += 100

            if typeof def.defaultValue is 'function'
              score += 300

          _sortables[score] = name

        properties[name] =
          type: def.type ? "string"
          _type: type
          index: def.index
          unique: def.unique
          default_value: def.defaultValue
          _default_value: default_value
          numeric_index: def.__numericIndex

      if typeof ins.idGenerator is 'function'
        id_generator = '[Function]'
        _id_generator = ins.idGenerator.toString()
      else
        id_generator = ins.idGenerator

      _sortables.map (name) -> sortables.push name

      model.count (err, count) ->
        return res.status 500 if err
        return res.send
          name: req.params.model
          count: count
          id_generator: id_generator
          _id_generator: _id_generator ? ""
          sortables: sortables
          properties: properties

    app.get "/record/:model/page/:page", (req, res) ->
      return res.status 404 unless req.params.model
      step = 10
      page = req.params.page or 1
      per_page = Math.min req.query.per_page or 30, 100
      direction = req.query.direction or 'DESC'
      direction = direction.toUpperCase()
      field = req.query.sort_on or 'id'
      model = Recore.getModel req.params.model

      start = (page - 1) * per_page + 1
      stop = start + per_page - 1
      count = 0
      records = []

      model.getClient().scard model.getIdsetsKey(), (err, total) ->
        return res.status 500 if err
        total ?= 0
        total = parseInt(total)
        return res.send records if total is 0

        stop = Math.min total, stop

        # We're sorting on a field
        unless field is 'id'
          return model.sort
            field: field
            direction: direction
            limit: [(page - 1) * per_page, per_page]
          , (err, ids) ->
            return res.status 500 if err
            ids.forEach (id) ->
              do (id) ->
                model.load id, (err, props) ->
                  count++
                  return unless props
                  records.push
                    id: @id
                    model: model.modelName
                    total: total
                    range: [start, stop]
                    properties: props
                  return res.send records if count is per_page

        # We're sorting on id
        offset = (page - 1) * per_page

        model.getClient().sort model.getIdsetsKey(), "limit", offset, per_page, direction, (err, ids) ->
          return res.status 500 if err
          return res.send records if ids.length is 0

          idx = 0
          max = ids.length

          fetch = ->
            id = ids[idx]
            model.load id, (err, props) ->
              # If hit error will return 500
              return res.status 500 if err and err isnt 'not found'
              # If we got a record
              if props
                records.push
                  id: @id
                  model: model.modelName
                  total: total
                  range: [start, stop]
                  properties: props

              # If we got enough records or hit the bottem then it's done
              return res.send records if idx + 1 is max
              # Otherwise we iterate
              idx++
              return fetch()

          return fetch()

    app.put "/record", (req, res) ->
      console.log req.body

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
