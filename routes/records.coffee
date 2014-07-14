module.exports = (recore) ->

  retrieve: (req, res) ->
    return res.send 404 unless req.params.model
    step = 10
    page = req.params.page or 1
    per_page = Math.min req.query.per_page or 30, 100
    direction = req.query.direction or 'DESC'
    direction = direction.toUpperCase()
    field = req.query.field or 'id'

    if req.params.model.indexOf(":") is -1
      model = recore.getModel req.params.model
    else
      model = recore.collections[req.params.model]

    return res.send 404 unless model

    start = (page - 1) * per_page + 1
    stop = start + per_page - 1
    count = 0
    records = []

    model.getClient().scard model.getIdsetsKey(), (err, total) ->
      return res.send 500 if err
      total ?= 0
      total = parseInt(total)
      return res.send records if total is 0

      stop = Math.min total, stop

      return model.sort
        field: field
        direction: direction
        limit: [(page - 1) * per_page, per_page]
      , (err, ids) ->
        return res.send 500 if err
        max = Math.min ids.length, per_page
        return res.send records if max is 0
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

  create: (req, res) ->
    model = recore.getModel req.body.model
    return 404 unless model?
    ins = new model
    for key, value of req.body.properties
      continue unless value.toString().length > 0
      ins.prop key, value
    ins.save (err) ->
      return res.send 400, @errors if err
      return res.send [
        id: @id
        model: model.modelName
        properties: @allProperties()
      ]

  update: (req, res) ->
    model = recore.getModel req.body.model
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
      for key, value of req.body.properties
        continue unless value.toString().length > 0
        @prop key, value
      @save (err) ->
        return res.send 400, @errors if err
        return res.send [
          id: @id
          model: model.modelName
          properties: @allProperties()
        ]

  destroy: (req, res) ->
    model = recore.getModel req.params.model
    id = req.params.id
    return res.send 400 unless model and id
    model.remove id, (err) ->
      return res.send 500 if err
      return res.send 200
