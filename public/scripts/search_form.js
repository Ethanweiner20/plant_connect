$(document).ready(function () {
  // Show loading spinner on submission
  $('button[type="submit"]').click(function () {
    $(this).children(".spinner-border").css("display", "inline-block");
  });

  function addTextInput(name) {
    const inputName = name.replace(/\s/g, "");

    $("div.filters").append(`
      <div class="col-sm-6 col-md-4 col-lg-3 col-12">
        <label for="${inputName}">${name}</label>
        <input type="text" name="${inputName}" id="${inputName}" class="form-control" placeholder="${inputName}" />
      </div>`);
  }

  function checkboxHTML(name, option) {
    return `
    <div class="form-check">
      <input type="checkbox" class="form-check-input" id="${option}" name="${name}[]" value="${option}"/>
      <label class="form-check-label" for="${option}">${option}</label>
    </div>
    `;
  }

  function addCheckboxInput(name, options) {
    const inputName = name.replace(/\s/g, "");

    const html = `
    <div class="col-sm-6 col-md-4 col-lg-3 col-12">
      <label>${name}</label>
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
