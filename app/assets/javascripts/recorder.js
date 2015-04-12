// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


// [{start: Float, end:Float, data:{note:String}}]
(function(){

}());
var audio_context;
var chunk_recorder;
var bookmarks = [];

var audio_init = function () {
  try {
    // webkit shim
    window.AudioContext = window.AudioContext || window.webkitAudioContext;
    navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia;
    window.URL = window.URL || window.webkitURL;

    audio_context = new AudioContext;
  } catch (e) {
    alert('No web audio support in this browser!');
  }

  var wavesurfer = Object.create(WaveSurfer);

  wavesurfer.init({
    container     : '#waveform-recorder',
    interact      : false,
    cursorWidth   : 0,
    height: 100
  });

  var microphone = Object.create(WaveSurfer.MicrophoneStream);

  microphone.init({
    wavesurfer: wavesurfer,
    bufferSize: 4096,
    windowSize: 4096 * 10
  });

  microphone.on('deviceReady', function(stream) {
    var input = audio_context.createMediaStreamSource(stream);

    chunk_recorder = new ChunkRecorder(function () {
      return new Recorder(input);
    }, {
      encoding_method: function (recorder, callback) {
        recorder.exportWAV(function (blob) {
          callback(null, blob);
        });
      }
    });

    chunk_recorder.record();
    $('#pause-record').show();
    $('#record').hide();
  });

  microphone.on('deviceError', function(code) {
    console.warn('Device error: ' + code);
  });
  var started = false;
  var recording = false;
  $(".recorder-component.record").on('click', function () {
    recording = true;
    $('.recorder-component.pause, .recorder-component.save').show();
    $(".recorder-component.record").hide();

    if (started) {
      microphone.togglePlay();
      chunk_recorder.record();
    }
    else {
      microphone.start();
      started = !started;
    }
  }.bind(this));

  $(".recorder-component.pause").on('click', function () {
    recording = false;
    microphone.togglePlay();
    chunk_recorder.pause();
    $(".recorder-component.pause").hide();
    $(".recorder-component.record").show();
  }.bind(this));

  $(".recorder-component.save").on('click', function (){
    if(started && !recording) {
      $.blockUI({
        css: {
          border: 'none',
          padding: '15px',
          backgroundColor: '#000',
          '-webkit-border-radius': '10px',
          '-moz-border-radius': '10px',
          opacity: .5,
          color: '#fff'
        }
      });

      chunk_recorder.stop(function (err, blob) {
        var fd = new FormData();
        fd.append('record[file]', blob, 'record.wav');
        fd.append('record[note]', $('#note-area').html());
        fd.append('record[bookmark]', JSON.stringify(bookmarks) );
        $.ajax({
            type: 'POST',
            url: '/records',
            data: fd,
            processData: false,
            contentType: false
        }).done(function(data) {
          var result = data;
          location.href = data.href;
        });
      }.bind(this));
    }
  }.bind(this));
};

function makeBookmarkDic() {
  bookmarkDic = { 1:"중요", 2:"안중요", 3:"듣지마" };
  return bookmarkDic;
}

function bookmarkTag(params) {
  var bookmark = $('<a />')
    .addClass('bookmark-tag')
    .attr({
      'href': '#',
      'contenteditable': false,
      'data-start': params.start,
      'data-end': params.end
    })
    .text(params.start + "초 - " + params.data);
  return bookmark;
}

$(document).on('ready page:load', function () {

  audio_init();
  $("[data-bookmark]").on('click', function(){

    var bookmarkval = $(this).data('bookmark');
    var bookmark = {
      start : (App.runningTime/10) - 0.5,
      end : (App.runningTime/10) + 0.5,
      data : bookmarkval,
    }
    bookmarks.push(bookmark);

    var note = $('#note-area');

    var bookmarkElement = bookmarkTag(bookmark);
    var p = document.createElement('p');
    p.innerHTML = '<br>';

    note.append($(bookmarkElement))
        .append($(p));

    // Setting Focus to the end of text.
    var range = document.createRange();
    var sel = document.getSelection();
    range.setStartAfter(bookmarkElement[0] ,0);
    range.collapse(true);
    sel.removeAllRanges();
    sel.addRange(range);

    note.focus();
  });

  $('.recorder-component').show();
  $('.recorder-component.pause, .recorder-component.save').hide();
  $('.player-component').hide();
});