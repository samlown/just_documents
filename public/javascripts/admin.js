
// Used to prevent the main window from scrolling
var scrollTop = 0, scrollInterval = null, scrollSemaphore = false;

$(document).ready( function(){

  $.documentForm.bindings();
  $.documentActions.bindings();

  $('.items.sortable').sortable({
    handle: '.dragHandle', items: 'article, .draggableItem',
    cursor: 'move',
    update: function(event, ui) {
      var list = $(this);
      var form = list.find('.sortForm').length > 0 ? list.find('.sortForm') : $('#sortDocumentsForm');
      $.post(form.attr('action'), form.serialize() + '&' + list.sortable('serialize'), function(result) {
        if (result.state != 'win') {
          alert(result.msg);
        }
      }, 'json');
    }
  });

  var toggleAdmin = function() {
    $('.sideActions').toggle();
    $('.adminArea').toggle();
    $('.notPublished').toggle();
    $('.adminToggle a:first').toggleClass('strike');
  };
  if ($.cookie('adminToggle') == 'true') toggleAdmin();
  $('.adminToggle a:first').click(function() {
    toggleAdmin()
    $.cookie('adminToggle', ($.cookie('adminToggle') == 'true' ? 'false' : 'true'), {path: '/'}); 
    return false; 
  });

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

  save: function(form) {
    $.post(form.attr('action'), form.serializeArray(), function(result) {
      if (result.state == 'win') {
        window.location.reload();
      } else {
        alert(result.msg);
      }
    }, 'json');
  }
};



/*
 * Methods for handling the document form, including loading the form itself.
 */
$.documentForm = {

  bindings: function() {
    $('.documentFormAction').live('click', function() { $.documentForm.edit($(this)); return false; });

    $('form.documentSaveForm button[type=submit]').live('click', function() {
      // save with the buttons name and value
      var options = {
        // provide button specific details
        extraParams: [ {name: $(this).attr('name'), value: $(this).attr('value')} ],
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

    /*
     * Handle auto generating the slug
     */
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
    $.get(link.attr('href'), '', function(result) {
      $.stdDialog.html(result.view);
    }, 'json');
  },

  /*
   * Save the document, parse the result and either redraw dialog or refresh page.
   */
  save: function(form, options) {
    $.stdDialog.submit(form, {
      extraParams: options.extraParams,
      success: function(result) {
        if (!options.noRefresh) {
          if (result.redirect)
            window.location = result.url;
          else
            window.location.reload();
        } else {
          if (result.redirect) {
            $('#dialog form').data('redirectOnClose', result.url); // When slug changes
          } 
          $.stdDialog.html(result.view);
          $('#dialog form').addClass('dirty');
        }
      },
      failure: function(result) {
        $.stdDialog.html(result.view);
        $('#dialog form').addClass('dirty');
      }
    });
  }
};


