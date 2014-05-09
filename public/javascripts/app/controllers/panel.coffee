class Panel extends Spine.Controller

  constructor: (title: @title, content: @content, size: @size) ->
    super
    @size ?= 1
    @render()

  render: =>
    @replace @template("panel") size: @size, title: @title, content: @content
    @

@app.exports["module panel"] = Panel
