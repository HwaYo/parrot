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