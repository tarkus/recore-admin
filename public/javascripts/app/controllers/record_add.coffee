Record = @app.require 'model record'

class RecordAdd extends Spine.Controller

  elements:
    ".input-group.date": "date"

  constructor: (schema: @schema) ->
    super
    @record = new Record
    @render()

  render: =>
    @replace @template("record_add") record: @record, schema: @schema
    @date.datepicker()
    @

@app.exports["module record add"] = RecordAdd
