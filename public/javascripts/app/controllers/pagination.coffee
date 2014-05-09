class Pagination extends Spine.Controller

  constructor: (path: @path, total: @total, current: @current, per_page: @per_page, scope: @scope) ->
    super
    @scope ?= 2
    @per_page ?= 30
    @path ?= "#/"
    @links = []
    @current = 1 if @current < 1

    @max = Math.ceil @total / @per_page
    return @render() unless @max > 1

    @prev = if @current > 1 then "#{@path}/page/#{@current - 1}" else false
    @next = if @current < @max then "#{@path}/page/#{@current + 1}" else false

    if @max <= @scope
      for page_num in [1..@scope]
        @links.push @link(page_num)
        break if page_num is @max
      return @render()

    append_last = false
    append_more = false
    left = @current - ( Math.floor @scope / 2)
    left = 1 if left < 1
    right = left + @scope - 1
    @links.push @link(1) if left > 1
    @links.push @link('...') if left > 2
    append_last = true if right < @max
    append_more = true if right < @max - 1
    @links.push @link(page_num) for page_num in [left..right]
    @links.push @link('...') if append_more
    @links.push @link(@max) if append_last
    @render()

  link: (page_num) =>
    link = text: page_num
    unless isNaN(page_num)
      link.href = "#{@path}/page/#{page_num}"
    return link

  render: =>
    @replace @template("pagination")
      max: @max
      prev: @prev
      next: @next
      links: @links
      current: @current
    @

@app.exports["module pagination"] = Pagination
