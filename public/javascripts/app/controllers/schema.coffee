SchemaModel = @app.require 'model schema'

class Schema extends Spine.Controller

  elements:
    ".modal": "modal"
    ".txt": "menu_text"

    ".actions .input-group": "actions"
    ".action.create-index .input-group-btn": "create_index_btn"
    ".action.remove-index .input-group-btn": "remove_index_btn"
    ".action.remove-property .input-group-btn": "remove_property_btn"

    ".action.remove-index input": "remove_index_property_field"
    ".action.remove-property input": "remove_property_field"

    ".task-progress": "progress_container"
    ".task-progress .progress-report": "progress"
    ".task-progress .empty": "noprogress"

    ".progress-report .btn-dump": "btn_dump"

    ".progress-report .progress-bar": "progress_bar"
    ".progress-report .progress-bar span": "progress_text"

    ".progress-report .title": "task_title"
    ".progress-report .status": "task_status"
    ".progress-report .errors": "task_errors"
    ".progress-report .objects": "task_objects"
    ".progress-report .time-elapsed": "task_time_elapsed"
    ".progress-report .time-left": "task_time_left"

    ".task-control .btn-play": "btn_play"
    ".task-control .btn-stop": "btn_stop"
    ".task-control .btn-pause": "btn_pause"

  events:
    "click .function": "detail"
    "click .action.create-index .dropdown-menu a": "select_field_to_create_index"

    "click .action.create-index .input-group-btn": "create_index"
    "click .action.remove-index .input-group-btn": "remove_index"
    "click .action.remove-property .input-group-btn": "remove_property"

    "click .progress-report .btn-dump": "task_dump"

    "click .task-control .btn-play": "task_resume"
    "click .task-control .btn-stop": "task_stop"
    "click .task-control .btn-pause": "task_pause"

  constructor: (schema: @schema) ->
    super
    @render()
    @schema.bind 'progress', @progress_report

  detail: (e) =>
    target = $(e.target)
    @modal.find(".modal-title").html target.data('title')
    @modal.find(".content").html target.data('content')
    @modal.modal 'show'

  progress_report: (schema, data) =>
    return unless data.progress?

    if data.progress is 100
      text = 'DONE'
      @task_done()
    else
      text = "#{data.progress}%"

    status = data.status
    status = """<font style="color: #d64e28">#{data.status}</font>""" if status is 'paused'
    status = 'DONE' if data.progress is 100

    @task_status.html status
    @task_objects.html "#{data.current}/#{data.objects}"
    @task_errors.html "#{data.errors.length}"
    @task_time_elapsed.html @duration data.time_elapsed
    @task_time_left.html @duration data.time_estimated - data.time_elapsed
      
    #FIXME
    #    Have to use jQuery here?
    $('.schema .progress-bar').css "width", "#{data.progress}%"
    $('.schema .progress span').html "#{text}"

  task_init: =>
    @btn_dump.attr 'disabled', false
    @btn_play.attr 'disabled', false
    @btn_stop.attr 'disabled', false
    @btn_pause.attr 'disabled', false

    @task_title.html @schema.task.title
    @task_status.html @schema.task.status
    @task_objects.html "#{@schema.task.current}/#{@schema.task.objects}"
    @task_time_elapsed.html @duration 0
    @task_time_left.html @duration null

    @noprogress.css 'display', 'none'
    @progress.css 'display', 'block'

    @disable_actions()

  task_done: =>
    @btn_dump.attr 'disabled', 'disabled'
    @btn_play.attr 'disabled', 'disabled'
    @btn_stop.attr 'disabled', 'disabled'
    @btn_pause.attr 'disabled', 'disabled'

    @enable_actions()

  disable_actions: =>
    @actions.find('.btn').attr 'disabled', 'disabled'
    @actions.find('input').attr 'disabled', 'disabled'

  enable_actions: =>
    @actions.find('.btn').attr 'disabled', false
    @actions.find('input').attr 'disabled', false

  select_field_to_create_index: (e) =>
    @selected_field = $(e.target).html()
    @menu_text = @el.find(".txt")
    @menu_text.html "Index on #{@selected_field}"

  create_index: =>
    return if @create_index_btn.attr 'disabled'
    return unless @selected_field
    $.getJSON "#{base_uri}/create_index/#{@schema.name}/#{@selected_field}", (json) =>
      @schema.task = json
      @task_init()
    @selected_field = null
    @menu_text = 'Select property'
        
  remove_index: =>
    return if @remove_index_btn.attr 'disabled'
    return unless @remove_index_property_field.val()

    $.getJSON "#{base_uri}/remove_index/#{@schema.name}/#{@remove_index_property_field.val()}", (json) =>
      @schema.task = json
      @task_init()
    @remove_index_property_field.val ''

  remove_property: =>
    return if @remove_property_btn.attr 'disabled'
    return unless @remove_property_field.val()

    $.getJSON "#{base_uri}/remove_property/#{@schema.name}/#{@remove_property_field.val()}", (json) =>
      @schema.task = json
      @task_init()
    @remove_property_field.val ''

  task_resume: =>
    return if @btn_play.attr 'disabled'
    return unless @schema.task.id
    $.getJSON "#{base_uri}/task/resume/#{@schema.task.id}", (json) =>
      @noprogress.css 'display', 'none'
      @progress.css 'display', 'block'

      @progress_container.removeClass 'paused'

      @btn_play.css 'display', 'none'
      @btn_pause.css 'display', 'inline-block'
      @btn_stop.css 'display', 'inline-block'

      @disable_actions()

  task_stop: =>
    return if @btn_stop.attr 'disabled'
    return unless @schema.task.id
    $.getJSON "#{base_uri}/task/stop/#{@schema.task.id}", (json) =>
      @progress.css 'display', 'none'
      @noprogress.css 'display', 'block'

      @progress_container.removeClass 'paused'

      @btn_play.css 'display', 'none'
      @btn_pause.css 'display', 'inline-block'
      @btn_stop.css 'display', 'inline-block'

      @task_done()

  task_pause: =>
    return if @btn_pause.attr 'disabled'
    return unless @schema.task.id
    $.getJSON "#{base_uri}/task/pause/#{@schema.task.id}", (json) =>
      @noprogress.css 'display', 'none'
      @progress.css 'display', 'block'

      @task_status.html 'paused'
      @progress_container.addClass 'paused'

      @btn_pause.css 'display', 'none'
      @btn_play.css 'display', 'inline-block'
      @btn_stop.css 'display', 'inline-block'

      @enable_actions()

  task_dump: =>
    return if @btn_dump.attr 'disabled'
    return unless @schema.task.id
    page = window.open "#{base_uri}/task/dump/#{@schema.task.id}"
    page.document.title = "Task Dump - #{@schema.task.id}"


  duration: (time) ->
    time = parseInt(time)
    return "--:--:--" unless time > 0

    duration = ""
    time = Math.floor time / 1000

    days = Math.floor time / 86400
    time -= days * 86400
    hours = Math.floor time / 3600
    time -= hours * 3600
    mins = Math.floor time / 60
    time -= mins * 60
    secs = time % 60

    hours = "0#{hours}" if hours.toString().length is 1
    mins = "0#{mins}" if mins.toString().length is 1
    secs = "0#{secs}" if secs.toString().length is 1

    duration += "#{days}:" if days > 0
    duration += "#{hours}:#{mins}:#{secs}"
    duration

  render: =>
    @html @template('schema') schema: @schema, duration: @duration

    if @schema.task.id
      @progress_report(@schema.task.progress)
      @task_pause() if @schema.task.status is 'paused'
      @disable_actions()
    @

@app.exports['module schema'] = Schema
