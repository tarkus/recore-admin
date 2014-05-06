class Schema extends Spine.Model

  @configure "Schema", "name", "id_generator", "properties"
  @extend Spine.Model.Ajax

  @url: "/schema"

@app.exports["model schema"] = Schema

