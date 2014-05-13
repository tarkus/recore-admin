class RecordDelete extends Spine.Controller

  constructor: (record: @record, schema: @schema, modal: @modal) ->
    super
    @render()
    @record.bind 'destroy', @destroy

    @modal.find(".modal-title").html "Deleting #{@schema.name.toLowerCase()} ##{@record.id}"
    @modal.find('.btn-default').css('display', 'inline-block').html "Cancel"
    @modal.find('.btn-primary').css('display', 'inline-block').html "Confirm"
    @modal.find('.modal-body').html @el
    @modal.data 'action', 'delete'
    @modal.modal 'show'

  submit: =>
    @record.destroy url: "#{base_uri}/record/#{@record.model}/#{@record.id}"

  destroy: =>
    @navigate "/record/#{@schema.name}/page/#{@stack.record.page}"
    $('.modal').modal 'hide'
    Flash = app.require 'module flash'
    flash = new Flash "info", "#{@schema.name} id ##{@record.id} has been successfully deleted"

  render: =>
    @replace @template("record_delete") record: @record, schema: @schema
    @

@app.exports["module record delete"] = RecordDelete
