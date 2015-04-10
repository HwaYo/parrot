
$(document).on('ready page:load', function() {
  $('#open-new-bookmark').on('click', function() {
    $('#new-bookmark-form').removeClass("hide");
  });

  $('#close-new-bookmark').on('click', function() {
    $('#new-bookmark-form').addClass("hide");
  });

  $('.main-container').on('click', '[data-color]', function() {
    var color = $(this).data('color');
    var dropdown = $(this).parents('.dropdown');
    dropdown.find('.palette-preview').css('background-color', color);
    dropdown.children('[name="bookmark[color]"]').val(color);
  });

  $('.main-container').on('click', '[data-close-bookmark-form]', function() {
    var bookmarkItem = $(this).parents('.list-group-item');
    bookmarkItem.children('.viewer').show();
    bookmarkItem.children('.modify').hide();
  });

  $('.glyphicon-edit').on('click', function() {
    var target = $(this);
    var bookmarkId = target.data('bookmark-id');

    console.log(bookmarkId);
    $.ajax({
      url: "/bookmarks/" + bookmarkId + "/edit"
    }).success(function(html){
      target.parents('.viewer').next().html(html);
      target.parents('.viewer').next().show();
      target.parents('.viewer').hide();
    });
  });
        

});
