if ( typeof (bookmarkHandler) == typeof (undefined)) {
  bookmarkHandler = {};
}

bookmarkHandler = {
  isRecording: false,
  audioTag: [],
  bookmarks: [],
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
  addBookmarkTagEvent: function() {

    $("[data-bookmark]").on('click', function(e){

      e.preventDefault();
      var time = 
          bookmarkHandler.isRecording ? App.runningTime/10 : bookmarkHandler.audioTag[0].currentTime.toFixed(1);
      time = parseFloat(time);

      var $bookmark = $(this),
          bookmarkInfo = {
            start : time,
            end : time + 0.5,
            name : $bookmark.data('name'),
            color : $bookmark.data('color'),
          },
          note = $('#note-area'),
          bookmarkTag = bookmarkHandler.makeBookmarkTag(bookmarkInfo),
          newLine = $('<p/>');
      console.log('$bookmark.data("color")');
      console.log($bookmark.data('color'));
      console.log('bookmarkInfo');
      console.dir(bookmarkInfo);
      bookmarkHandler.bookmarks.push(bookmarkInfo);

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
    newOption.color = wavesurfer.giveTransparency(options.color);
    wavesurfer.object.addRegion(newOption);
  },
  saveBookmark: function(options) {
    var recordId = $('#waveform-player').data('id');
    var formData = new FormData();
    console.log(JSON.stringify(this.bookmarks));
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
});