$(document).on('ready page:load', function () {
  editModal.init();
});

var editModal = {
  init: function(){
    this.loadInitContent();
    $("#edit-modal").on("shown.bs.modal", function(e) {
      editModal.setValidationEvent();
    });
  },

  loadInitContent: function(){
    $(".btn-record-edit").on("click", function(e){
      var link = $(e.target);
      var postId = link.data('post');

      $.ajax({
        url: "records/" + postId + "/edit"
      }).success(function(html){
        $('.modal-body').html(html);
      });
    });
  },

  setValidationEvent: function(){
    $('#edit-modal form').on('ajax:success', function(xhr, status, error){
      location.reload();
    }).on('ajax:error',function(xhr, status, error){
      $('.modal-body').html(status.responseText);
      editModal.setValidationEvent();
    });
  }


}