
$(document).on('ready page:load', function() {
  $( ".bookmark-item" ).on('mouseenter mouseleave',function() {
    $(this).children('.bookmark-modify').toggle();
    $(this).children('.bookmark-normal').toggle();
  });

  editModal.init();
});


var editModal = {
  init: function(){
    this.loadInitContent();
    $("#bookmark-modify-modal").on("shown.bs.modal", function(e) {
      editModal.setValidationEvent();
    });
  },

  loadInitContent: function(){
    $('[data-target="#bookmark-modify-modal"]').on("click", function(e){
      var link = $(e.target);
      var bookmarkId = link.data('bookmark-id');

      $.ajax({
        url: "/bookmarks/" + bookmarkId + "/edit"
      }).success(function(html){
        $('.modal-form').html(html);
      });
    });
  },

  setValidationEvent: function(){
    $('#bookmark-modify-modal form').on('ajax:success', function(xhr, status, error){
      location.reload();
    }).on('ajax:error',function(xhr, status, error){
      $('.modal-form').html(status.responseText);
      editModal.setValidationEvent();
    });
  }
}

