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
  stop: function () {
    this._store_chunk(this.recorder_buffer.get_current_buffer());
  },
  clear: function () {
    this.recorder_buffer.get_current_buffer().clear();
  },
  _swap: function () {
    console.log('try swapping.');
    if (!this.lock) {
      console.log('swapped.');
      this.lock = true;
      var recording = this.recorder_buffer.get_current_buffer();
      var swapped = this.recorder_buffer.swap_buffer();

      this._store_chunk(recording);
      swapped.record();
    } else {
      setTimeout(this._swap, 200);
    }
  },
  _store_chunk: function (recording) {
    recording.stop();
    recording.exportWAV(function (b) {
      console.log(this.chunks.length + ': New chunk');
      this.chunks.push(b);
      recording.clear();

      this.lock = false;
    }.bind(this));
  }
};

function startUserMedia(stream) {
  var input = audio_context.createMediaStreamSource(stream);
  console.log('Media stream created.');

  chunk_recorder = new ChunkRecorder(input);
  console.log('Recorder initialised.');

  $("#record-btn").on('click', function () {
    chunk_recorder.record();
  });

  $("#stop-btn").on('click', function () {
    chunk_recorder.stop();
  });
}

$(document).on('ready page:load', function () {
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

  navigator.getUserMedia({audio: true}, startUserMedia, function(e) {
    console.log('No live audio input: ' + e);
  });
});

$(document).on('ready page:load', function () {
  $("#dim").on('click', function() {
    $("#wrapper").toggleClass("toggled");
    $("#dim").hide(true);
  });

  $("#menu-toggle").on('click', function(e) {
    $("#wrapper").toggleClass("toggled");
    $("#dim").show(true);
  });
});