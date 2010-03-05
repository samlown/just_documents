// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$.commentActions = {

  bindings: function() {
    $('.comments.form button[type=submit]').live('click', function() {
      $.commentActions.save($(this).parents('form'));
      return false;
    });
    // Admin actions:
    $('form.commentActions button[type=submit]').live('click', function() {
      $.commentActions.save($(this).parents('form'));
      return false;
    });
    $('form.commentDestroy button[type=submit]').live('click', function() {
      if (confirm($(this).attr('data-msg'))) {
        $.commentActions.destroy($(this).parents('form'));
      }
      return false;
    });
  },

  // Save the form using AJAX
  save: function(form, options) {
    $.commentActions.spinner.start(form);
    form.ajaxSubmit({
      dataType: 'json',
      success: function(result) {
        $.commentActions.spinner.stop(form);
        if (result.msg) alert(result.msg);
        if (result.state == 'win') {
          if (result.view) {
            if ($('#'+result.id).length > 0) { 
              $('#'+result.id).replaceWith(result.view);
            } else {
              $('section.comments').append(result.view); 
              window.location.hash = '#'+result.id; // jump to the new comment
            }
            // window.location.hash = '#'+result.id;
          } 
          form.find('textarea').val(''); // clean the form
        }
      }
    });
  },

  destroy: function(form) {
    form.ajaxSubmit({
      dataType: 'json',
      success: function(result) {
        if (result.state == 'win') {
          form.parents('.comment').remove(); 
        } else {
          alert(result.msg);
        }
      }
    });
  },

  spinner: {
    start: function(form) {
      form.find('.actions button').hide().siblings('.spinner').show();
    },
    stop: function(form) {
      form.find('.actions .spinner').hide().siblings('button').show();
    }
  }

};


$.stdDialog = {

  bindings: function() {
    // Bind to generic dialog link (not live!)
    $('a.dialogLink, a[data-dialog]').live('click', function() {
      $.stdDialog.show($(this).attr('data-title'));
      $.get($(this).attr('href'), '', function(result) {
        $.stdDialog.html(result.view);
      }, 'json');
      return false;
    });

    $('#dialog form').live('submit', function() {
      $.stdDialog.submit($(this)); return false;
    });
  },

  show: function(title, contents, options) {
    options = $.extend({
      closeOnEscape: false,
      title: title,
      modal: true, draggable: true,
      resizable: false,
      position: ['center', 20],
      width: 750, height: ($(window).height() - 50),
      dialogClass: 'simple',
      close: function() {
        var form = $('#dialog form');
        if (form.hasClass('dirty')) {
          if (form.data('redirectOnClose'))
            window.location = form.data('redirectOnClose');
          else
            window.location.reload();
        } else {
          $('html,body').smoothScrollBack('stop');
          $('#dialog').dialog('destroy');
        }
      }
    }, options);
    $('html,body').smoothScrollBack();
    if (!contents || contents == '')
      this.loading();
    else
      $('#dialog').html(contents);
    $('#dialog').dialog(options).dialog('open');
  },

  loading: function() {
    $('#dialog').children().hide().after($('#dialogSpinner').clone().show());
  },
  // If there was an error loading, return the dialog back to how it was.
  loadingFailed: function() {
    $('#dialog').find('#dialogSpinner').remove();
    $('#dialog').children().show();
  },

  html: function(contents) {
    if (contents) {
      $('#dialog').html(contents);
      $('#dialog form .markItUp').markItUp(mySettings);
      $('#dialog input:visible:first').focus();
   } else {
      return $('#dialog').html();
    }
  },

  hide: function() {
    $('html,body').smoothScrollBack('stop');
    $('#dialog').dialog('close');
  },

  submit: function(form, options) {
    options = $.extend({
      success: function(result) {
        if (result.view) {
          $.stdDialog.html(result.view);
        } else {
          window.location.reload();
        }
      },
      failure: function(result) {
        if (result.msg) alert(result.msg);
          $.stdDialog.html(result.view);
      },
      error: function() {
        // Setup ajax error handling
        $.stdDialog.loadingFailed();
         alert('Unable to load page, check connection and try again!');
      },
      extraParams: null  // in format: [ name: "foo", value: "bar" ]
    }, options);

    // Do we need to include extra parameters? (button press details perhaps?)
    var beforeSubmit = null;
    if (options.extraParams) {
      beforeSubmit = function(a) {
        $.each(options.extraParams, function(i, item) {
          a.push(item);
        });
        return true;
      }
    }

    var hasFiles = form.find('input[type=file]').length > 0;
    $.stdDialog.loading();
    form.ajaxSubmit({
      iframe: hasFiles,
      dataType: 'json',
      beforeSubmit: beforeSubmit, 
      error: options.error,
      success: function(result) {
        if (result.state == 'win') {
          options.success(result);
        } else {
          options.failure(result);
        }
      }
    });
  }
}

$.fn.smoothScrollBack = function(command) {
  switch(command) {
    case "stop":
      $.smoothScrollBack.stop(this);
      break;
    default:
      $.smoothScrollBack.start(this);
  }
  return this;
};
$.smoothScrollBack = {
  target: null,
  top: 0,
  interval: null,
  semaphore: false,

  start: function(target) {
    var obj = this;
    obj.target = target;
    obj.top = $(window).scrollTop();
    obj.interval = setInterval(function() {
      var obj = $.smoothScrollBack;
      if (!obj.semaphore && (obj.top != $(window).scrollTop())) {
        obj.semaphore = true;
        setTimeout(function() {
          var obj = $.smoothScrollBack;
          obj.target.animate({scrollTop: obj.top}, 250, '', function() {
              setTimeout("$.smoothScrollBack.semaphore = false", 250);});
            }, 150);
          }
        }, 100);
   
  },
  stop: function(target) {
    clearInterval(this.interval);
    this.target = null;
  }
};


$(document).ready(function() {

  $.stdDialog.bindings(); // This should always be first!
  $.commentActions.bindings();

  $('a[data-confirm]').live('click', function() {
    if (confirm($(this).attr('data-confirm'))) {
      return true;
    } else {
      return false;
    }
  });

});
