
var documentFormBindings = function() {
  $('.documentFormAction').unbind('click').click(function() {
    var title = $(this).attr('title');
    $.get($(this).attr('href'), '', function(data) {
      $('#dialog').html(data).dialog({
          title: title,
          modal: true, draggable: true,
          position: ['center', 40],
          width: 750, height: 500,
          dialogClass: 'simple',
          close: function() {
            $('#dialog').dialog('destroy');
          }
      }).dialog('open');
      documentFormBindings();
    });
    return false;
  });

  $('form.documentSaveForm').unbind('submit').submit(function() { 
    postAndParse(this, function(result) {
      if (result.status == 'WIN') {
        window.location.reload();
      } else {
        $('#dialog').html(result.view);
      }
    });
    return false;
  });

  $('form.documentActions').unbind('submit').submit(function() {
    postAndParse(this, function(result) {
      if (result.status == 'WIN') {
        window.location.reload();
      } else {
        alert(result.msg);
      }
    });
    return false;
  });

  $('form.documentActionsConfirm').unbind('submit').submit(function() {
    if (confirm($(this).find('.confirm').html())) {
      postAndParse(this, function(result) {
        if (result.status == 'WIN') {
          window.location.reload();
        } else {
          alert(result.msg);
        }
      });
    }
    return false;
  });

  $('form .markItUp').markItUp(mySettings);

  $('form label.hideable').click(function() {
    $(this).next().toggle(100);
  });
};


var commentFormBindings = function() {

  $('form.commentActions').unbind('submit').submit(function() {
    postAndParse(this, function(result) {
      if (result.status == 'WIN') {
        window.location.reload();
      } else {
        alert(result.msg);
      }
    });
    return false;
  });

  $('form.commentActionsConfirm').unbind('submit').submit(function() {
    if (confirm($(this).find('.confirm').html())) {
      postAndParse(this, function(result) {
        if (result.status == 'WIN') {
          window.location.reload();
        } else {
          alert(result.msg);
        }
      });
    }
    return false;
  });

};


$(document).ready( function(){

  documentFormBindings();
  commentFormBindings();

  $('.sideBar .items.sortable').sortable({
    handle: '.handle', items: '.sideBarEntry',
    cursor: 'pointer',
    update: function(event, ui) {
      var list = $('.sideBar .items.sortable');
      var form = list.prev();
      $.post(form.attr('action'), form.serialize() + '&' + list.sortable('serialize'), function(data) {
        var result = parseJSON(data);
        if (result.status != 'WIN') {
          alert(result.msg);
        }
      });
    }
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
