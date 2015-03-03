# total = 0
# count = 1
# while count <= 10
#   total += count
#   count += 1
# total

# total = 0
# total += count for count in [1..10]
# console.log total


# sum = (v) -> _.reduce v, ((a,b) -> a+b), 0
# sum[1..10]
# console.log sum

# Array::sum = -> @reduce

# me = 115 * 4 - 4 + 88 / 2
# console.log me

# me = (4 >= 6 or 'grass' isnt 'green') and not(12 * 2 is 144 and true)
# console.log me

# penis = Math.max 2, 4
# console.log penis

# confirm 'shall we, then?', (answer) -> answer

# while loop that prints 1 - 100 in a new line

# i = 0
# while i <= 100
#   console.log i
#   i += 1

# prompt ' Tel'
# shit = [1..10]
# console.log shit

# [1..10].map (i) -> i*2

# EXERCISE 2
# Write a program that shows the result of 2^10 power

# count = 0
# i = 1

# runOnDemand = ->
#   while count < 10
#     i *= 2
#     count++
#   return i
# console.log runOnDemand()
# end of exercise 2

# EXERCISE 3
# Draw a triangle by printing out 10 lines, each with a new "#"
# tri = ''
# count = 0

# runOnDemand = ->
# while count < 10
#   tri = tri + "#"
#   console.log tri
#   count++
# runOnDemand()

# EXERCISE 4
# Rewrite the solutions of the prev 2 exercises to use for instead of while
# tri = '1'
# i = 0
# x = 10
# runOnDemand = ->
#   for count in [i...x]
#     tri = tri + '#'
#     console.log tri
# runOnDemand()

# for counter in [0..20]
#   if counter % 3 is 0 and counter % 4 is 0
#     console.log counter

# for counter in [0...10]
#   if counter % 4 is 0
#     console.log counter
#   if counter % 4 isnt 0
#     console.log '(' + counter + ')'

# for counter in [0..20]
#   if counter > 15
#     console.log + '**'
#   else if counter > 10
#     console.log counter + '*'
#   else
#   console.log counter
    
# EXERCISE 5
# Using prompt, ask what the value of '2 + 2' is. If the answer if '4',
#use show to say something praising. If it is '3' or '5', say 'almost!'.
# in other cases, say something mean!

prompt 'hey'





## older stuff written by chris starts

diskOutdated = false #boolean
renderOutdated = true #boolean


#converter is a constructor that creates a converter object.
#Call this object's makeHtml method to #turn Markdown into HTML:
converter = new Markdown.Converter()

markdown = (s) -> converter.makeHtml(s)

code = """

## What ctm is
Ctm is a file format for storing 3D triangle
meshes in a compact and versatile way.

#### To run locally, clone the repo and run:
`npm install`

`grunt serve`

# Understanding the code

This project primarily relies on codeMirror
to generate a text editor in the browser
## Example 1: Bouncing ball

The **gravitational force** will accelerate an object starting at a certain
height.

Gravity (0-10, Earth surface would be about 9.81):

    var gravity = slider(0, 10, 0.1, 1.5);

Starting Height (0-100m):

    var start = slider(0, 100, 1, 100);

Upon hitting the ground, a portion of the *kinetic energy* will be lost, so a
*bouncing ball* will be jump back up with less velocity than before.

Bounce factor (0.0 - 1.0):

    var bounce = slider(0, 1, 0.1, 0.8);

Additionally, drag in term of *air resistance/friction* will also slow down the
obj.  The amount of drag affecting an object is usually linear with its
velocity which caps the acceleration due to graviation at a certain **terminal
velocity**.

Drag (0-10%):

    var drag = 1 - slider(0, 0.1, 0.0001, 0);

### Simulation

    var height = [], velocity = [], v = 0, h = start;
    for (var i = 0; i < 100; i++) {
      v -= gravity;
        v *= drag;
        h += v;
        if (h < 0) { v = -v * bounce; h = 0; }
        velocity.push(Math.abs(v));
        height.push(h);
    }

Plotting the height of the bouncing ball over time looks like a series of
inverted parables:

    plotseries(height);

By plotting the velocity, it is possible to understand the effects of
gravitation and drag on the momentum:

    plotseries(velocity);"""

textarea = undefined
outputarea = undefined
showCodeButton = undefined
hideCodeButton = undefined
filePicker = undefined

window.addEventListener('beforeunload', (e) ->
  if diskOutdated
    e.returnValue = 'Are you sure you want to leave this page?'
)

window.App =
  init: ->
    textarea = CodeMirror $('#source .panel-body').get(0),
      value: code
      mode: 'markdown'
      indentUnit: 4

    outputarea = $('#output')

    showCodeButton = $('#showCodeButton')
    hideCodeButton = $('#hideCodeButton')
    showCodeButton.click(showCode)
    hideCodeButton.click(hideCode)

    $('#loadButton').click(load)
    filePicker = $('#filePicker')
    filePicker.on('change', load2)

    $('#saveButton').click(save)

    setInterval(possiblyUpdate, 2000)

    $("#vimmode").on "change", ->
      console.log $("#vimmode").is(":checked")
      textarea.setOption 'vimMode', $("#vimmode").is(":checked")

possiblyUpdate = ->
  if code != textarea.getValue()
    diskOutdated = true
    renderOutdated = true
  code = textarea.getValue()

  return if !renderOutdated

  renderOutdated = false

  md = markdown(code)
  outputarea.find('.output').html(md)
  jsa = []
  n = 0
  $('#output .output code').parent('pre').replaceWith(-> (
    jsa.push($(this).children().text())
    replacement = $('<div class="widget">')
    replacement.attr('id', 'js' + (n++))
    replacement
  ))

  if jsa.length == 0
    return

  all_js = ''
  for js,n in jsa
    all_js += js
    all_js += ';App.ctx.setSection($("#js' + (n + 1) + '"));'

  try
    f = eval('(function() {' + all_js + '})')
  catch e
    error = $('<p style="color:red;">')
    error.text(e.toString())
    $('#js0').append error
    return

  run(f, $('#js0'))  if jsa.length > 0

hideCode = ->
  $('#source').fadeOut ->
    outputarea.removeClass 'col-xs-6'
    outputarea.addClass 'col-xs-12'
  showCodeButton.fadeIn()

showCode = ->
  outputarea.removeClass 'col-xs-12'
  outputarea.addClass 'col-xs-6'
  $('#source').fadeIn()
  showCodeButton.fadeOut()

load = ->
  if diskOutdated
    if !window.confirm('Are you sure you want to load a new file without' +
                       'saving this one first?')
      return
  filePicker[0].click()

load2 = ->
  file = filePicker[0].files[0]
  if file == undefined
    console.log('file is undefined')
    return
  reader = new FileReader()
  reader.onload = (_) ->
    if reader.result == undefined
      console.log('file contents are undefined')
      return

    # Populate the text field with the new source code
    code = reader.result
    textarea.setValue(reader.result)
    diskOutdated = false
    renderOutdated = true

  reader.readAsText(file)

save = ->
  console.log('attempting to save')
  download('file.ctm', textarea.getValue())

download = (filename, text) ->
  a = $('<a>')
  a.attr
    href: 'data:text/plain;charset=utf-8,' + encodeURIComponent(text)
    download: filename
  a.appendTo($('body'))
  a[0].click()
  a.remove()
  diskOutdated = false
