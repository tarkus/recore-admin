class KeyFinder extends Spine.Controller

  elements:
    "input[name='key']": "key_input"
    ".result": "result"

  events:
    "submit form": "submit"

  constructor: ->
    super
    @render()

  submit: (e) =>
    e.preventDefault()
    @result.html ''
    self = @
    $.ajax
      url: "#{base_uri}/key_finder"
      type: 'POST'
      data:
        key: @key_input.val()
      success: (result) ->
        self.result.html "<pre><code>#{result}</code></pre>"

  render: =>
    @replace @template("key_finder")()
    @
@app.exports['scene key finder'] = KeyFinder
