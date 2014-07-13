Task   = require '../lib/task'


format_schema = (model) ->
  error_handler = ->
  resolve_handler = ->

  task = {}
  properties = {}
  ins = new model

  for id, data of Task.all()
    task = data.dump() if data.model is model.modelName

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
      sortable: def.__numericIndex

  if typeof ins.idGenerator is 'function'
    id_generator = '[Function]'
    _id_generator = ins.idGenerator.toString()
  else
    id_generator = ins.idGenerator

  model.count (err, count) ->
    return error_handler() if err
    return resolve_handler
      id: model.modelName
      name: model.modelName
      count: count
      collection: model.isCollection
      id_generator: id_generator
      _id_generator: _id_generator ? ""
      properties: properties
      task: task

  promise =
    error: (func) ->
      error_handler = func
      promise

    success: (func) ->
      resolve_handler = func
      promise

  return promise

module.exports = (recore) ->

  format_schema: format_schema

  index: (req, res) ->
    return res.send 404 unless req.params.model
    if req.params.model.indexOf(":") is -1
      model = recore.getModel req.params.model
    else
      model = recore.collections[req.params.model]
    return res.send 404 unless model

    format_schema model
      .success (data) ->
        res.app.locals.models[req.params.model] = data
        res.send data
      .error -> res.send 500

  node: (req, res) ->
    res.send 200
