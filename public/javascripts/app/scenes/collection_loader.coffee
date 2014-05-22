Schema = @app.require 'model schema'

class CollectionLoader extends Spine.Controller

  elements:
    ".select-model": "model_selection"
    "input[name='key']": "key_input"
    ".result": "result"

  events:
    "submit form": "submit"

  constructor: ->
    super
    @render()

  submit: (e) =>
    e.preventDefault()
    selected_model = encodeURIComponent @model_selection.val()
    key = @key_input.val()
    Schema.fetch url: "#{base_uri}/util/collection_loader?model=#{selected_model}&key=#{key}"

  render: ->
    @replace @template('collection_loader')()
    @

@app.exports['scene collection loader'] = CollectionLoader
