class SidebarList extends Spine.Controller

  constructor: (schema: @schema) ->
    super
    parts = @schema.name.split ":collection:"
    @title = parts.pop()
    @render()

  render: =>
    @replace @template('sidebar_list')
      name: @schema.name
      title: @title
      collection: @schema.collection
      count: @schema.count
    @

@app.exports["module sidebar list"] = SidebarList
