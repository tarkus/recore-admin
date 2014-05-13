Widget = @app.require 'model widget'
Panel = @app.require 'module panel'

class Dashboard extends Spine.Controller
  elements:
    ".widgets": "widgets"

  constructor: ->
    super
    @columns = 3
    @render()
    Widget.bind 'refresh', @refresh

  active: =>
    return if @stack.swap.scene is 'dashboard'
    @stack.swap.scene = 'dashboard'
    Widget.deleteAll()
    Widget.fetch url: "#{base_uri}/stats"
    @widgets.html ''
    super

  refresh: (widgets) =>
    total = widgets.length
    containers = {}
    for widget in widgets
      widget.group = 'ungrouped' unless widget.group
      widget.size ?= 1
      containers[widget.group] ?= $("<div/>").addClass "col-lg-#{Math.min(12, Math.floor(widget.size * 4))}"
      view = new Panel size: widget.size, title: widget.name, content: widget.content
      containers[widget.group].append view.el

    for group, container of containers
      @widgets.append container
    
  render: =>
    @replace @template("dashboard")()
    @

@app.exports["scene dashboard"] = Dashboard
