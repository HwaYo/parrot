function bindSpeedEvent(wavesurfer){
  $('.speed-group').on('click', function(e){
    var speed = $(e.target).find("input[type='radio']").data('speed');
    wavesurfer.setPlaybackRate(speed);
  });
}

var wavesurfer = Object.create(WaveSurfer);
$(document).on('ready page:load' ,function(){

  var GLOBAL_ACTIONS = {
    'play': function () {
      wavesurfer.playPause();
    },

    'back': function () {
      wavesurfer.skipBackward();
    },    'forth': function () {
      wavesurfer.skipForward();
    },

    'toggle-mute': function () {
      wavesurfer.toggleMute();
    }
  };

  GLOBAL_ACTIONS['delete-region'] = function () {
    var form = document.forms.edit;
    var regionId = form.dataset.region;
    if (regionId) {
      wavesurfer.regions.list[regionId].remove();
      form.reset();
    }
  };

  GLOBAL_ACTIONS['export'] = function () {
    window.open('data:application/json;charset=utf-8,' +
      encodeURIComponent(localStorage.regions));
  };

  wavesurfer.init({
    container: '#waveform-player',
    height: 150,
    scrollParent: true,
    normalize: true,
    minimap: true,
    backend: 'AudioElement'
  });

  var record_url = $("#waveform-player").data("url");
  wavesurfer.load(record_url);

  wavesurfer.on('ready', function () {
    wavesurfer.util.ajax({
      responseType: 'json',
      url: $("#waveform-player").data('id')+'/bookmark_json',
    }).on('success', function (data) {
      loadRegions(data);
    });
  });
  wavesurfer.on('region-click', function (region, e) {
    e.stopPropagation();
    e.shiftKey ? region.playLoop() : region.play();
  });
  // wavesurfer.on('region-click', editAnnotation);
  // wavesurfer.on('region-updated', saveRegions);
  // wavesurfer.on('region-removed', saveRegions);
  wavesurfer.on('region-in', showNote);

  wavesurfer.on('region-play', function (region) {
    region.once('out', function () {
      wavesurfer.play(region.start);
      wavesurfer.pause();
    });
  });


  /* Minimap plugin */
  wavesurfer.initMinimap({
    height: 30,
    waveColor: '#ddd',
    progressColor: '#999',
    cursorColor: '#999'
  });


  /* Timeline plugin */
  wavesurfer.on('ready', function () {
    var timeline = Object.create(WaveSurfer.Timeline);
    timeline.init({
      wavesurfer: wavesurfer,
      container: "#wave-timeline"
    });
  });

  $('.bookmark-tag').on('click', function() {
    console.log(this);
    wavesurfer.play($(this).data('start'), $(this).data('end'));
  });


  /* Toggle play/pause buttons. */
  var playButton = document.querySelector('#play');
  var pauseButton = document.querySelector('#pause');
  wavesurfer.on('play', function () {
    playButton.style.display = 'none';
    pauseButton.style.display = '';
    // wavesurfer.setPlaybackRate(2);
  });
  wavesurfer.on('pause', function () {
    playButton.style.display = '';
    pauseButton.style.display = 'none';
  });
  wavesurfer.on('finish', function(){
    wavesurfer.stop();
  });

  [].forEach.call(document.querySelectorAll('[data-action]'), function (el) {
    el.addEventListener('click', function (e) {
      var action = e.currentTarget.dataset.action;
      if (action in GLOBAL_ACTIONS) {
        e.preventDefault();
        GLOBAL_ACTIONS[action](e);
      }
    });
  });

  bindSpeedEvent(wavesurfer);


});

function loadRegions(regions) {
  regions.forEach(function (region) {
    region.color = randomColor(0.1);
    wavesurfer.addRegion(region);
  });
}

function extractRegions(peaks, duration) {
  // Silence params
  var minValue = 0.0015;
  var minSeconds = 0.25;

  var length = peaks.length;
  var coef = duration / length;
  var minLen = minSeconds / coef;

  // Gather silence indeces
  var silences = [];
  Array.prototype.forEach.call(peaks, function (val, index) {
    if (val < minValue) {
      silences.push(index);
    }
  });

  // Cluster silence values
  var clusters = [];
  silences.forEach(function (val, index) {
    if (clusters.length && val == silences[index - 1] + 1) {
      clusters[clusters.length - 1].push(val);
    } else {
      clusters.push([ val ]);
    }
  });

  // Filter silence clusters by minimum length
  var fClusters = clusters.filter(function (cluster) {
    return cluster.length >= minLen;
  });

  // Create regions on the edges of silences
  var regions = fClusters.map(function (cluster, index) {
    var next = fClusters[index + 1];
    return {
      start: cluster[cluster.length - 1],
      end: (next ? next[0] : length - 1)
    };
  });

  // Add an initial region if the audio doesn't start with silence
  var firstCluster = fClusters[0];
  if (firstCluster && firstCluster[0] != 0) {
    regions.unshift({
      start: 0,
      end: firstCluster[firstCluster.length - 1]
    });
  }

  // Filter regions by minimum length
  var fRegions = regions.filter(function (reg) {
    return reg.end - reg.start >= minLen;
  });

  // Return time-based regions
  return fRegions.map(function (reg) {
    return {
      start: Math.round(reg.start * coef * 10) / 10,
      end: Math.round(reg.end * coef * 10) / 10
    };
  });
}


function randomColor(alpha) {
  return 'rgba(' + [
    ~~(Math.random() * 255),
    ~~(Math.random() * 255),
    ~~(Math.random() * 255),
    alpha || 1
    ] + ')';
}

function editAnnotation (region) {
  var form = document.forms.edit;
  form.style.opacity = 1;
  form.elements.start.value = Math.round(region.start * 10) / 10,
  form.elements.end.value = Math.round(region.end * 10) / 10;
  form.elements.note.value = region.data.note || '';
  form.onsubmit = function (e) {
    e.preventDefault();
    region.update({
      start: form.elements.start.value,
      end: form.elements.end.value,
      data: {
        note: form.elements.note.value
      }
    });
    form.style.opacity = 0;
  };
  form.onreset = function () {
    form.style.opacity = 0;
    form.dataset.region = null;
  };
  form.dataset.region = region.id;
}

function showNote (region) {
  if (!showNote.el) {
    showNote.el = document.querySelector('#subtitle');
  }
  showNote.el.textContent = region.data.note || '–';
}


// document.addEventListener('keydown', function (e) {
//   var map = {
//     // 32: 'play',       // space
//     // 37: 'back',       // left
//     // 39: 'forth'       // right
//   };
//   var action = map[e.keyCode];
//   if (action in GLOBAL_ACTIONS) {
//     if (document == e.target || document.body == e.target) {
//       e.preventDefault();
//     }
//     GLOBAL_ACTIONS[action](e);
//   }
// });