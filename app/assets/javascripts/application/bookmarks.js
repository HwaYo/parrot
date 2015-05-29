if ( typeof (bookmark) == typeof (undefined)) {
    bookmark = {};
}

bookmark = {
  init: function() {
    this.addEventListener();
  },
  addEventListener: function() {
    this.addNewBookmarkFormEvent();
    this.addEditBookmarkFormEvent();
    this.addColorPickEvent();
  },
  addNewBookmarkFormEvent: function() {
    var $newBookmarkForm = $('#new-bookmark-form');

    $('#open-new-bookmark').on('click', function() {
      $newBookmarkForm.removeClass("hide");
    });

    $('#close-new-bookmark').on('click', function() {
      $newBookmarkForm.addClass("hide");
    });
  },
  addColorPickEvent: function() {
    $('.main-container').on('click', '[data-color]', function() {
      var $target = $(this),
          color = $target.data('color'),
          dropdown = $target.parents('.dropdown');

      dropdown.find('.palette-preview').css('background-color', color);
      dropdown.children('[name="bookmark[color]"]').val(color);
    });
  },
  addEditBookmarkFormEvent: function() {
    $('[data-bookmark-edit]').on('click', function() {
      var $target = $(this),
          bookmarkId = $target.data('bookmark-id'),
          url = "/bookmarks/" + bookmarkId + "/edit";

      bookmark.request(url, function(html) {
          var $viewer = $target.parents('.viewer');
              $modify = $viewer.next();
          $modify.html(html);
          $modify.show();
          $viewer.hide();
      });
    });

    $('.main-container').on('click', '[data-close-bookmark-form]', function() {
      var bookmarkItem = $(this).parents('.list-group-item');
      bookmarkItem.children('.viewer').show();
      bookmarkItem.children('.modify').hide();
    });
  },
  request: function(url, callback) {
    $.ajax({
      url: url
    }).success(function(result){
      callback(result);
    });
  }
};

$(document).on('ready page:load', function() {
  bookmark.init();
});