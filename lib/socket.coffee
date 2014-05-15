_ = require 'lodash'

io = exports.io = null
app = null

options =
  path: ''
  script: '/init_socket.js'
  resource: 'socket.io'

init_script = (resource) -> """
  var socket = null;
  (function(){
    var script = document.createElement('script');
    script.src = "/#{resource}/socket.io.js";
    document.getElementsByTagName('head')[0].appendChild(script);
    script.onload = function() {
      socket = io.connect("", {resource: "#{resource}"});
      if (typeof(init_socket) == 'function') {
        socket.on('connect', init_socket.bind(window));
      }
    }
  })();
"""

exports.bind = (_app, _options) ->
  app = _app
  options = _.extend options, _options
  exports

exports.use = (_io, callback) ->
  io = exports.io = _io
  configure callback

exports.listen = (server, callback) ->
  throw new Error 'no app no fun' unless app
  options.path = app.path() unless options.path
  options.resource = "#{options.path}/#{options.resource}" if options.path

  io = exports.io = require('socket.io').listen server
  io.enable 'browser client minification'
  io.enable 'browser client cache'
  io.enable 'browser client etag'
  io.enable 'browser client gzip'
  io.set 'log level', 1
  io.set 'resource', options.resource
  configure callback

configure = (callback) ->
  throw new Error 'no app no fun' unless app
  client_resource = "#{options.resource.replace(/^\//, '')}"

  app.get options.script, (req, res) ->
    res.type "text/javascript"
    res.send init_script(client_resource)

  io.on 'connection', (socket) ->

    socket.join options.path
    socket.on 'new task', (data) ->
      socket.emit 'ack', data

  callback? io

