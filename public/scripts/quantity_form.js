$(document).ready(function () {
  $(".add-plant-form .update-quantity-form")
    .unbind("submit")
    .bind("submit", function (event) {
      event.preventDefault();
      event.stopPropagation();

      const spinner = $(this).find(".spinner-border");
      spinner.css("display", "inline-block");

      const url = $(this).attr("action");
      const data = $(this).serialize();
      const request = $.post(url, data);

      request.done(function () {
        spinner.css("display", "none");
      });
    });
});
