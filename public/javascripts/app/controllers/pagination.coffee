class Pagination extends Spine.Controller

  constructor: (path: @path, total: @total, current: @current, per_page: @per_page, scope: @scope) ->
    @scope ? 5
    @per_page ? 30
    @path ? "#/"
    @links = []
    @current = 1 if @current < 1

    @last = Math.ceil @total / @per_page

    @prev = if @current - 1 > 0 then "#{@path}/page/#{@current - 1}" else false
    @next = if @current + 1 <= @last then "#{@path}/page/#{@current + 1}" else false

    return @render() if @last < 1

    if @last <= @scope
      for i in @scope
        page_num = i + 1
        @links.push @link(page_num)
    else
      append_last = false
      append_more = false
      left = @current - ( Math.floor @scope / 2)
      left = 1 if left < 1
      right = left + @scope - 1
      if left > 1
        @links.push @link(1)
      if left > 2
        @links.push @link('...')
      if right < @last
        append_last = true
      if right < @last - 1
        append_more = true
      for i in [left...right]
        page_num = i
        @links.push @link(page_num)
      if append_more
        @links.push @link('...')
      if append_last
        @links.push @link(@last)

    @render()

  link: (page_num) =>
    link = text: page_num
    unless isNaN(page_num)
      link.href = "#{@path}/page/#{page_num}"
    return link

  render: =>
    @html @template("pagination")
      prev: @prev
      next: @next
      links: @links
      current: @current
      
    @

@app.exports["module pagination"] = Pagination
