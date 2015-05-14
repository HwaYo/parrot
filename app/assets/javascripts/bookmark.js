// [{start: Float, end:Float, data:{note:String}}]

if ( typeof (bookmarkHandler) == typeof (undefined)) {
  bookmarkHandler = {};
}

bookmarkHandler = {
  isRecording: false,
  audioTag: [],
  bookmarks: [],
  bookmarkDic: {},
  init: function(isRecording) {
    this.isRecording = isRecording;
    this.addEventListener();
    this.audioTag = document.getElementsByTagName('audio');
  },
  setBookmarks : function(data) {
    this.bookmarks = data;
  },
  addEventListener: function() {
    this.addBookmarkTagEvent();
  },
  giveTransparency: function(color) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(color);
    return 'rgba(' + [
      parseInt(result[1], 16),
      parseInt(result[2], 16),
      parseInt(result[3], 16),
      0.5
      ] +')';
  },
  closeAllBookmarks: function() {
    var time =
        bookmarkHandler.isRecording ? App.recorder.getElapsedTime() : bookmarkHandler.audioTag[0].currentTime.toFixed(1);
    time = parseFloat(time);
    for(var key in bookmarkHandler.bookmarkDic){
      var bookmarkInfo = bookmarkHandler.bookmarkDic[key];
      bookmarkInfo['end'] = time;
      bookmarkHandler.bookmarks.push(bookmarkInfo);
      delete bookmarkHandler.bookmarkDic[key];
    }
  },
  addBookmarkTagEvent: function() {
    $('#note-area').on('click', '.bookmark-tag', function(e) {
      e.preventDefault();
    });
    $("[data-bookmark]").on('click', function(e){

      e.preventDefault();

      var $bookmark = $(this);
      var time =
          bookmarkHandler.isRecording ? App.recorder.getElapsedTime() : bookmarkHandler.audioTag[0].currentTime.toFixed(1);
      time = parseFloat(time);

      // start of the Bookmark
      if( !$bookmark.hasClass("bookmark-active") ) {
        $(this).addClass("bookmark-active");
        $(this).css("background-color",bookmarkHandler.giveTransparency($(this).data('color')));

        var bookmarkInfo = {
          start : time,
          id : $bookmark.data('bookmark'),
          name : $bookmark.data('name'),
          color : $bookmark.data('color'),
        }

        bookmarkHandler.bookmarkDic[$bookmark.data('bookmark')] = bookmarkInfo;
        console.log(bookmarkHandler.bookmarkDic[$bookmark.data('bookmark')]);

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

        if ( !bookmarkHandler.isRecording ) {
          bookmarkHandler.saveBookmark();
          bookmarkHandler.addRegion(bookmarkInfo);
        }
      }
      // end of the Bookmark
      else {
        $(this).removeClass("bookmark-active");
        $(this).css("background-color",'');

        var bookmarkInfo = bookmarkHandler.bookmarkDic[$bookmark.data('bookmark')];
        bookmarkInfo['end'] = time;

        bookmarkHandler.bookmarks.push(bookmarkHandler.bookmarkDic[$bookmark.data('bookmark')]);
        delete bookmarkHandler.bookmarkDic[$bookmark.data('bookmark')]
      }

      console.log(bookmarkInfo);
    });
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
    $.extend(newOption,options)
    newOption.color = bookmarkHandler.giveTransparency(options.color);
    wavesurfer.object.addRegion(newOption);
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
  bookmarkHandler.init(true);

  var timer = {};
  $('#note-area').on('keyup', function(event){
    window.clearInterval(timer);
    timer = window.setInterval(updateNote, 3000);
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