
var mRecorder = {
  wavesurfer : Object.create(WaveSurfer),
  audioContext : null,
  chunkRecorder : null,
  microphone : Object.create(WaveSurfer.MicrophoneStream),
  started : false,
  recording : false,

  init : function(){
    try {
      window.AudioContext = window.AudioContext || window.webkitAudioContext;
      navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia;
      window.URL = window.URL || window.webkitURL;

      this.audioContext = new AudioContext;
    } catch (e) {
      alert('No web audio support in this browser!');
    }

    this.wavesurfer.init({
      container     : '#waveform-recorder',
      interact      : false,
      cursorWidth   : 0,
      height: 100
    });

    this.microphone.init({
      wavesurfer: this.wavesurfer,
      bufferSize: 4096,
      windowSize: 4096 * 10
    });

    this.addMicrophoneEvent();
    this.addClickEvent();

    

  },

  addMicrophoneEvent : function(){
    this.microphone.on('deviceReady', function(stream) {
      var input = this.audioContext.createMediaStreamSource(stream);

      this.chunkRecorder = new ChunkRecorder(function () {
        return new Recorder(input);
      }, {
        encoding_method: function (recorder, callback) {
          recorder.exportWAV(function (blob) {
            callback(null, blob);
          });
        }
      });

      this.chunkRecorder.record();
      $('.recorder-description').hide();
      $('#pause-record').show();
      $('#record').hide();
    }.bind(this));

    this.microphone.on('deviceError', function(code) {
      console.warn('Device error: ' + code);
    }.bind(this));
    
  },

  addClickEvent : function(){
    $(".recorder-component.record").on('click', function () {
      this.recording = true;
      $('.recorder-component.pause, .recorder-component.save').show();
      $(".recorder-component.record").hide();

      if (this.started) {
        this.microphone.togglePlay();
        this.chunkRecorder.record();
      }
      else {
        this.microphone.start();
        this.started = !this.started;
      }
    }.bind(this));

    $(".recorder-component.pause").on('click', function () {
      this.recording = false;
      this.microphone.togglePlay();
      this.chunkRecorder.pause();
      $(".recorder-component.pause").hide();
      $(".recorder-component.record").show();
    }.bind(this));

    $(".recorder-component.save").on('click', function (){
      if(this.started && !this.recording) {
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

        this.chunkRecorder.stop(function (err, blob) {
          var fd = new FormData();
          fd.append('record[file]', blob, 'record.wav');
          fd.append('record[note]', $('#note-area').html());
          fd.append('record[bookmark]', JSON.stringify(bookmarkHandler.bookmarks) );
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
        });
      }
    }.bind(this));

  }
}


$(document).on('ready page:load', function () {
  bookmarkHandler.init(true);
  mRecorder.init();

  $('.recorder-component').show();
  $('.recorder-component.pause, .recorder-component.save').hide();
  $('.player-component').hide();
});