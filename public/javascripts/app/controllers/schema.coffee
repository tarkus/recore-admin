class Schema extends Spine.Controller

  elements:
    ".modal": "modal"

  events:
    "click .function": "detail"

  constructor: (schema: @schema) ->
    super
    @render()

  detail: (e) =>
    target = $(e.target)
    @modal.find(".modal-title").html target.data('title')
    @modal.find(".content").html target.data('content')
    @modal.modal 'show'

  render: =>
    @html @template('schema') schema: @schema
    @

@app.exports['module schema'] = Schema
