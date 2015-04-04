// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var audio_context;
var chunk_recorder;

var RecorderBuffer = function (input) {
  // double buffering
  this.buffer = [];
  this.current_buffer_index = 0;
  this.buffer.push(new Recorder(input));
  this.buffer.push(new Recorder(input));
};

RecorderBuffer.prototype = {
  constructor: RecorderBuffer,
  get_current_buffer: function () {
    return this.buffer[this.current_buffer_index];
  },
  swap_buffer: function () {
    this.current_buffer_index = 1 - this.current_buffer_index;
    return this.get_current_buffer();
  }
};

var ChunkRecorder = function (input) {
  // TEMP: need a lock for each recorder and ensure working order.
  this.lock = false;
  this.recorder_buffer = new RecorderBuffer(input);
  this.chunks = [];
};

ChunkRecorder.prototype = {
  constructor: ChunkRecorder,
  record: function () {
    var recorder = this.recorder_buffer.get_current_buffer();
    recorder.record();
  },
  pause: function () {
    var recorder = this.recorder_buffer.get_current_buffer();
    recorder.stop();
  },
  stop: function (callback) {
    this._store_chunk(this.recorder_buffer.get_current_buffer(), callback);
  },
  clear: function () {
    this.recorder_buffer.get_current_buffer().clear();
  },
  get_recorded_url: function () {
    var recorded_wav = this.chunks[0];
    var objectURL = URL.createObjectURL(recorded_wav);
    return objectURL;
  },
  _swap: function () {
    if (!this.lock) {
      this.lock = true;
      var recording = this.recorder_buffer.get_current_buffer();
      var swapped = this.recorder_buffer.swap_buffer();

      this._store_chunk(recording);
      swapped.record();
    } else {
      setTimeout(this._swap, 200);
    }
  },
  _store_chunk: function (recording, callback) {
    recording.stop();
    recording.exportWAV(function (b) {
      console.log(this.chunks.length + ': New chunk');
      this.chunks.push(b);
      recording.clear();

      this.lock = false;

      console.log(callback);
      if (callback) {
        callback(null, b);
      }
    }.bind(this));
  }
};

var audio_init = function () {
  try {
    // webkit shim
    window.AudioContext = window.AudioContext || window.webkitAudioContext;
    navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia;
    window.URL = window.URL || window.webkitURL;

    audio_context = new AudioContext;
    console.log('Audio context set up.');
    console.log('navigator.getUserMedia ' + (navigator.getUserMedia ? 'available.' : 'not present!'));
  } catch (e) {
    alert('No web audio support in this browser!');
  }

  var wavesurfer = Object.create(WaveSurfer);

  wavesurfer.init({
    container     : '#waveform-recorder',
    interact      : false,
    cursorWidth   : 0
  });

  var microphone = Object.create(WaveSurfer.Microphone);

  microphone.init({
      wavesurfer: wavesurfer
  });

  microphone.on('deviceReady', function(stream) {
    console.log('Device ready!', stream);
    var input = audio_context.createMediaStreamSource(stream);
    console.log('Media stream created.');

    chunk_recorder = new ChunkRecorder(input);
    console.log('Recorder initialised.');

    chunk_recorder.record();
    $('#pause-record').show();
    $('#record').hide();
  });

  microphone.on('deviceError', function(code) {
    console.warn('Device error: ' + code);
  });

  var started = false;
  var recording = false;
  $("#record").on('click', function () {
    recording = true;

    if (started) {
      chunk_recorder.record();
      microphone.togglePlay();
      $('#pause-record').show();
      $('#record').hide();
    }
    else {
      microphone.start();
      started = !started;
    }
  }.bind(this));

  $("#pause-record").on('click', function () {
    recording = false;
    microphone.togglePlay();
    chunk_recorder.pause();
    $('#record').show();
    $('#pause-record').hide();
  }.bind(this));

  $("#save-record").on('click', function (){
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
        fd.append('file', chunk_recorder.chunks[0], 'record.wav');
        fd.append('note', $('#note-area').val());
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

$(document).on('ready page:load', function () {
  audio_init();

  $('.recorder-component').show();
  $('.player-component').hide();
});