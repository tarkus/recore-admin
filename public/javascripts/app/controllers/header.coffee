class Header extends Spine.Controller
  className: "header"

  reload: =>
    @render()
    
  render: =>
    @html @template("header")
      title: window.title
      subtitle: window.subtitle
    @

@app.exports["module header"] = Header
