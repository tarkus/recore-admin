cuid   = require 'cuid'

###
tasks = exports.tasks = {}

exports.all = ->
  tasks

exports.find = (id) ->
  tasks[id]

exports.new = (model, title) ->
  id = cuid()
  tasks[id] =
    id: id
    model: model
    title: title
    status: 'running'
    errors: []
    current: 0
    objects: 0
    progress: 0
    started_at: new Date().getTime()
    time_elapsed: 0
    time_estimated: 0
  tasks[id]
###

class Task

  @tasks: {}

  @all: => @tasks

  @find: (id) =>
    @tasks[id]

  @max_error_count: 10

  constructor: (model: model, title: title) ->
    @id = cuid()
    @properties =
      id: @id
      model: model
      title: title
      status: 'running'
      errors: []
      current: 0
      objects: 0
      progress: 0
      started_at: new Date().getTime()
      time_elapsed: 0
      time_estimated: null

    Task.tasks[@id] = @
    @

  status: (status) =>
    return @properties.status unless status?
    @update status: status

  update: (properties) =>
    @touch()
    @set properties

  touch: =>
    @properties.time_elapsed = new Date().getTime() - @properties.started_at
    if @properties.progress is 0
      @properties.time_estimated = null
    else
      @properties.time_estimated = Math.ceil(@properties.time_elapsed / @properties.progress) * 100

    console.log @properties.time_estimated, @properties.time_elapsed
    if @properties.time_estimated < @properties.time_elapsed
      @properties.time_estimated = null

  set: (properties) =>
    @properties[k] = v for k, v of properties

  destroy: =>
    delete Task.tasks[@id]
    delete @

  error: (error) =>
    @touch()
    @properties.errors.push error
    if @properties.errors.length > Task.max_error_count
      @properties.status = 'error'

  dump: => @properties

  toString: => @dump()




module.exports = Task


