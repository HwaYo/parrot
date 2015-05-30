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
  addClickListener: function() {
    $('#share-btn').on('click', function(){
      window.prompt("Copy to clipboard: Ctrl+C, Enter", $(this).attr("data-clipboard-text"));
    });
    $('#share-stop').on('click', function() {
      record.request(url, 'DELETE', function(result){
        $('#share-record-modal-content').html(result);
        record.addClickListener();
        record.setValidationEvent('share');
      });
    });
  },
  setValidationEvent: function(action) {
    $('#' + action + '-record-modal form').on('ajax:success', function(xhr, status, error){
      location.reload();
    }).on('ajax:error',function(xhr, status, error){
      $('#' + action + '-record-modal-content').html(status.responseText);
      record.addClickListener();
      record.setValidationEvent(action);
    });
  },
  addEditRecordFormEvent: function() {

    $("#edit-record-modal").on("shown.bs.modal", function(e) {
      record.setValidationEvent('edit');
    });

    $("#share-record-modal").on("shown.bs.modal", function(e) {
      record.addClickListener();
      record.setValidationEvent('share');
    });

    $('[data-record-edit]').on("click", function(e){
      e.preventDefault();

      var recordId = $(this).data('record');
      var action = $(this).data('action');

      url = "records/" + recordId + "/" + action;

      record.request(url, 'GET', function(html){
        $('#' + action + '-record-modal-content').html(html);
      });
    });
  },
  request: function(url, type, callback, error) {
    $.ajax({
      url: url,
      type: type,
    }).success(function(result){
      callback(result);
    }).error(error);
  }
};

$(document).on('ready page:load', function () {
  record.init();
});
