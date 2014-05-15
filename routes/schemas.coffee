Task   = require '../lib/task'
Recore = null

exports.setRecore = (recore) -> Recore = recore

exports.index = (req, res) ->
  return res.status 404 unless req.params.model
  model = Recore.getModel req.params.model
  return res.status 404 unless model
  task = {}
  properties = {}
  ins = new model

  for id, data of Task.all()
    task = data.dump() if data.model is model.modelName

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

  model.count (err, count) ->
    return res.status 500 if err
    return res.send
      id: req.params.model
      name: req.params.model
      count: count
      id_generator: id_generator
      _id_generator: _id_generator ? ""
      properties: properties
      task: task

exports.node = (req, res) ->
  res.send 200
