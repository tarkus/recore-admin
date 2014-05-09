class Record extends Spine.Model
  @configure "Record", "model", "properties", "total", "range"
  @extend Spine.Model.Ajax

  @url: "/record"

@app.exports["model record"] = Record
