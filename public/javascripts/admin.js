
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


$(document).ready( function(){

  documentFormBindings();



});
