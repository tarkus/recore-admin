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

  if req.params.model.indexOf(":") is -1
    model = Recore.getModel req.params.model
  else
    model = Recore.collections[req.params.model]

  return res.status 404 unless model

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
    max  = Math.min total, per_page

    return model.sort
      field: field
      direction: direction
      limit: [(page - 1) * per_page, per_page]
    , (err, ids) ->
      return res.status 500 if err
      ids.forEach (id, idx) ->
        do (id) ->
          model.load id, (err, props) ->
            count++
            return unless props
            records[idx] =
              id: @id
              model: model.modelName
              total: total
              range: [start, stop]
              properties: props
            return res.send records if count is max

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
