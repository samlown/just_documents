// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function postAndParse(form, callback) {
  $.post($(form).attr('action'), $(form).serializeArray(), function(data) {
    var result = parseJSON(data);
    callback(result);
  });
}

function parseJSON(data) {
  if (data.charAt(0) == '{') {
    return JSON.parse(data);
  } else {
    return null;
  }
}
