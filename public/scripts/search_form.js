$(document).ready(function () {
  // Plant form submission
  $("form.plant-search").submit(function (event) {
    const spinner = $("form.plant-search .spinner-border");
    spinner.css("display", "inline-block");
  });

  // Filter deletion
  $(".filters").on("click", "a.delete", function () {
    $(this).parent().parent().remove();
  });

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
  $("a.add-states-input").click(function (event) {
    event.preventDefault();
    addStatesInput();
  });
});

const deleteLinkHTML = `
  <a class="btn btn-link delete text-danger">
  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-trash" viewBox="0 0 16 16">
    <path d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0V6z"/>
    <path fill-rule="evenodd" d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1v1zM4.118 4 4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z"/>
  </svg>
  </a>
`;

// Add inputs
function addTextInput(name) {
  const label = name.charAt(0).toUpperCase() + name.replace("_", " ").slice(1);

  $("div.filters").append(`
    <div class="col-sm-6 col-md-4 col-lg-3 col-12">
      <label for="${name}">${label}${deleteLinkHTML}</label>
      <input type="text" name="${name}" id="${name}" class="form-control" placeholder="${label}" />
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
  const label = name.charAt(0).toUpperCase() + name.replace("_", " ").slice(1);

  const html = `
  <div class="col-sm-6 col-md-4 col-lg-3 col-12">
    <label>${label}${deleteLinkHTML}</label>
    ${options.map((value) => checkboxHTML(name, value)).join("")}
  </div>
  `;

  $("div.filters").append(html);
}

function addStatesInput() {
  const selectHTML = `
  <select name="State[]" multiple>
    <option>AK</option>
    <option>AL</option>
    <option>AR</option>
    <option>AZ</option>
    <option>CA</option>
    <option>CO</option>
    <option>CT</option>
    <option>DC</option>
    <option>DE</option>
    <option>FL</option>
    <option>GA</option>
    <option>HI</option>
    <option>IA</option>
    <option>ID</option>
    <option>IL</option>
    <option>IN</option>
    <option>KS</option>
    <option>KY</option>
    <option>LA</option>
    <option>MA</option>
    <option>MD</option>
    <option>ME</option>
    <option>MI</option>
    <option>MN</option>
    <option>MO</option>
    <option>MS</option>
    <option>MT</option>
    <option>NC</option>
    <option>ND</option>
    <option>NE</option>
    <option>NH</option>
    <option>NJ</option>
    <option>NM</option>
    <option>NV</option>
    <option>NY</option>
    <option>OH</option>
    <option>OK</option>
    <option>OR</option>
    <option>PA</option>
    <option>RI</option>
    <option>SC</option>
    <option>SD</option>
    <option>TN</option>
    <option>TX</option>
    <option>UT</option>
    <option>VA</option>
    <option>VT</option>
    <option>WA</option>
    <option>WI</option>
    <option>WV</option>
    <option>WY</option>
  </select>`;

  const html = `
  <div class="col-sm-6 col-md-4 col-lg-3 col-12">
    <label>States${deleteLinkHTML}</label>
    ${selectHTML}
  </div>
  `;

  $("div.filters").append(html);
}
