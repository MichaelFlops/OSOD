# Context of a simulation (covers initial run and updates)
#
# @output jQuery selector of the output element
# @fn function which includes all the code


# global object- only 1 of this (per page)
class Context

  # methods to manage the widgets
  # Create new context
  constructor: (@output, @fn) ->
    @initial = true
    @output.html ''  # clear output
    @widgets = []

  # Invoked both initially and for updates
  ensureWidget: (widgetClass, optArg) ->
    if @initial
      # The widget for this invocation has not been created yet, so do it
      widget = new widgetClass optArg
      @widgets.push widget
      @output.append widget.el # show the html
      @output.append $('<br>') # add line break
    else if @i >= @widgets.length
      throw new Exception 'Number of widgets changed during update'
    @widgets[@i++] # return widget and increment invocation count

  # Run initially or for updates ******* IMPORTANT
  # Makes this context be a global variable (for "slider" calls, etc.)
  run: ->
    @i = 0
    App.ctx = this
    try
      @fn()
    catch e
      error = $('<p style="color:red;">')
      error.text e.toString()
      @output.append error
      throw e
    finally
      App.ctx = null
      @initial = false
      if @i != @widgets.length
        throw new Exception 'Number of widgets changed during update'

# if it's the beginning, set it to blank, otherwise se to 's'
  setSection: (s) ->
    @output = s
    @output.html '' if @initial  # clear output

# Base class for all the widgets
  # all widgets render into html and can be controlled via
  # js interactions(in browser)
class Widget

  # Update widget based on arguments and return new value
  update: -> ''
    # Override in subclasses

# all classes of widget have these functions
# polymorhism

# A slider
class Slider extends Widget # inherets from widget

  constructor: (@def) ->
    @initial = true
    @el = $ '<input type="range"></input>'
      .on 'change', App.ctx.run.bind App.ctx
      .on 'mousemove', _.debounce App.ctx.run.bind(App.ctx), 100

  update: (min, max, step) ->
    @el
      .attr 'min', min
      .attr 'max', max
      .attr 'step', step
    if @initial
      @el.val @def
      @initial = false
    +@el.val()

class Label extends Widget

  constructor: ->
    @el = $ '<pre></pre>'

  update: (val) ->
    @el.html String val


class List extends Widget

  constructor: ->
    @el = $ '<table class="table table-bordered">
               <tbody><tr></tr></tbody>
             </table>'

  update: (val) ->
    row = @el.find 'tr'
    row.html ''
    for item in val
      $ '<td></td>'
        .html String item
        .appendTo row

$.jqplot.config.enablePlugins = true

class Plot extends Widget

  options: -> {}

  constructor: ->
    @el = $ '<div class="plot"></div>'

  update: (points) ->
    @el.html ''
    @el.jqplot [points], @options()

class PlotSeries extends Plot

  options: ->
    axes:
      xaxis:
        min: 1
        tickInterval: 1.0

  update: (series) ->
    super ([(+i) + 1,y] for i,y of series)

class Histogram extends PlotSeries

  options: ->
    seriesDefaults:
      pointLabels:
        show: true
      renderer: $.jqplot.BarRenderer
      rendererOptions:
        fillToZero: true
    axes:
      xaxis:
        renderer: $.jqplot.CategoryAxisRenderer

#window is whole thing plus more in DOM, but when 'run' gets called


window.slider = (min = 0, max = 1.0, step = 0.1, def) ->
  def = min if def is undefined
  App.ctx.ensureWidget(Slider, def).update min, max, step

window.print = (val = '') ->
  App.ctx.ensureWidget(Label).update val

window.list = (val = []) ->
  App.ctx.ensureWidget(List).update val

window.plot = (val = []) ->
  App.ctx.ensureWidget(Plot).update val

window.plotseries = (val = []) ->
  App.ctx.ensureWidget(PlotSeries).update val

window.histogram = (val = []) ->
  App.ctx.ensureWidget(Histogram).update val

# Run with a given update function fn
# Defining the fx
# run is set to global fx that runs the context fx
# output returns the html
window.run = (fn, output = $('#output')) -> # method for window
  ctx = new Context output, fn
  ctx.run()
