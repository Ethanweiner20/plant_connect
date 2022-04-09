$(document).ready(function () {
  $("form.plant-search").submit(function (event) {
    event.preventDefault();
    const spinner = $("form.plant-search .spinner-border");
    spinner.css("display", "inline-block");
    const formData = $(this).serialize();

    const response = $.get("/plants", formData);

    response.done(function (data) {
      $(".plants").html(data);
      spinner.css("display", "none");
    });

    response.fail(function (response, textStatus, error) {
      if (response.status == 302) {
        window.location.href = response.responseText;
      } else {
        throw Error(error);
      }
      spinner.css("display", "none");
    });
  });

  $(".filters").on("click", "a.delete", function () {
    $(this).parent().parent().remove();
  });

  function addTextInput(name) {
    const inputName = name.replace(/\s/g, "");

    $("div.filters").append(`
      <div class="col-sm-6 col-md-4 col-lg-3 col-12">
        <label for="${inputName}">
          ${name}
          <a class="btn btn-link delete text-danger">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-trash" viewBox="0 0 16 16">
              <path d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0V6z"/>
              <path fill-rule="evenodd" d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1v1zM4.118 4 4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z"/>
            </svg>
          </a>
        </label>
        <input type="text" name="${inputName}" id="${inputName}" class="form-control" placeholder="${inputName}" />
      </div>`);
  }

  function checkboxHTML(name, option) {
    return `
    <div class="form-check">
      <input type="checkbox" class="form-check-input" id="${option}" name="${name}[]" value="${option}"/>
      <label class="form-check-label" for="${option}">${option}
      </label>
    </div>
    `;
  }

  function addCheckboxInput(name, options) {
    const inputName = name.replace(/\s/g, "");

    const html = `
    <div class="col-sm-6 col-md-4 col-lg-3 col-12">
      <label>
      ${name}
        <a class="btn btn-link delete text-danger">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-trash" viewBox="0 0 16 16">
              <path d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0V6z"/>
              <path fill-rule="evenodd" d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1v1zM4.118 4 4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z"/>
            </svg>
          </a>
      </label>
      ${options.map((value) => checkboxHTML(inputName, value)).join("")}
    </div>
    `;

    $("div.filters").append(html);
  }

  $("a.add-text-input").click(function (event) {
    event.preventDefault();
    const inputName = $(this).attr("data-input-name");
    addTextInput(inputName);
  });

  $("a.add-checkbox-input").click(function (event) {
    event.preventDefault();
    const inputName = $(this).attr("data-input-name");
    const options = $(this).attr("data-options").split(", ");
    addCheckboxInput(inputName, options);
  });
});
