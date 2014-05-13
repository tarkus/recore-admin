class Flash extends Spine.Controller

  constructor: (@type, @message, @ttl) ->
    super
    @render()
    setTimeout @destroy, 3000 unless @ttl < 0

  destroy: =>
    @el.fadeOut 'slow', =>
      @el.remove()

  render: =>
    @replace @template('flash')
      type: @type
      message: @message
    $('body').append @el
    @

@app.exports['module flash'] = Flash
