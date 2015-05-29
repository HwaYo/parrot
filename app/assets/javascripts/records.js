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
    var setValidationEvent = function(action) {
      $('#' + action + '-record-modal form').on('ajax:success', function(xhr, status, error){
        location.reload();
      }).on('ajax:error',function(xhr, status, error){
        $('#' + action + '-record-modal-content').html(status.responseText);
        $('#share-btn').on('click', function(){
            window.prompt("Copy to clipboard: Ctrl+C, Enter", $(this).attr("data-clipboard-text"));
          });
        setValidationEvent(action);
      });
    };

    $("#edit-record-modal").on("shown.bs.modal", function(e) {
      setValidationEvent('edit');
    });

    $("#share-record-modal").on("shown.bs.modal", function(e) {
      $('#share-btn').on('click', function(){
        window.prompt("Copy to clipboard: Ctrl+C, Enter", $(this).attr("data-clipboard-text"));
      });
      setValidationEvent('share');
    });

    $('[data-record-edit]').on("click", function(e){
      e.preventDefault();

      var recordId = $(this).data('record');
      var action = $(this).data('action');

      url = "records/" + recordId + "/" + action;

      record.request(url, function(html){
        $('#' + action + '-record-modal-content').html(html);
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
