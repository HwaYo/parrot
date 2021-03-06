// [{start: Float, end:Float, data:{note:String}}]

if ( typeof (bookmarkHandler) == typeof (undefined)) {
  bookmarkHandler = {};
}

bookmarkHandler = {
  audioTag: [],
  bookmarks: [],
  colorList: [],
  maxLen: {},
  bookmarkInfo: {},
  regionInfo: {},
  $currentBookmark: {},
  bookmarkTimer: {},
  init: function() {
    this.addEventListener();
    this.audioTag = document.getElementsByTagName('audio');
    if ( null != document.getElementById('waveform-recorder') )
      this.maxLen = document.getElementById('waveform-recorder').offsetWidth;
  },
  appendColor : function() {
    // add color to colorList index
    if ( null == this.currentBookmark ) {
      this.colorList.push("#000000");
    }
    else {
      this.colorList.push(this.currentBookmark.data('color'));
    }
    // check if its over the player width
    if ( this.colorList.length > this.maxLen ) {
      this.colorList.shift();
    }
  },
  waveformColor : function(place, amplitude) {
    return bookmarkHandler.colorList[place];
  },
  setBookmarks : function(data) {
    this.bookmarks = data;
  },
  addEventListener: function() {
    if( null != document.getElementById('waveform-recorder') ) {
      this.addBookmarkTagEvent();
    } else {
      // Different job done when Playing audio
      this.addBookmarkPlaying();
    }
  },
  giveTransparency: function(color) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(color);
    if ( result == null ) return color;

    return 'rgba(' + [
      parseInt(result[1], 16),
      parseInt(result[2], 16),
      parseInt(result[3], 16),
      0.5
      ] +')';
  },
  getCurrentTime: function() {
    var time = App.recorder ? App.recorder.getElapsedTime() : bookmarkHandler.audioTag[0].currentTime.toFixed(1);
    time = parseFloat(time);
    return time;
  },
  addBookmarkPlaying: function() {
    $('#note-area').on('click', '.bookmark-tag', function(e) {
      e.preventDefault();
    });
    $("[data-bookmark]").on('click', function(e){
      e.preventDefault();

      window.clearInterval(bookmarkHandler.bookmarkTimer);

      // start of the Bookmark
      if( !$(this).hasClass("bookmark-active") ) {
        $(this).addClass("bookmark-active");
        $(this).css("background-color",bookmarkHandler.giveTransparency($(this).data('color')));

        if( bookmarkHandler.currentBookmark != null ) {
          bookmarkHandler.closeBookmark();
        }

        var options = {
          bookmark_id: $(this).data('bookmark'),
          start: bookmarkHandler.getCurrentTime(),
          end: bookmarkHandler.getCurrentTime(),
          color: $(this).data('color'),
          name: $(this).data('name'),
        };

        bookmarkHandler.currentBookmark = $(this);
        bookmarkHandler.bookmarkInfo = options;
        bookmarkHandler.regionInfo = bookmarkHandler.addRegion(options);

        bookmarkHandler.bookmarkTimer = window.setInterval(bookmarkHandler.updateRegionTime,25);
      }
      // end of the boomkark
      else {
        bookmarkHandler.closeBookmark();
        bookmarkHandler.saveBookmark();
      }
    });
  },
  updateRegionTime: function() {

    bookmarkHandler.regionInfo.update({ end: bookmarkHandler.getCurrentTime() });

  },
  addBookmarkTagEvent: function() {
    $('#note-area').on('click', '.bookmark-tag', function(e) {
      e.preventDefault();
    });
    $("[data-bookmark]").on('click', function(e){
      e.preventDefault();

      var $bookmark = $(this);
      var time = bookmarkHandler.getCurrentTime();

      // start of the Bookmark
      if( !$bookmark.hasClass("bookmark-active") ) {
        $(this).addClass("bookmark-active");
        $(this).css("background-color",bookmarkHandler.giveTransparency($(this).data('color')));

        var bookmarkInfo = {
          start : time,
          bookmark_id : $bookmark.data('bookmark'),
          name : $bookmark.data('name'),
          color : $bookmark.data('color'),
        }

        // when no other bookmark is active
        if ( bookmarkHandler.currentBookmark != null ) {
          bookmarkHandler.closeBookmark(time);
        }
        bookmarkHandler.currentBookmark = $(this);
        bookmarkHandler.bookmarkInfo = bookmarkInfo;

        var note = $('#note-area'),
          bookmarkTag = bookmarkHandler.makeBookmarkTag(bookmarkInfo),
          newLine = $('<p/>');

        note.attr('data-placeholder','');

        newLine.html('&nbsp;');
        note.append(bookmarkTag);
        note.append(newLine);

        // Setting Focus to the end of text.
        var range = document.createRange();
        var sel = document.getSelection();
        range.setStartAfter(bookmarkTag[0] ,0);
        range.collapse(true);
        sel.removeAllRanges();
        sel.addRange(range);

        $(window).scrollTop($(document).height());
        note.focus();
      }
      // end of the Bookmark
      else {
        bookmarkHandler.currentBookmark = $(this);
        bookmarkHandler.closeBookmark(time);
      }
    });
  },
  closeBookmark : function(time) {
    if ( time == null ) {
      time = bookmarkHandler.getCurrentTime();
    }
    if(this.currentBookmark != null) {
      this.currentBookmark.removeClass("bookmark-active");
      this.currentBookmark.css("background-color","");
      this.bookmarkInfo['end'] = time;
      this.bookmarks.push(this.bookmarkInfo);
      this.currentBookmark = null;
    }
  },
  makeBookmarkTag: function(bookmarkInfo) {
    var bookmark = $('<p/>'),
        content = $('<a/>')

    content.addClass('bookmark-tag');
    content.attr({
      'href': '',
      'contenteditable': false,
      'data-start': bookmarkInfo.start,
      'data-end': bookmarkInfo.end
    });
    content.text("[" + bookmarkInfo.start + "초] - " + bookmarkInfo.name);
    content.css('color', bookmarkInfo.color);

    bookmark.html(content);
    return bookmark;
  },
  addRegion: function(options) {
    var newOption = {};
    $.extend(newOption,options);
    newOption.color = bookmarkHandler.giveTransparency(options.color);
    return wavesurfer.object.addRegion(newOption);
  },
  saveBookmark: function(options) {
    var recordId = $('#waveform-player').data('id');
    var formData = new FormData();
    formData.append('record[bookmark]', JSON.stringify(this.bookmarks) );
    $.ajax({
        type: 'PUT',
        url: '/records/' + recordId,
        data: formData,
        processData: false,
        contentType: false
    }).done(function(data) {
    });
  }
};

$(document).on('ready page:load', function () {
  bookmarkHandler.init();

  var timer = {};
  $('#note-area').on('keyup', function(event){
    if( !App.recorder ) {
      window.clearInterval(timer);
      timer = window.setInterval(updateNote, 3000);
    }
  });
  updateNote = function() {
    window.clearInterval(timer);

    var recordId = $('#waveform-player').data('id');
    var formData = new FormData();
    formData.append('record[note]', $('#note-area').html() );

    $.ajax({
        type: 'PUT',
        url: '/records/' + recordId,
        data: formData,
        processData: false,
        contentType: false
    }).done(function(data) {
    });

  }
});