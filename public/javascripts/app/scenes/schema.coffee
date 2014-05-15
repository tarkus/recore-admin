SchemaModel = @app.require 'model schema'
SchemaController = @app.require 'module schema'

class Schema extends Spine.Controller

  elements:
    ".schema-view": "schema_view"
    ".page-header": "title"

  constructor: ->
    super
    @render()

    SchemaModel.bind 'refresh', @createSchemas

  configure: (@model) ->
    @stack.swap.scene = 'schema'
    @title.html @model
    SchemaModel.fetch url: "#{base_uri}/schema/#{@model}"
    @active()

  createSchemas: (schemas) =>
    return unless @stack.swap.scene is 'schema'
    @schema = schemas.pop()
    view = new SchemaController schema: @schema
    @schema_view.html view.el

  render: =>
    @replace @template("schema_scene")()
    @

@app.exports['scene schema'] = Schema
