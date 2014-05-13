class Row extends Spine.Controller

  constructor: (record: @record, schema: @schema) ->
    super
    @render()

    @record.bind 'save', @render

  render: =>
    @replace @template('row') record: @record, schema: @schema
    @

@app.exports['module row'] = Row
