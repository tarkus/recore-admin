module.exports = (recore) ->

  finder: (req, res) ->
    key = req.body.key
    return res.send 400 unless key
    
    if recore.getClient().shardable
      node = recore.getClient().nodeFor? key
    else
      node = recore.getClient()

    res.send node
    
  loader: (req, res) ->
    console.log "?!?!"
    model_name = req.query.model
    key = req.query.key
    return res.send 400 unless key and model_name
  
    model = recore.getModel model_name

    return res.send 404 unless model

    collection = model.collection key

    return res.send 404 unless collection

    (require './schemas')(recore).format_schema collection
      .success (data) ->
        res.app.locals.models[model_name] = data
        res.send data
      .error -> res.send 500
