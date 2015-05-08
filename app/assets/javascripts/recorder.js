(function (window, navigator) {
  // webkit shim
  try {
    window.AudioContext = window.AudioContext || window.webkitAudioContext;
    navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia;
    window.URL = window.URL || window.webkitURL;
  } catch (e) {
    alert('No web audio support in this browser!');
  }

  // initialize vorbis
  Vorbis.configure({
    workerURL: '/libvorbis.worker.js',
    moduleURL: '/libvorbis.module.min.js',
    memoryInitializerURL: '/libvorbis.module.min.js.mem'
  });

  var Recorder = function (params) {
    // initialize params
    params = params || {};
    this.channels = params['channels'] || 2;
    this.bufferSize = params['bufferSize'] || 4096;
    this.quality = params['quality'] || 0.8;
    this.sampleRate = null;

    this.recording = false;
    this.elapsedTime = 0;

    this.streamInitialized = false;
    this.streamRef = null;
    this.encoderPromise = null;

    this.audioContext = null;
    this.audioSourceNode = null;
    this.scriptProcessorNode = null;

    // UI binding
    this.recordButton = $('.recorder-component.record');
    this.pauseButton = $('.recorder-component.pause');
    this.saveButton = $('.recorder-component.save');

    this._bindUI();
  };

  Recorder.prototype._bindUI = function () {
    this.recordButton.on('click', function () {
      this.record().then(function () {
        this.pauseButton.show(); this.saveButton.show();
        this.recordButton.hide();
      }.bind(this));
    }.bind(this));

    this.pauseButton.on('click', function () {
      this.pause().then(function () {
        this.pauseButton.hide();
        this.recordButton.show();
      }.bind(this));
    }.bind(this));

    this.saveButton.on('click', function () {
      if (!this.recording) {
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

        this.save().then(function (blob) {
          this._sendBlob(blob).then(function (data) {
            var result = data;
            location.href = data.href;
          });
        }.bind(this));
      }
    }.bind(this));
  };

  Recorder.prototype.record = function () {
    if (!this.streamInitialized) {
      return this._initializeStream().then(function () {
        this.recording = true;
      }.bind(this));
    }
    else if (!this.recording) {
      // resume
      this.recording = true;
    }

    return Promise.resolve();
  };

  Recorder.prototype._initializeStream = function () {
    return new Promise(function (resolve, reject) {
      navigator.getUserMedia({ audio: true }, function (stream) {
        this.streamRef = stream;
        this._connectAudioStream(stream).then(function () {
          this.streamInitialized = true;
          resolve();
        }.bind(this));
      }.bind(this), function () {
        alert("Error occurred!");
        reject();
      });
    }.bind(this));
  };

  Recorder.prototype._connectAudioStream = function (stream) {
    this.audioContext = new AudioContext();
    this.audioSourceNode = this.audioContext.createMediaStreamSource(stream);
    this.scriptProcessorNode = this.audioContext.createScriptProcessor(this.bufferSize);

    this.sampleRate = this.audioContext.sampleRate;

    this.encoderPromise =
      Vorbis.Encoding.createVBR(this.channels, this.sampleRate, this.quality)
      .then(Vorbis.Encoding.writeHeaders);

    // Need a central audio stream.
    this.scriptProcessorNode.onaudioprocess = function (e) {
      if (!this.recording) {
        return;
      }

      var inputBuffer = e.inputBuffer;
      var samples = inputBuffer.length;

      this.elapsedTime += (samples / this.sampleRate);

      var ch0 = inputBuffer.getChannelData(0);
      var ch1 = inputBuffer.getChannelData(1);

      ch0 = new Float32Array(ch0);
      ch1 = new Float32Array(ch1);

      var buffers = [ch0.buffer, ch1.buffer];

      this.encoderPromise = this.encoderPromise.then(Vorbis.Encoding.encodeTransfer(samples, buffers));
    }.bind(this);

    this.audioSourceNode.connect(this.scriptProcessorNode);
    this.scriptProcessorNode.connect(this.audioContext.destination);

    return Promise.resolve();
  };

  Recorder.prototype.pause = function () {
    this.recording = false;
    return Promise.resolve();
  };

  Recorder.prototype.save = function () {
    this.streamRef.stop();
    this.audioSourceNode.disconnect(this.scriptProcessorNode);
    this.scriptProcessorNode.disconnect(this.audioContext.destination);

    this.encoderPromise = this.encoderPromise.then(Vorbis.Encoding.finish);

    return this.encoderPromise;
  };

  Recorder.prototype._sendBlob = function (blob) {
    var fd = new FormData();
    fd.append('record[file]', blob, 'record.ogg');
    fd.append('record[note]', $('#note-area').html());
    fd.append('record[bookmark]', JSON.stringify(bookmarkHandler.bookmarks) );

    return new Promise(function (resolve, reject) {
      $.ajax({
        type: 'POST',
        url: '/records',
        data: fd,
        processData: false,
        contentType: false
      }).done(resolve).fail(reject);
    });
  };

  Recorder.prototype.getElapsedTime = function () {
    return this.elapsedTime.toFixed(1);
  };

  window.Recorder = Recorder;
})(window, navigator);

$(document).on('ready page:load', function () {
  $('.recorder-component').show();
  $('.recorder-component.pause, .recorder-component.save').hide();
  $('.player-component').hide();

  App.recorder = new Recorder();
});