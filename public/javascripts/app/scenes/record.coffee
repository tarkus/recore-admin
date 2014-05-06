RecordModel = @app.require 'model record'
Empty = @app.require 'module empty'
Pagination = @app.require 'module pagination'

class Record extends Spine.Controller

  elements:
    ".modal": "modal"
    ".header": "header"
    ".rows": "rows"
    ".pager": "pager"

  events:
    "click .function": "detail"

  constructor: ->
    super
    @per_page = 30
    RecordModel.bind 'refresh', @create

  active: (@model, @page=1) ->
    RecordModel.fetch url: "#{base_uri}/record/#{@model}/page/#{@page}?per_page=#{@per_page}"
    super

  create: (records) =>
    if records.length is 0
      empty = new Empty
      return @rows.append empty.el

    @paginate records[0]

    for record in records
      row = new Row record: record
      @rows.append row.el

  paginate: (record) =>
    pager = new Pagination
      total: record.total
      current: @page
      per_page: @per_page
      path: "#{base_uri}/record/#{@model}"
    @paper.append paper.el


  detail: (e) =>
    target = $(e.target)
    @modal.find(".modal-title").html target.data('title')
    @modal.find(".content").html target.data('content')
    @modal.modal 'show'

  render: =>
    @replace @template("record")
      model: @model
    @

@app.exports['module record'] = Record
