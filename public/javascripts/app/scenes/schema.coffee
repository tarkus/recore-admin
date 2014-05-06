SchemaModel = @app.require 'model schema'

class Schema extends Spine.Controller

  elements:
    ".modal": "modal"

  events:
    "click .function": "detail"

  constructor: ->
    super
    SchemaModel.bind 'refresh', @create

  active: (@name) ->
    SchemaModel.fetch url: "#{base_uri}/schema/#{@name}"
    super

  create: (schemas) =>
    @schema = schemas.pop()
    @render()

  detail: (e) =>
    target = $(e.target)
    @modal.find(".modal-title").html target.data('title')
    @modal.find(".content").html target.data('content')
    @modal.modal 'show'


  render: =>
    @replace @template("schema")
      schema: @schema
    @


@app.exports['module schema'] = Schema
