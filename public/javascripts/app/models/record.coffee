class Record extends Spine.Model
  @configure "Record", "properties", "total"
  @extend Spine.Model.Ajax

  @url: "/record"

@app.exports["model record"] = Record

