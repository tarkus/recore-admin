Header     = @app.require 'module header'
Footer     = @app.require 'module footer'
Sidebar    = @app.require 'module sidebar'

Dashboard  = @app.require 'scene dashboard'
Schema     = @app.require 'scene schema'
Record     = @app.require 'scene record'
KeyFinder  = @app.require 'scene key finder'

class Stage extends Spine.Stack
  className: "stage"

  controllers:
    dashboard: Dashboard
    record: Record
    schema: Schema
    key_finder: KeyFinder

  constructor: ->
    @el = $("<div id='page-wrapper'/>").addClass(@className).appendTo($("#wrapper")) unless @el?
    @footer = new Footer
    @footer.render()

    super
    
  #default: 'dashboard'
  
class RecoreAdmin extends Spine.Controller
  className: "app"
  
  constructor: ->
    super

    @header  = new Header
    @sidebar = new Sidebar

    @append @header.render()
    @append @sidebar.render()

    @stage = new Stage
    @setStack @stage

    @routes
      "/key_finder": =>
        @stage.key_finder.active()

      "/schema/:name": (params) =>
        @stage.schema.configure(params.name)

      "/record/:name": (params) =>
        @stage.record.configure(params.name)

      "/record/:name/page/:page": (params) =>
        @stage.record.configure(params.name, params.page)

      "/record/:name/add": (params) =>
        @stage.record.add(params.name)

      "/record/:name/view/:id": (params) =>
        @stage.record.view(params.name, params.id)

      "/record/:name/edit/:id": (params) =>
        @stage.record.edit(params.name, params.id)

      "/record/:name/delete/:id": (params) =>
        @stage.record.delete(params.name, params.id)

      "*any": =>
        @stage.dashboard.active()

$ ->
  app = new RecoreAdmin el: $("#wrapper")
  Spine.Route.setup()
  for model in Spine.Models
    model.url = "#{base_uri}/#{model.url}"

  window.App = app


