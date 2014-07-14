url          = require 'url'

module.exports = (recore) ->

  index: (req, res) ->
    stats = []
    redism = recore.getClient()
    nodes = redism.client_list.length
    server_list = Object.keys(redism.server_list)
    servers = server_list.length

    stats.push
      name: 'Nodes'
      group: '2'
      content:
        nodes: nodes
        servers: servers

    unless req.query.node
      random_index = Math.floor(Math.random() * (servers - 1))
      node = server_list[random_index]
    else
      node = req.query.node
      node = "redis://#{node}" unless node.indexOf('redis://') is 0

    selected_client = redism.clients[node]
    return res.send 404 unless selected_client

    selected_client.info (err, raw) ->
      return res.send 500 if err
      serverparts = url.parse(node)
      keys = 0
      info = {}
      _info = {}
      rows = raw.match /(\w+):(.*)/g
      for row in rows
        [key, value] = row.split(":")
        if key.match /db(\d+)/
          keys += parseInt(value.split(',')[0].split("=")[1])
        _info[key] = value

      info['Keys'] = keys
      info['Memory Used'] = _info['used_memory_human']
      info['Memory Peak'] = _info['used_memory_peak_human']
      info['Connections'] = _info['connected_clients']
      info['Uptime'] = "#{_info['uptime_in_days']} days"
      info['AOF Status'] = _info['aof_last_write_status']
      info['RDB Status'] = _info['rdb_last_bgsave_status']
      info['Redis Version'] = _info['redis_version']

      stats.push
        name: "Info of #{serverparts.host}"
        group: '2'
        content: info

      selected_client.slowlog 'get', 10, (err, slowlogs) ->
        return res.send 500 if err
        logs = []
        for log in slowlogs
          logs.push
            date: new Date(log[1] * 1000).toISOString()
            time: "#{log[2] / 1000}ms"
            command: log[3].join(" ")

        stats.push
          name: "Slowlogs from #{serverparts.host}"
          size: 2
          group: 1
          content: logs

        res.send stats

  node: (req, res) ->
    res.send 200
