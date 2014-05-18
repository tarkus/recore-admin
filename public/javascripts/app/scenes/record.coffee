SchemaModel  = @app.require 'model schema'
RecordModel  = @app.require 'model record'

Row          = @app.require 'module row'
Empty        = @app.require 'module empty'
Pagination   = @app.require 'module pagination'

RecordAdd    = @app.require 'module record add'
RecordView   = @app.require 'module record view'
RecordEdit   = @app.require 'module record edit'
RecordDelete = @app.require 'module record delete'

class Record extends Spine.Controller

  elements:
    ".page-header": "title"
    ".modal.detail": "detail_modal"
    ".modal.action": "action_modal"
    ".panel-heading": "desc"
    ".tables": "table_container"
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

    "click .sort": "sort"

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

    @ids_header.html ''
    @records_header.html ''

    @ids.html ''
    @records.html ''

    @pagination.html ''
    
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

    @ids_header.html "<tr><th>&nbsp;</th></tr>"

    header = $("<tr/>")
    has_records = records.length > 0
    for name, value of @schema.properties
      if has_records and value.sortable
        toggler = $('<span/>').addClass 'dropdown-toggle'
        toggler.attr 'data-toggle', 'dropdown'
        toggler.attr 'id', "th-dropdown-#{name}"
        toggler.html name
        toggler.append '<span class="caret"></span>'
        dropdown = $('<ul/>').addClass 'dropdown-menu'
        dropdown.attr 'role', 'menu'
        dropdown.append "<li><a class='sort' data-dir='ASC' data-field='#{name}' href='javascript: void(0);'>Ascending</a></li>"
        dropdown.append "<li><a class='sort' data-dir='DESC' data-field='#{name}' href='javascript: void(0);'>Descending</a></li>"
        div = $("<div/>").addClass 'dropdown'
        div.append toggler
        div.append dropdown
        th = $("<th/>").append div
        header.append th
      else
        header.append $("<th/>").html name
    @records_header.html header

    if records.length is 0
      empty = new Empty
      @records.html empty.el

      @ids.append "<tr><td class='record-id-none'>&nbsp;</td></tr>"

      full_width = @table_container.width()
      @table_records.width full_width - @table_ids.width() - 2

      @[@action](@schema.name) if @action
      return

    first = records[0]
    @paginate first

    @desc.html "Showing #{first.range[0]}-#{first.range[1]} of #{first.total}" if first.range?
      
    for record in records
      @ids.append "<tr><td class='record-id' id='id-#{record.id}'>#{record.id}</td></tr>"
      row = new Row record: record, schema: @schema
      @records.append row.el

    full_width = @table_container.width()
    @table_records.width full_width - @table_ids.width() - 2

    @btn_view.addClass('disabled').css 'display', 'inline-block'
    @btn_edit.addClass('disabled').css 'display', 'inline-block'
    @btn_delete.addClass('disabled').css 'display', 'inline-block'

    @[@action](@schema.name) if @action

  paginate: (record) =>
    pager = new Pagination
      total: record.total
      current: @page
      per_page: @per_page
      path: "#/record/#{@model}"
    @pagination.html pager.el

  showAddModal: =>
    @navigate "/record/#{@schema.name}/add"

  showViewModal: =>
    @navigate "/record/#{@schema.name}/view/#{@selected_id}"

  showEditModal: =>
    @navigate "/record/#{@schema.name}/edit/#{@selected_id}"

  showDeleteModal: =>
    @navigate "/record/#{@schema.name}/delete/#{@selected_id}"

  add: (model) =>
    @action = null
    if @schema and @schema.name is model
      @record = new RecordModel
      @action_handler = new RecordAdd record: @record, schema: @schema, modal: @action_modal
    else
      @action = 'add'
      @configure model

  view: (model, id) =>
    @action = null
    @selected_id ?= id
    if @schema and @schema.name is model
      @record = RecordModel.find @selected_id
      @action_handler = new RecordView record: @record, schema: @schema, modal: @action_modal
    else
      @action = 'view'
      page = Math.floor(@selected_id / @per_page) + 1
      @configure model, page

  edit: (model, id) =>
    @action = null
    @selected_id ?= id
    @record = RecordModel.find @selected_id
    return @navigate "/record/#{model}" unless @record
    if @schema and @schema.name is model
      @action_handler = new RecordEdit record: @record, schema: @schema, modal: @action_modal
    else
      @action = 'edit'
      page = Math.floor(@selected_id / @per_page) + 1
      @configure model

  delete: (model, id) =>
    @action = null
    @selected_id ?= id
    @record = RecordModel.find @selected_id
    return @navigate "/record/#{model}" unless @record
    if @schema and @schema.name is model
      @action_handler = new RecordDelete record: @record, schema: @schema, modal: @action_modal
    else
      @action = 'delete'
      page = Math.floor(@selected_id / @per_page) + 1
      @configure model

  submit: =>
    @action_modal.find(".form-group.has-error").removeClass 'has-error'
    @action_modal.find(".alert-danger").css('display', 'none').html ""

    @action_handler?.submit?()
    
  detail: (e) =>
    e.preventDefault()
    e.stopPropagation()
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

  sort: (e) =>
    target = $(e.target)
    @sort_field = target.data 'field'
    @sort_direction = target.data 'dir'
    @configure @model


  render: =>
    @replace @template("record_scene")
      model: @model
    @

@app.exports['scene record'] = Record
