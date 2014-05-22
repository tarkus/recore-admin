Recore = null

exports.setRecore = (recore) -> Recore = recore

exports.key_finder = (req, res) ->
  key = req.body.key
  return res.send 400 unless key
  
  if Recore.getClient().shardable
    node = Recore.getClient().nodeFor? key
  else
    node = Recore.getClient()

  res.send node
  
exports.collection_loader = (req, res) ->
  model_name = req.query.model
  key = req.query.key
  return res.send 400 unless key and model_name

  model = Recore.getModel model_name

  return res.send 404 unless model

  collection = model.collection key

  return res.send 404 unless collection

  require('./schemas').format_schema collection
    .success (data) ->
      res.app.locals.models[model_name] = data
      res.send data
    .error -> res.send 500
