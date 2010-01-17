// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function parseJSON(data) {
  return JSON.parse(data);
}

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

  redirectToUrl: null,

  bindings: function() {
    // Bind to generic dialog link (not live!)
    $('a.dialogLink, a[data-dialog]').live('click', function() {
      $.stdDialog.show($(this).attr('data-title'));
      $.get($(this).attr('href'), '', function(data) {
        var result = parseJSON(data);
        $.stdDialog.html(result.view);
      });
      return false;
    });

    $('#dialog form button[type=submit]').live('click', function() {
      var form = $(this).parents('form');
      var hasFiles = form.find('input[type=file]').length > 0;
      $.stdDialog.loading();
      form.ajaxSubmit({
        iframe: hasFiles,
        dataType: 'json',
        success: function(result) {
          if (result.state == 'win') {
            if (result.view) {
              $.stdDialog.html(result.view);
            } else {
              window.location.reload();
            }
          } else {
            if (result.msg) alert(result.msg);
            $.stdDialog.html(result.view);
          }
        }
      });
      return false; // ignore the button press
    });

  },

  show: function(title, contents, options) {
    options = $.extend({
      closeOnEscape: false,
      title: title,
      modal: true, draggable: true,
      resizable: false,
      position: ['center', 20],
      width: 750, height: (window.innerHeight - 50),
      dialogClass: 'simple',
      close: function() {
        if ($('#dialog form').hasClass('dirty')) {
          if ($.stdDialog.redirectToUrl == '')
            window.location.reload();
          else
            window.location = $.stdDialog.redirectToUrl;
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
    return $('#dialog').dialog(options).dialog('open');
  },

  loading: function() {
    $('#dialog').children().hide().after($('#dialogSpinner').html());
  },

  html: function(contents) {
    if (contents) {
      $('#dialog').html(contents);
      $('#dialog form .markItUp').markItUp(mySettings);
   } else {
      return $('#dialog').html();
    }
  },

  hide: function() {
    $('html,body').smoothScrollBack('stop');
    $('#dialog').dialog('close');
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

  $.commentActions.bindings();
  $.stdDialog.bindings();

  $('a[data-confirm]').live('click', function() {
    if (confirm($(this).attr('data-confirm'))) {
      return true;
    } else {
      return false;
    }
  });

});
