// Generated by CoffeeScript 1.9.1
var code, converter, diskOutdated, download, filePicker, hideCode, hideCodeButton, load, load2, markdown, outputarea, possiblyUpdate, renderOutdated, save, showCode, showCodeButton, textarea;

diskOutdated = false;

renderOutdated = true;

converter = new Markdown.Converter();

markdown = function(s) {
  return converter.makeHtml(s);
};

code = "\nThe **gravitational force** will accelerate an object starting at a certain\nheight.\n\nGravity (0-10, Earth surface would be about 9.81):\n\n    var gravity = slider(0, 10, 0.1, 1.5);\n\nStarting Height (0-100m):\n\n    var start = slider(0, 100, 1, 100);\n\nUpon hitting the ground, a portion of the *kinetic energy* will be lost, so a\n*bouncing ball* will be jump back up with less velocity than before.\n\nBounce factor (0.0 - 1.0):\n\n    var bounce = slider(0, 1, 0.1, 0.8);\n\nAdditionally, drag in term of *air resistance/friction* will also slow down the\nobj.  The amount of drag affecting an object is usually linear with its\nvelocity which caps the acceleration due to graviation at a certain **terminal\nvelocity**.\n\nDrag (0-10%):\n\n    var drag = 1 - slider(0, 0.1, 0.0001, 0);\n\n### Simulation\n\n    var height = [], velocity = [], v = 0, h = start;\n    for (var i = 0; i < 100; i++) {\n      v -= gravity;\n        v *= drag;\n        h += v;\n        if (h < 0) { v = -v * bounce; h = 0; }\n        velocity.push(Math.abs(v));\n        height.push(h);\n    }\n\nPlotting the height of the bouncing ball over time looks like a series of\ninverted parables:\n\n    plotseries(height);\n\nBy plotting the velocity, it is possible to understand the effects of\ngravitation and drag on the momentum:\n\n    plotseries(velocity);";

textarea = void 0;

outputarea = void 0;

showCodeButton = void 0;

hideCodeButton = void 0;

filePicker = void 0;

window.addEventListener('beforeunload', function(e) {
  if (diskOutdated) {
    return e.returnValue = 'Are you sure you want to leave this page?';
  }
});

window.App = {
  init: function() {
    textarea = CodeMirror($('#source .panel-body').get(0), {
      value: code,
      mode: 'markdown',
      indentUnit: 4
    });
    outputarea = $('#output');
    showCodeButton = $('#showCodeButton');
    hideCodeButton = $('#hideCodeButton');
    showCodeButton.click(showCode);
    hideCodeButton.click(hideCode);
    $('#loadButton').click(load);
    filePicker = $('#filePicker');
    filePicker.on('change', load2);
    $('#saveButton').click(save);
    setInterval(possiblyUpdate, 2000);
    return $("#vimmode").on("change", function() {
      console.log($("#vimmode").is(":checked"));
      return textarea.setOption('vimMode', $("#vimmode").is(":checked"));
    });
  }
};

possiblyUpdate = function() {
  var all_js, e, error, f, i, js, jsa, len, md, n;
  if (code !== textarea.getValue()) {
    diskOutdated = true;
    renderOutdated = true;
  }
  code = textarea.getValue();
  if (!renderOutdated) {
    return;
  }
  renderOutdated = false;
  md = markdown(code);
  outputarea.find('.output').html(md);
  jsa = [];
  n = 0;
  $('#output .output code').parent('pre').replaceWith(function() {
    var replacement;
    jsa.push($(this).children().text());
    replacement = $('<div class="widget">');
    replacement.attr('id', 'js' + (n++));
    return replacement;
  });
  if (jsa.length === 0) {
    return;
  }
  all_js = '';
  for (n = i = 0, len = jsa.length; i < len; n = ++i) {
    js = jsa[n];
    all_js += js;
    all_js += ';App.ctx.setSection($("#js' + (n + 1) + '"));';
  }
  try {
    f = eval('(function() {' + all_js + '})');
  } catch (_error) {
    e = _error;
    error = $('<p style="color:red;">');
    error.text(e.toString());
    $('#js0').append(error);
    return;
  }
  if (jsa.length > 0) {
    return run(f, $('#js0'));
  }
};

hideCode = function() {
  $('#source').fadeOut(function() {
    outputarea.removeClass('col-xs-6');
    return outputarea.addClass('col-xs-12');
  });
  return showCodeButton.fadeIn();
};

showCode = function() {
  outputarea.removeClass('col-xs-12');
  outputarea.addClass('col-xs-6');
  $('#source').fadeIn();
  return showCodeButton.fadeOut();
};

load = function() {
  if (diskOutdated) {
    if (!window.confirm('Are you sure you want to load a new file without' + 'saving this one first?')) {
      return;
    }
  }
  return filePicker[0].click();
};

load2 = function() {
  var file, reader;
  file = filePicker[0].files[0];
  if (file === void 0) {
    console.log('file is undefined');
    return;
  }
  reader = new FileReader();
  reader.onload = function(_) {
    if (reader.result === void 0) {
      console.log('file contents are undefined');
      return;
    }
    code = reader.result;
    textarea.setValue(reader.result);
    diskOutdated = false;
    return renderOutdated = true;
  };
  return reader.readAsText(file);
};

save = function() {
  console.log('attempting to save');
  return download('file.ctm', textarea.getValue());
};

download = function(filename, text) {
  var a;
  a = $('<a>');
  a.attr({
    href: 'data:text/plain;charset=utf-8,' + encodeURIComponent(text),
    download: filename
  });
  a.appendTo($('body'));
  a[0].click();
  a.remove();
  return diskOutdated = false;
};
