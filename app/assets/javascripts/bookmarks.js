
$(document).on('ready page:load', function() {
  $('#new-bookmark').on('click', function() {
    $('#new-bookmark-form').removeClass("close");
    $('#new-bookmark-form').addClass("open");
  });

  $('#close-new-bookmark-form').on('click', function() {
    $('#new-bookmark-form').removeClass("open");
    $('#new-bookmark-form').addClass("close");
  });
});
