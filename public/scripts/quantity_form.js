$(document).ready(function () {
  $(".add-plant-form")
    .unbind("submit")
    .bind("submit", function (event) {
      event.preventDefault();
      event.stopPropagation();

      const spinner = $(this).find(".spinner-border");
      spinner.css("display", "inline-block");

      const url = $(this).attr("action");
      const data = $(this).serialize();
      const request = $.post(url, data);

      request.done(() => {
        spinner.css("display", "none");
        $(this).find("button").html("Added!");
      });
    });

  $(".update-quantity-form")
    .unbind("submit")
    .bind("submit", function (event) {
      event.preventDefault();
      event.stopPropagation();

      const spinner = $(this).find(".spinner-border");
      spinner.css("display", "inline-block");

      const url = $(this).attr("action");
      const data = $(this).serialize();
      const request = $.post(url, data);

      request.done(() => {
        spinner.css("display", "none");
        $(this).find("button").html("Updated!");
      });
    });

  $(".delete-plant-form")
    .unbind("submit")
    .bind("submit", function (event) {
      event.preventDefault();
      event.stopPropagation();

      const url = $(this).attr("action");
      const data = $(this).serialize();
      const request = $.post(url, data);

      request.done(() => {
        $(this).find("button").html("Deleted!");
      });
    });
});
