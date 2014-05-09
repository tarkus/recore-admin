class RecordEdit extends Spine.Controller

  elements:
    ".input-group.date": "date"

  constructor: (record: @record, schema: @schema) ->
    super
    @render()

  render: =>
    @replace @template("record_edit") record: @record, schema: @schema
    @date.datepicker()
    @

@app.exports["module record edit"] = RecordEdit
