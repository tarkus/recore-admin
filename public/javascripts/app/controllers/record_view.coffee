class RecordView extends Spine.Controller

  events:
    "click .field-value": "select"

  constructor: (record: @record, schema: @schema, modal: @modal) ->
    super
    @render()

    @modal.find(".modal-title").html "Viewing #{@schema.name.toLowerCase()} ##{@record.id}"
    @modal.find(".modal-body").html @el
    @modal.find('.btn-default').css('display', 'inline-block').html "Close"
    @modal.find('.btn-primary').css "display", 'none'
    @modal.modal 'show'

    @modal.on 'hide.bs.modal', =>
      @navigate "/record/#{@schema.name}/page/#{@stack.record.page}"

  select: (e) =>
    selectText(e.target)

  render: =>
    @replace @template("record_view") record: @record, schema: @schema
    @

@app.exports["module record view"] = RecordView
