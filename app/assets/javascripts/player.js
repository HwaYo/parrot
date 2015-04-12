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
    this.speedControll();
    this.playControll();
  },

  playControll: function() {
    var wavesurferObject = wavesurfer.object;

    $('.bookmark-tag').on('click', function() {
      wavesurferObject.play($(this).data('start'));
      player.showPausebutton();
    });

    $('[data-action="play"]').on('click', function() {
      wavesurferObject.playPause();
    });

    $('#forward-btn').on('click', function() {
      wavesurferObject.skipForward();
    });

    $('#backward-btn').on('click', function() {
      wavesurferObject.skipBackward();
    });
  },

  speedControll: function() {
    var wavesurferObject = wavesurfer.object;

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
        console.log('realSpeed : ' + realSpeed);
        $('#speed-info').html(realSpeed.toFixed(1));
        wavesurferObject.setPlaybackRate(realSpeed);
      }
    }
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
        region.color = randomColor(0.1);
        wavesurferObject.addRegion(region);
      });
    };

    wavesurferObject.on('ready', function () {
      wavesurferObject.util.ajax({
        responseType: 'json',
        url: $("#waveform-player").data('id')+'/bookmark_json',
      }).on('success', function (data) {
        loadRegions(data);
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
  // wavesurfer.init();
  player.init();
});




  

  

  





