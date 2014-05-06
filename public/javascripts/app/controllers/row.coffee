class Row extends Spine.Controller

  constructor: (record: @record) ->
    super
    @render()

  render: =>
    @html @template('row') record: @record
    @

@app.exports['module row'] = Row
