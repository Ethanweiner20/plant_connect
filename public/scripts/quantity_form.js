$(document).ready(function () {
  $(".quantity-form")
    .unbind("submit")
    .bind("submit", function (event) {
      event.preventDefault();
      event.stopPropagation();

      const spinner = $(this).find(".spinner-border");
      spinner.css("display", "inline-block");

      const url = $(this).attr("action");
      const data = $(this).serialize();
      const request = $.post(url, data);

      const successMessage = $(this).find(".text-success");
      const errorMessage = $(this).find(".text-danger");

      request.done(() => {
        errorMessage.addClass("d-none");
        successMessage.removeClass("d-none");
      });

      request.fail((data) => {
        successMessage.addClass("d-none");
        errorMessage.removeClass("d-none");
        errorMessage.html(data.responseText);
      });

      request.always(() => {
        spinner.css("display", "none");
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
