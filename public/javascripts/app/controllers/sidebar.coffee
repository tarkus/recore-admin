SchemaModel = @app.require 'model schema'

class Sidebar extends Spine.Controller
  className: "sidebar"

  elements:
    ".model-list": 'model_list'
    ".collection-list": 'collection_list'

  constructor: ->
    super
    @subview = window.app.require 'module sidebar list'
    @render()

    SchemaModel.bind 'refresh', @update_count

  update_count: (schemas) =>
    for schema in schemas
      if document.getElementById("count-#{schema.name}")
        document.getElementById("count-#{schema.name}").innerHTML = schema.count
        window.models[schema.name] = schema
      else
        @createList schema

  createList: (schema) =>
    view = new @subview schema: schema
    if schema.collection
      parts = schema.name.split(":collection:")
      sub = ""
      subs = []
      padding = 1
      for idx in [0..parts.length] by 2
        break unless parts[idx]
        subs.push parts[idx]
        if $(".collection-#{sub}").length is 0
          sub_div = $("<div/>").addClass "collection-#{subs.join('-')}"
          sub_div.css 'padding-left', "#{padding}em"
          sub_title = $('<h6/>').addClass("collection-title-#{subs.join('-')}").html subs.join ':'
          sub_ul = $('<ul/>').addClass "sub nav collection-list-#{subs.join('-')}"
          sub_ul.append view.el
          sub_div.append sub_title, sub_ul
          @collection_list.append sub_div
        else
          $(".collection-list-#{subs.join('-')}").append view.el
        padding = padding * 2
    else
      @model_list.append view.el

    $("#page-wrapper").height $(".navbar-static-side").height() + 60

  render: =>
    @html @template("sidebar")()
    for name, schema of window.models
      @createList schema
    @

@app.exports["module sidebar"] = Sidebar
