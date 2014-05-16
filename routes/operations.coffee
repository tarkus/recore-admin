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

  event = model.create_index req.params.property

  event.on 'objects', (count) -> task.update objects: count

  event.on 'checkpoint', (count) ->
    task.update current: count
    socket.io.sockets.in(req.app.path()).emit 'task progress', task.dump()

  event.on 'done', (count) ->
    task.update current: count, progress: 100
    socket.io.sockets.in(req.app.path()).emit 'task progress', task.dump()
    task.destroy()

  event.on 'error', (error) -> console.error error

  event.on 'halt', (error) ->
    console.error error
    task.status 'stopped'
    socket.io.sockets.in(req.app.path()).emit 'task progress', task.dump()

  return res.send task.dump()

exports.remove_index = (req, res) ->
  model = Recore.getModel req.params.model
  return res.send 404 unless model
  return res.send 400 unless req.params.property

  title = "Removing index on #{req.params.model}.#{req.params.property}"
  task = new Task model: req.params.model, title: title

  event = model.remove_index req.params.property

  event.on 'objects', (count) -> task.update objects: count

  event.on 'checkpoint', (count) ->
    task.update current: count
    socket.io.sockets.in(req.app.path()).emit 'task progress', task.dump()

  event.on 'done', (count) ->
    task.update current: count, progress: 100
    socket.io.sockets.in(req.app.path()).emit 'task progress', task.dump()
    task.destroy()

  event.on 'error', (error) -> console.error error

  event.on 'halt', (error) ->
    console.error error
    task.status 'stopped'
    socket.io.sockets.in(req.app.path()).emit 'task progress', task.dump()

  return res.send task.dump()

exports.remove_property = (req, res) ->
  model = Recore.getModel req.params.model
  return res.send 404 unless model
  ins = new model
  property = ins.properties[req.params.property]
  return res.send 400 if property

  title = "Removing property #{req.params.model}.#{req.params.property}"
  task = new Task model: req.params.model, title: title

  #
  # same as above plus hdel 
  
  return res.send task.dump()
