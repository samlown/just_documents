// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

/*
 * Send the provided form object using AJAX and parse the results provided as JSON.
 *
 * The following options are supported:
 *   params: Array of aditional name, value objects to append to serializeArray.
 *   
 */
function ajaxAndParse(form, options, callback) {
  options = $.extend({params: [], method: 'get'}, options);
  options.params = options.params.concat($(form).serializeArray());
  action = function(data) {
    var result = parseJSON(data);
    callback(result);
  }
  if (options.method == 'get') {
    $.get($(form).attr('action'), options.params, action); 
  } else if (options.method == 'post') {
    $.post($(form).attr('action'), options.params, action); 
  }
}

function postAndParse(form, options, callback) {
  options = $.extend({method: 'post'}, options);
  ajaxAndParse(form, options, callback);
}

function parseJSON(data) {
  return JSON.parse(data);
}
