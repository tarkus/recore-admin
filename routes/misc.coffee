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
  
