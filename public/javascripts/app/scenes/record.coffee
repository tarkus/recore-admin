SchemaModel = @app.require 'model schema'
RecordModel = @app.require 'model record'

Row         = @app.require 'module row'
Empty       = @app.require 'module empty'
Pagination  = @app.require 'module pagination'
RecordAdd   = @app.require 'module record add'
RecordView  = @app.require 'module record view'
RecordEdit  = @app.require 'module record edit'

class Record extends Spine.Controller

  elements:
    ".page-header": "title"
    ".modal.detail": "detail_modal"
    ".modal.action": "action_modal"
    ".panel-heading": "desc"
    ".table-responsive": "table_container"
    ".table-records": "table_records"
    ".table-records thead": "records_header"
    ".table-records tbody": "records"
    ".table-ids": "table_ids"
    ".table-ids thead": "ids_header"
    ".table-ids tbody": "ids"
    ".pagination": "pagination"
    ".btn.add": "btn_add"
    ".btn.view": "btn_view"
    ".btn.edit": "btn_edit"
    ".btn.delete": "btn_delete"

  events:
    "click .record-value": "detail"

    "click .record-id": "selectRow"
    "click .record-id.selected": "deselectRow"

    "click .modal.detail .content": "selectValue"

    "click .actions .add": "showAddModal"
    "click .actions .view": "showViewModal"
    "click .actions .edit": "showEditModal"
    "click .actions .delete": "showDeleteModal"

    "click .modal.action .btn-primary": "submit"


  constructor: ->
    super
    @render()

    @per_page ?= 30
    @sort_field ?= 'id'
    @sort_direction ?= "DESC"
    SchemaModel.bind 'refresh', @createSchemas
    RecordModel.bind 'refresh', @createRecords

  configure: (@model, @page=1) ->
    @stack.swap.scene = 'record'
    @title.html @model
    SchemaModel.fetch url: "#{base_uri}/schema/#{@model}"

    @desc.html '&nbsp;'
    @records_header.html ''
    @ids_header.html ''
    @records.html ''
    @ids.html ''
    @pagination.html ''
    @table_ids.css 'display', 'none'
    @btn_add.css 'display', 'none'
    @btn_view.css 'display', 'none'
    @btn_edit.css 'display', 'none'
    @btn_delete.css 'display', 'none'

    @active()

  createSchemas: (schemas) =>
    return unless @stack.swap.scene is 'record'
    @schema = schemas.pop()
    @fetchRecords()

  fetchRecords: =>
    RecordModel.fetch url: "#{base_uri}/record/#{@model}/page/#{@page}?per_page=#{@per_page}&direction=#{@sort_direction}"

  createRecords: (records) =>
    @btn_add.css 'display', 'inline-block'
    if records.length is 0
      empty = new Empty
      @records.html empty.el
      return

    first = records[0]
    @paginate first

    @table_ids.css 'display', 'inline-block'

    header = $("<tr/>")
    for name, value of @schema.properties
      header.append $("<th/>").html name
    @records_header.html header
    @ids_header.html "<tr><th>&nbsp;</th></tr>"

    @desc.html "Showing #{first.range[0]}-#{first.range[1]} of #{first.total}"
      
    full_width = @table_container.width()
    for record in records
      @ids.append "<tr><td class='record-id' id='id-#{record.id}'>#{record.id}</td></tr>"
      row = new Row record: record, schema: @schema
      @records.append row.el

    @table_records.width full_width - @table_ids.width() - 2

    @btn_view.addClass('disabled').css 'display', 'inline-block'
    @btn_edit.addClass('disabled').css 'display', 'inline-block'
    @btn_delete.addClass('disabled').css 'display', 'inline-block'

  paginate: (record) =>
    pagination = new Pagination
      total: record.total
      current: @page
      per_page: @per_page
      path: "#/record/#{@model}"
    @pagination.html pagination.el

  showViewModal: =>
    @record = RecordModel.find @selected_id
    view = new RecordView record: @record, schema: @schema
    @action_modal.find(".modal-title").html "Viewing #{@schema.name.toLowerCase()} ##{@selected_id}"
    @action_modal.find(".modal-body").html view.el
    @action_modal.find('.btn-default').css('display', 'inline-block').html "Close"
    @action_modal.find('.btn-primary').css "display", 'none'
    @action_modal.modal 'show'

  showAddModal: =>
    @record = new RecordModel
    view = new RecordAdd record: @record, schema: @schema
    @action_modal.find(".modal-title").html "Adding new #{@schema.name.toLowerCase()} object"
    @action_modal.find('.btn-default').css('display', 'inline-block').html "Cancel"
    @action_modal.find('.btn-primary').css('display', 'inline-block').html "Save"
    @action_modal.find(".modal-body").html view.el
    @action_modal.modal 'show'
    @action_modal.data 'action', 'create'

  showEditModal: =>
    @record = RecordModel.find @selected_id
    view = new RecordEdit record: @record, schema: @schema
    @action_modal.find(".modal-title").html "Editing #{@schema.name.toLowerCase()} ##{@selected_id}"
    @action_modal.find('.btn-default').css('display', 'inline-block').html "Cancel"
    @action_modal.find('.btn-primary').css('display', 'inline-block').html "Save"
    @action_modal.find(".modal-body").html view.el
    @action_modal.modal 'show'
    @action_modal.data 'action', 'update'

  showDeleteModal: =>
    @action_modal.find(".modal-title").html "Deleting #{@schema.name.toLowerCase()} ##{@selected_id}"
    @action_modal.find('.btn-default').css('display', 'inline-block').html "Cancel"
    @action_modal.find('.btn-primary').css('display', 'inline-block').html "Confirm"
    @action_modal.find('.modal-body').html """
      Please confirm deleting a #{@schema.name.toLowerCase()} object with id = <code>#{@selected_id}</code>
    """
    @action_modal.find('.btn-primary').on 'click', =>
      @record.destroy()
    @action_modal.modal 'show'
    @action_modal.data 'action', 'delete'

  submit: =>
    if @action_modal.data('action') is 'delete'
      return
    else
      fields = @action_modal.find('form').serializeArray()
      properties = {}
      for field in fields
        properties[field.name] = field.value

      @record.updateAttributes
        model: @schema.name
        properties: properties

      @record.update url: "#{base_uri}/record"

  detail: (e) =>
    target = $(e.target)
    @detail_modal.find(".modal-title").html target.data('title')
    @detail_modal.find(".content").html target.data('content')
    @detail_modal.modal 'show'

  selectRow: (e) =>
    if @selected_id
      $("#id-#{@selected_id}").removeClass 'selected'
      $("#record-id-#{@selected_id}").removeClass 'selected'

    id_cell = $(e.target)
    @selected_id = id = id_cell.html()

    id_cell.addClass 'selected'
    $("#record-id-#{id}").addClass 'selected'

    @btn_view.removeClass 'disabled'
    @btn_edit.removeClass 'disabled'
    @btn_delete.removeClass 'disabled'

  deselectRow: (e) =>
    @selected_id = null
    id_cell = $(e.target)
    id = id_cell.html()
    id_cell.removeClass 'selected'
    $("#record-id-#{id}").removeClass 'selected'

    @btn_view.addClass 'disabled'
    @btn_edit.addClass 'disabled'
    @btn_delete.addClass 'disabled'
    
  selectValue: (e) =>
    selectText e.target

  render: =>
    @replace @template("record_scene")
      model: @model
    @action
    @

@app.exports['scene record'] = Record
