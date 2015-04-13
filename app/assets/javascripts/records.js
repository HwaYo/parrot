if ( typeof (record) == typeof (undefined)) {
    record = {};
}

record = {
  init: function() {
    this.addEventListener();
  },
  addEventListener: function() {
    this.addEditRecordFormEvent();
  },
  addEditRecordFormEvent: function() {
    var setValidationEvent = function() {
      $('#edit-record-modal form').on('ajax:success', function(xhr, status, error){
        location.reload();
      }).on('ajax:error',function(xhr, status, error){
        $('#edit-record-modal-content').html(status.responseText);
        setValidationEvent();
      });
    };

    $("#edit-record-modal").on("shown.bs.modal", function(e) {
      setValidationEvent();
    });

    $('[data-record-edit]').on("click", function(e){
      e.preventDefault();

      var recordId = $(this).data('record');
          url = "records/" + recordId + "/edit";

      record.request(url, function(html){
        $('#edit-record-modal-content').html(html);
      });
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

$(document).on('ready page:load', function () {
  record.init();
});
