
console.log(current);



      // function getRandomIngredients(event) {
      //   let form = document.querySelector("#random-ingredients");
      //   event.preventDefault();
      //   let xhr = new XMLHttpRequest();
      //   xhr.open("POST", "/add/random/ingredients");
      //   xhr.responseType = "json";
      //   xhr.addEventListener("load", (event) => {
      //     let response = JSON.parse(xhr.response);
      //     console.log(xhr)

      //     refresh('main');
      //     current.flash = null;
      //   });

      //   xhr.send();
      // }

function submitIngredient(event) {
  let form = document.querySelector("#add-ingredients-form");
    event.preventDefault();

    let data = new FormData(form);
    let xhr = new XMLHttpRequest();
    xhr.open("POST", "/add/ingredient");
    xhr.responseType = "json";
    xhr.addEventListener("load", (event) => {
      let response = JSON.parse(xhr.response);
      // current.person.selectedIngredients.push(response.ingredient)
      // current.flash = response.flash
      // current.chosenIngredients = true;
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
    // event.preventDefault();
    if (event.target.id === 'login-form') {

      let login = new XMLHttpRequest();
      login.responseType = "json";
      login.open("POST", "/login");
      login.addEventListener("load", (event) => {
        let response = login.response;
        // current = JSON.parse(response);
        refresh();
        current.flash = null;

      });
      let data = new FormData($form[0]);
      login.send(data);
    } else if (event.target.id === 'add-ingredients-form') {
      // submitIngredient(event);
    } else if (event.target.id === 'random-ingredients') {
      // getRandomIngredients(event);
    }
  });
});