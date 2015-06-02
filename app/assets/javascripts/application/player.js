// 음소거 : .toggleMute();

if ( typeof (player) == typeof (undefined)) {
  player = {};
}
if ( typeof (wavesurfer) == typeof (undefined)) {
  wavesurfer = {};
}

player = {
  init: function() {
    this.addEventListener();
  },

  addEventListener: function() {
    var wavesurferObject = wavesurfer.object;
    this.addSpeedControllEvent(wavesurferObject);
    this.addPlayControllEvent(wavesurferObject);
    this.addBookmarkTagEvent();
  },

  addPlayControllEvent: function(wavesurferObject) {
    $('.bookmark-tag').on('click', function(e) {
      e.preventDefault();
      wavesurferObject.play($(this).data('start'));
      player.showPausebutton();
    });

    $('[data-action="play"]').on('click', function() {
      wavesurferObject.playPause();
    });
    $('#forward-btn').on('click', function() {
      wavesurferObject.skipForward();
    });
  },
  
  addSpeedControllEvent: function(wavesurferObject) {
    $('#speed-up-btn').on('click', function() {
      setSpeed(1);
    });

    $('#speed-down-btn').on('click', function() {
      setSpeed(-1);
    });

    function setSpeed(variationPpeed) {
      var MIN_SPEED = 5,
          MAX_SPEED = 20,
          currentSpeed = parseFloat($('#speed-info').html()) * 10,
          checkSpeed = currentSpeed + variationPpeed,
          realSpeed;

      if(checkSpeed >= MIN_SPEED && checkSpeed <= MAX_SPEED) {
        realSpeed = (checkSpeed / 10);
        $('#speed-info').html(realSpeed.toFixed(1));
        wavesurferObject.setPlaybackRate(realSpeed);
      }
    }
  },
  addBookmarkTagEvent: function() {
    $("[data-bookmark]").on('click', function(e){
      e.preventDefault();
    });
  },
  showPlaybutton: function() {
    $('[data-play]').show();
    $('[data-pause]').hide();
  },
  showPausebutton: function() {
    $('[data-play]').hide();
    $('[data-pause]').show();
  }
};

wavesurfer = {
  object: null,
  init: function() {
    this.createObject();
    this.addEventListener();
  },
  createObject: function() {
    var wavesurferObject = this.object = Object.create(WaveSurfer),
        record_url = $("#waveform-player").data("url");

    wavesurferObject.init({
      container: '#waveform-player',
      height: 50,
      scrollParent: true,
      normalize: true,
      minimap: true,
      backend: 'AudioElement'
    });
    wavesurferObject.load(record_url);
  },
  addEventListener: function() {
    this.ready();
    this.region();
    this.playControll();
  },
  ready: function() {
    var wavesurferObject = this.object;
    var randomColor = function(alpha) {
      return 'rgba(' + [
        ~~(Math.random() * 255),
        ~~(Math.random() * 255),
        ~~(Math.random() * 255),
        alpha || 1
        ] + ')';
    };

    var loadRegions = function(regions) {
      regions.forEach(function (region) {
        bookmarkHandler.addRegion(region);
      });
    };

    wavesurferObject.on('ready', function () {
      wavesurferObject.util.ajax({
        responseType: 'json',
        url: $("#waveform-player").data('id')+'/bookmark_json',
      }).on('success', function (data) {
        loadRegions(data);
        bookmarkHandler.setBookmarks(data);
      });
    });
  },
  region: function() {
    var wavesurferObject = this.object;

    wavesurferObject.on('region-click', function (region, e) {
      e.stopPropagation();
      e.shiftKey ? region.playLoop() : region.play();
    });

    wavesurferObject.on('region-play', function (region) {
      region.once('out', function () {
        wavesurferObject.play();
      });
    });
  },
  playControll: function() {
    var wavesurferObject = this.object;

    wavesurferObject.on('play', function () {
      player.showPausebutton();
    });

    wavesurferObject.on('pause', function () {
      player.showPlaybutton();
    });

    wavesurferObject.on('finish', function(){
      wavesurferObject.stop();
    });
  }
}

$(document).on('ready page:load' ,function(){
  wavesurfer.init();
  player.init();
});
