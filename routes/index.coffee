exports.use = (recore) ->
  exports.schemas     = (require './schemas') recore
  exports.records     = (require './records') recore
  exports.operations  = (require './operations') recore
  exports.stats       = (require './stats') recore
  exports.tasks       = (require './tasks') recore
  exports.misc        = (require './misc') recore
  


