cuid   = require 'cuid'

class Task

  @tasks: {}

  @all: => @tasks

  @find: (id) =>
    @tasks[id]

  @max_error_count: 10

  constructor: (model: @model, title: title) ->
    @id = cuid()
    @properties =
      id: @id
      model: @model
      title: title
      status: 'running'
      errors: []
      current: 0
      objects: 0
      progress: 0
      updated_at: new Date().getTime()
      started_at: new Date().getTime()
      time_elapsed: 0
      time_estimated: null


    Task.tasks[@id] = @
    @

  status: (status) =>
    return @properties.status unless status?
    @update status: status

  update: (properties) =>
    @set properties
    @touch()

  touch: =>
    now = new Date().getTime()

    @properties.time_elapsed = now - @properties.updated_at
    @properties.updated_at   = now

    if @properties.progress is 0
      @properties.time_estimated = null
    else
      @properties.time_estimated = Math.ceil(@properties.time_elapsed / @properties.progress) * 100

    if @properties.time_estimated < @properties.time_elapsed
      @properties.time_estimated = null

  set: (properties) =>
    for key, value of properties
      @properties[key] = value
      if key is 'current' or key is 'objects'
        if @properties.objects > 0
          @properties.progress = Math.floor(@properties.current / @properties.objects) * 100
    if @properties.progress is 100
      @properties.status

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


