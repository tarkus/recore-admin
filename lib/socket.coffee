_ = require 'lodash'

io = exports.io = null
app = null

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

class Socket
  
  io: null
  app: null

  options:
    path: ''
    prefix: ''
    script: '/socket.js'
    resource: 'socket.io'

  constructor: (@app, options) ->
    @app = app
    @options = _.extend @options, options

  # Use a intialized socket.io instance
  use: (io, callback) ->
    @io = io
    @configure callback

  # Create a new socket.io and listen on the server
  listen: (server, callback) ->
    @options.path = @app.path() unless @options.path
    @options.resource = "#{@options.path}/#{@options.resource}" if @options.path

    # TODO
    #   Deprecated in socket.io@1.0
    @io = require('socket.io').listen server
    @io.enable 'browser client minification'
    @io.enable 'browser client cache'
    @io.enable 'browser client etag'
    @io.enable 'browser client gzip'
    @io.set 'log level', 1
    @io.set 'resource', resource

    @configure callback

  configure: (callback) ->
    throw new Error 'no app no fun' unless @app

    resource = "#{@options.resource.replace(/^\//, '')}"

    @app.get @options.script, (req, res) =>
      res.type "text/javascript"
      res.send init_script(resource)

    @io.on 'connection', (socket) =>
      socket.join @app.locals.title
      socket.on 'new task', (data) ->
        socket.emit 'ack', data

    callback? @io

module.exports = Socket
