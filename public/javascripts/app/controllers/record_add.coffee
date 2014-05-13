Record = @app.require 'model record'

class RecordAdd extends Spine.Controller

  elements:
    "form": "form"
    ".alert-danger": "form_error"
    ".input-group.date": "date"

  constructor: (schema: @schema, record: @record, modal: @modal) ->
    super
    @record ?= new Record
    @render()

    @record.bind 'ajaxError', @error
    @record.bind 'ajaxSuccess', @saved

    @modal.find(".modal-title").html "Adding new #{@schema.name}"
    @modal.find('.btn-default').css('display', 'inline-block').html "Cancel"
    @modal.find('.btn-primary').css('display', 'inline-block').html "Save"
    @modal.find(".modal-body").html @el
    @modal.data 'action', 'create'
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
    @modal.modal 'hide'
    @navigate "/record/#{@schema.name}/page/#{@stack.record.page}"

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
    @replace @template("record_add") record: @record, schema: @schema
    @date.datepicker()
    @

@app.exports["module record add"] = RecordAdd
