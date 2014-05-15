socket = require '../lib/socket'
Task   = require '../lib/task'

Recore = null

exports.setRecore = (recore) -> Recore = recore

exports.create_index = (req, res) ->
  model = Recore.getModel req.params.model
  return res.send 404 unless model
  ins = new model
  property = ins.properties[req.params.property]
  return res.send 400 unless property and (property.index or property.unique)

  title = "Indexing on #{req.params.model}.#{req.params.property}"
  task = new Task model: req.params.model, title: title

  ###
  page = 0
  per_page = 1000
  Recore.getClient().sort model.getIdsKey(), 'limit', page * per_page, per_page, 'asc', (err, ids) ->
  ###

  # Mock it up
  progress = 0

  emit_progress = ->
    task = Task.find task.id
    return unless task
    return setTimeout emit_progress, 5000 unless task.status() is 'running'

    progress += 10

    task.update progress: progress

    socket.io.sockets.in(req.app.path()).emit "progress", task.dump()

    return setTimeout emit_progress, 5000 unless progress is 100
    return task.destroy()

  setTimeout emit_progress, 100

  return res.send task.dump()

exports.remove_index = (req, res) ->
  model = Recore.getModel req.params.model
  return res.send 404 unless model
  ins = new model
  property = ins.properties[req.params.property]
  return res.send 400 unless property
  return res.send 400 if property.index or property.unique

  title = "Removing index on #{req.params.model}.#{req.params.property}"
  task = new Task model: req.params.model, title: title

  # Mock it up
  progress = 0

  emit_progress = ->
    task = Task.find task.id
    return unless task
    return setTimeout emit_progress, 5000 unless task.status() is 'running'

    progress += 10

    task.update progress: progress

    socket.io.sockets.in(req.app.path()).emit "progress", task.dump()

    return setTimeout emit_progress, 5000 unless progress is 100
    return task.destroy()

  setTimeout emit_progress, 100

  return res.send task.dump()

exports.remove_property = (req, res) ->
  model = Recore.getModel req.params.model
  return res.send 404 unless model
  ins = new model
  property = ins.properties[req.params.property]
  return res.send 400 if property

  title = "Removing property #{req.params.model}.#{req.params.property}"
  task = new Task model: req.params.model, title: title

  # Mock it up
  progress = 0

  emit_progress = ->
    task = Task.find task.id
    return unless task
    return setTimeout emit_progress, 5000 unless task.status() is 'running'

    progress += 10

    task.update progress: progress

    socket.io.sockets.in(req.app.path()).emit "progress", task.dump()

    return setTimeout emit_progress, 5000 unless progress is 100
    return task.destroy()

  setTimeout emit_progress, 100

  return res.send task.dump()
