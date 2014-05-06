class Empty extends Spine.Controller

  constructor: ->
    @render

  render: =>
    @html @template("empty")()
    @

@app.exports["module empty"] = Empty
