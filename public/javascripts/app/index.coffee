Header     = @app.require 'module header'
Footer     = @app.require 'module footer'
Sidebar    = @app.require 'module sidebar'

Dashboard  = @app.require 'scene dashboard'
Schema     = @app.require 'scene schema'
Record     = @app.require 'scene record'

class Stage extends Spine.Stack
  className: "stage"

  controllers:
    dashboard: Dashboard
    record: Record
    schema: Schema

  constructor: ->
    @el = $("<div id='page-wrapper'/>").addClass(@className).appendTo($("#wrapper")) unless @el?
    @footer = new Footer
    @footer.render()

    super
    
  #default: 'home'
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
      "/schema/:name": (params) =>
        @stage.schema.configure(params.name)

      "/record/:name": (params) =>
        @stage.record.configure(params.name)

      "/record/:name/page/:page": (params) =>
        @stage.record.configure(params.name, params.page)

      "/": =>
        @stage.dashboard.active()

      "/(.*)": =>
        @stage.dashboard.active()

$ ->
  moment.lang("zh-cn") if moment

  app = new RecoreAdmin el: $("#wrapper")
  Spine.Route.setup()

  window.App = app


