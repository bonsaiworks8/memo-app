$(function () {
  $(".js_mobileNavMenuClosePanel").click(
    function () {
      $(".js_mobileNavMenu").removeClass("is_open");
      $(".js_mobileNavMenu").addClass("is_close");
      $(".js_mobileNavMenuClosePanel").hide();
    }
  );

  $(".js_hamburgerIcon").click(
    function () {
      $(".js_mobileNavMenu").addClass("is_open");
      $(".js_mobileNavMenu").removeClass("is_close");
      $(".js_mobileNavMenuClosePanel").show();
    }
  );
});
