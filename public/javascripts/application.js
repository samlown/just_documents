// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

/*
 * Post the provided form object using AJAX and parse the results provided as JSON.
 *
 * The following options are supported:
 *   params: Array of aditional name, value objects to append to serializeArray.
 *   
 */
function postAndParse(form, options, callback) {
  options = $.extend({params: [ ]}, options);
  options.params = options.params.concat($(form).serializeArray());
  $.post($(form).attr('action'), options.params, function(data) {
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
