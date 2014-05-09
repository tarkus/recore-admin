SchemaModel = @app.require 'model schema'

class Sidebar extends Spine.Controller
  className: "sidebar"

  reload: =>
    @render()

    SchemaModel.bind 'refresh', @updateCount

  updateCount: (schemas) ->
    for schema in schemas
      $(".count-#{schema.name}").html schema.count

  render: =>
    @html @template("sidebar")()
    @

@app.exports["module sidebar"] = Sidebar
