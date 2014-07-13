Task   = require '../lib/task'

module.exports = (recore) ->

  stop: (req, res) ->
    results = []
    task_id = req.params.id

    ids = if task_id is 'all' then Object.keys Task.all() else [task_id]

    for id in ids
      Task.find(id)?.destroy()
      results.push id

    res.send count: results.length

  pause: (req, res) ->
    results = []
    task_id = req.params.id

    ids = if task_id is 'all' then Object.keys(Task.all()) else [task_id]

    for id in ids
      Task.find(id)?.status 'paused'
      results.push id

    res.send count: results.length

  resume: (req, res) ->
    results = []
    task_id = req.params.id

    ids = if task_id is 'all' then Object.keys Task.all() else [task_id]

    for id in ids
      Task.find(id)?.status 'running'
      results.push id

    res.send count: results.length

  dump: (req, res) ->
    if req.params.id is 'all'
      tasks = {}
      res.type 'text/plain'
      tasks[id] = task.dump() for id, task of Task.all()
      return res.send JSON.stringify tasks, null, '\t'
    else
      task = Task.find req.params.id
      return res.send 404 unless task

    res.type 'text/plain'
    return res.send JSON.stringify task.dump(), null, '\t'

