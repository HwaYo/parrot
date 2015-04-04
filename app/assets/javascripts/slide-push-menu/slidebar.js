
$("#menu-toggle #dim").on('click', function(e) {
  $("#wrapper").toggleClass("toggled");
  $("#dim").toggleClass("modal-backdrop");
  $("#dim").toggleClass("fade");
  $("#dim").toggleClass("in");
});
