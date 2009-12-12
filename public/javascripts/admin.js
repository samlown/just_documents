
// Used to prevent the main window from scrolling
var scrollTop = 0, scrollInterval = null, scrollSemaphore = false;

$(document).ready( function(){

  $.documentForm.bindings();
  $.documentActions.bindings();
  $.commentActions.bindings();
  $.stdDialog.bindings();

  $('.items.sortable').sortable({
    handle: '.dragHandle', items: 'article, .draggableItem',
    cursor: 'move',
    update: function(event, ui) {
      var list = $(this);
      var form = $('#sortDocumentsForm');
      $.post(form.attr('action'), form.serialize() + '&' + list.sortable('serialize'), function(data) {
        var result = parseJSON(data);
        if (result.state != 'win') {
          alert(result.msg);
        }
      });
    }
  });

  $('.adminToggle').click(function() {
    $('.sideActions').toggle();
    $('.adminArea').toggle();
    $('.notPublished').toggle();
    return false;
  });
  /* Not convinced, I think its easier to show them all the time
  $('.documentBody, .commentBody').hover(
    function() {
      $(this).find('.sideActions').show();
    },
    function() {
      var doc = $(this);
      setTimeout(function(){ doc.find('.sideActions').hide(250); }, 200);
    }
  );
  */

});

/*
 * Methods related to handling actions performed on documents while being viewed (not edited).
 */
$.documentActions = {

  bindings: function() {
    $('form.documentActions button[type=submit]').live('click', function() {
      $.documentActions.save($(this).parents('form'));
      return false;
    });

    $('form.documentActionsConfirm button[type=submit]').die('click').live('click', function() {
      if (confirm($(this).siblings('.confirm').html())) {
        $.documentActions.save($(this).parents('form'));
      }
      return false;
    });
  },

  save: function(form, options) {
    postAndParse(form, options, function(result) {
      if (result.state == 'win') {
        window.location.reload();
      } else {
        alert(result.msg);
      }
    });
  }
};

/*
 * Methods for handling the document form, including loading the form itself.
 */
$.documentForm = {

  // URL to redirect to, mainly when the slug has changed.
  redirectToUrl: '',

  bindings: function() {
    $('.documentFormAction').live('click', function() { $.documentForm.edit($(this)); return false; });

    $('form.documentSaveForm button[type=submit]').live('click', function() {
      // save with the buttons name and value
      var options = {
        // provide button specific details
        params: [ {name: $(this).attr('name'), value: $(this).attr('value')} ],
        // Delay refresh for when form closed for drafts
        noRefresh: $(this).attr('value') == 'draft'
      };
      $.documentForm.save($(this).parents('form'), options);
      return false;
    });

    $('form .hideable .toggle').live('click', function() {
      $(this).parent().next().toggle(100);
      return false;
    });

    // Handle auto generating the slug
    $('form .slugOrigin input').live('keyup', function() {
      if ($('form input.originalSlug').val() == '') {
        // DRY alert! See also models/document.rb
        var slug = $(this).val().replace(/^\s+|[^\w\d_ ]+|\s+$/g, '').replace(/ /g, '_').toLowerCase();
        $(this).parents('form').find('.slugUrl .slug').html(slug);
        if ($('form .slugUrlField.hidden').length > 0) 
          $(this).parents('form').find('.slugUrlField input').val(slug);
      }
    });


    $('form .slug .slugUrl a').live('click', function() {
      var slug = $(this).siblings('.slug').html();
      $(this).parent().addClass('hidden').siblings('.slugUrlField').removeClass('hidden').find('input').val(slug);
      return false;
    });
    $('form .slug .slugUrlField a').live('click', function() {
      $(this).parent().addClass('hidden').siblings('.slugUrl').removeClass('hidden');
      return false;
    });
  },

  /*
   * Load the form dialog to edit with from the provided link jQuery object.
   */
  edit: function(link, options) {
    var title = link.attr('title');
    $.stdDialog.show(title);
    $.get(link.attr('href'), '', function(data) {
      var result = parseJSON(data);
      // Lock the window scrolling
      $.stdDialog.html(result.view);
    });
  },

  /*
   * Save the document, parse the result and either redraw dialog or refresh page.
   */
  save: function(form, options) {
    // Disable all the buttons first
    form.find('button').attr('disabled', 'disabled');
    // $.stdDialog.loading();
    postAndParse(form, options, function(result) {
      if (result.state == 'win') {
        if (! options.noRefresh) {
          if (result.redirect)
            window.location = result.url;
          else
            window.location.reload();
        } else {
          if (result.redirect) {
            $.documentForm.redirectToUrl = result.url;
          } else {
            $.stdDialog.html(result.view);
            $('#dialog form').addClass('dirty');
          }
        }
      } else {
        $.stdDialog.html(result.view);
        $('#dialog form').addClass('dirty');
        // alert(result.msg);
      }
    });
  },

  /*
   * Alias for save
   */
  update: function(form, options) {
    return $.documentForm(form, options);
  },

  /*
   * Alias for save
   */
  create: function(form, options) {
    return $.documentForm(form, options);
  }

};

$.commentActions = {

  bindings: function() {
    $('form.commentActions button[type=submit]').live('click', function() {
      $.commentActions.save($(this).parents('form'));
      return false;
    });

    $('form.commentActionsConfirm button[type=submit]').live('click', function() {
      if (confirm($(this).find('.confirm').html())) {
        $.commentActions.save($(this).parents('form'));
      }
      return false;
    });
  },


  save: function(form, options) {
    postAndParse(this, null, function(result) {
      if (result.state == 'win') {
        window.location.reload();
      } else {
        alert(result.msg);
      }
    });
  },

};


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


$.stdDialog = {

  bindings: function() {
    // Bind to generic dialog link (not live!)
    $('a.dialogLink').click(function() {
      $.stdDialog.show($(this).attr('data-title'));
      $.get($(this).attr('href'), '', function(data) {
        var result = parseJSON(data);
        $.stdDialog.html(result.view);
      });
      return false;
    });

    $('#dialog form button[type=submit]').live('click', function() {
      var form = $(this).parents('form');
      $.stdDialog.loading();
      $.post(form.attr('action'), form.serializeArray(), function(data) {
        var result = parseJSON(data);
        if (result.state == 'win') {
          if (result.view) {
            $.stdDialog.html(result.view);
          } else {
            window.location.reload();
          }
        } else {
          $.stdDialog.html(result.view);
        }
      });
      return false;
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
          if ($.documentForm.redirectToUrl == '')
            window.location.reload();
          else
            window.location = $.documentForm.redirectToUrl;
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
    $('#dialog').html($('#dialogSpinner').html());
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

