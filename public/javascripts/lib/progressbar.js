// Generated by CoffeeScript 1.7.1
var ProgressBar;

ProgressBar = (function() {
  function ProgressBar() {}

  ProgressBar.show = function() {
    if ($("#progress").length === 0) {
      $("body").append($("<div><dt/><dd/></div>").attr("id", "progress"));
      return $("#progress").width((50 + Math.random() * 30) + "%");
    }
  };

  ProgressBar.hide = function() {
    return $("#progress").width("101%").delay(200).fadeOut(400, function() {
      return $(this).remove();
    });
  };

  return ProgressBar;

})();

window.ProgressBar = ProgressBar;

$(document).ajaxStart(function() {
  return ProgressBar.show();
});

$(document).ajaxComplete(function() {
  return ProgressBar.hide();
});
