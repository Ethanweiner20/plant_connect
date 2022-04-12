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

      request.done(() => {
        $(this).find(".text-success").removeClass("d-none");
      });

      request.fail((data) => {
        const message = $(this).find(".text-danger");
        message.removeClass("d-none");
        message.html(data.responseText);
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
