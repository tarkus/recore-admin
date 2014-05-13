class Schema extends Spine.Model

  @configure "Schema", "name", "id_generator", "properties", "sortables", "count"
  @extend Spine.Model.Ajax
  @extend Spine.ModelParty

  @url: "/schema"

@app.exports["model schema"] = Schema

