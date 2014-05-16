SchemaModel = @app.require 'model schema'

class Sidebar extends Spine.Controller
  className: "sidebar"

  constructor: ->
    super
    @render()
    SchemaModel.bind 'refresh', @update_count

  update_count: (schemas) =>
    for schema in schemas
      $(".count-#{schema.name}").html schema.count
      window.count[schema.name] = schema.count

  render: =>
    @html @template("sidebar")()
    @

@app.exports["module sidebar"] = Sidebar
