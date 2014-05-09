class RecordView extends Spine.Controller

  events:
    "click .field-value": "select"

  constructor: (record: @record, schema: @schema) ->
    super
    @render()

  select: (e) =>
    selectText(e.target)

  render: =>
    @replace @template("record_view") record: @record, schema: @schema
    @

@app.exports["module record view"] = RecordView
