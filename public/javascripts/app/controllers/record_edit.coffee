class RecordEdit extends Spine.Controller

  elements:
    "form": "form"
    ".input-group.date": "date"
    ".alert-danger": "form_error"

  constructor: (record: @record, schema: @schema, modal: @modal) ->
    super
    @render()

    @record.bind 'ajaxError', @error
    @record.bind 'ajaxSuccess', @saved

    @modal.find(".modal-title").html "Editing #{@schema.name} ##{@record.id}"
    @modal.find('.btn-default').css('display', 'inline-block').html "Cancel"
    @modal.find('.btn-primary').css('display', 'inline-block').html "Save"
    @modal.find(".modal-body").html @el
    @modal.data 'action', 'update'
    @modal.modal 'show'

  error: (record, xhr, statusText, error) =>
    return unless xhr.status is 400
    error_fields = record.report_error xhr.responseJSON
    for field, errors of error_fields
      field_group = @form.find(".field-group-#{field}")
      field_group.addClass 'has-error'
      for error in errors
        @form_error.append $("<p/>").html "<strong>#{field}</strong> #{error}"
    @form_error.css 'display', 'block'
    @modal.scrollTop 0 if error_fields.length > 0

  saved: =>
    $(".record-id.selected").removeClass 'selected'
    @modal.modal 'hide'
    @navigate "/record/#{@schema.name}/page/#{@stack.record.page}"
    Flash = app.require 'module flash'
    flash = new Flash "success", "#{@schema.name} id ##{@record.id} has been successfully saved"

  submit: =>
    fields = @form.serializeArray()
    properties = {}
    for field in fields
      properties[field.name] = field.value

    @record.updateAttributes
      model: @schema.name
      properties: properties
    , url: "#{base_uri}/record/#{@schema.name}"

  render: =>
    @replace @template("record_edit") record: @record, schema: @schema
    @date.datepicker()
    @

@app.exports["module record edit"] = RecordEdit
