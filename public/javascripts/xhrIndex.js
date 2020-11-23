function submitIngredient(event) {
  let form = document.querySelector("#add-ingredients-form");
    event.preventDefault();

    let data = new FormData(form);
    let xhr = new XMLHttpRequest();
    xhr.open("POST", "/add/ingredient");
    xhr.responseType = "json";
    xhr.addEventListener("load", (event) => {
      let response = JSON.parse(xhr.response);

      refresh();
      current.flash = null;
    });
    xhr.send(data);
};

refresh();

document.addEventListener("DOMContentLoaded", () => {
  $('a.create-account').click(function(event) {
    event.preventDefault();
    $('#login-form').replaceWith(createAccountTemplate($('#createAccount').html()))
  })

  $(document).submit(function (event) {
    if (event.target.id === 'login-form') {

      let login = new XMLHttpRequest();
      login.responseType = "json";
      login.open("POST", "/login");
      login.addEventListener("load", (event) => {
        let response = login.response;
        refresh();
        current.flash = null;

      });
      let data = new FormData($form[0]);
      login.send(data);
    }
  });
});