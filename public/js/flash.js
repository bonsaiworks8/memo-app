$(function () {
  $(".js_flash").removeClass("is_close");
  $(".js_flash").addClass("is_open");

  $(".js_flash_closeIcon").click(
    function () {
      $(".js_flash").removeClass("is_open");
      $(".js_flash").addClass("is_close");
    }
  );
});
