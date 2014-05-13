Recore = null

exports.setRecore = (recore) -> Recore = recore

exports.retrieve = (req, res) ->
  return res.status 404 unless req.params.model
  step = 10
  page = req.params.page or 1
  per_page = Math.min req.query.per_page or 30, 100
  req.session.per_page = per_page
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

exports.create = (req, res) ->
  model = Recore.getModel req.body.model
  return 404 unless model?
  ins = new model
  ins.prop req.body.properties
  ins.save (err) ->
    return res.send 400, @errors if err
    return res.send [
      id: @id
      model: model.modelName
      properties: @allProperties()
    ]

exports.update = (req, res) ->
  model = Recore.getModel req.body.model
  return 404 unless model?

  find_or_create = (callback) ->
    if isNaN parseInt(req.body.id)
      ins = new model
      return callback.call ins, null, ins.allProperties()
    return model.load req.body.id, (err, props) ->
      return callback err if err
      return callback.apply @, arguments

  find_or_create (err, props) ->
    return res.send 500 if err
    @prop req.body.properties
    @save (err) ->
      return res.send 400, @errors if err
      return res.send [
        id: @id
        model: model.modelName
        properties: @allProperties()
      ]

exports.destroy = (req, res) ->
  model = Recore.getModel req.params.model
  id = req.params.id
  return res.send 400 unless model and id
  model.remove id, (err) ->
    return res.send 500 if err
    return res.send 200
