
const theHeader = `<nav class="navigation" id='navigation'>
    {{#if loggedIn}}
      <a class='menu-item active' href="/">Home</a>
      <a class='menu-item'href="/profile">{{person.name}}'s Profile</a>
      <a class='menu-item' href="/photos">Submissions</a>
      <a class='menu-item' href="/logout">Log Out</a>
    {{else}}
        <a class='menu-item active' href="/" >Sign In</a>
        <a class='menu-item create-account' href="/create-account">Create A New Account</a>
    {{/if}}

      <a href="javascript:void(0)" class='icon' onclick="toggleMenu()">
        <i class='fa fa-bars'></i>
      </a>
  </nav>`;
const theMain = `{{#if flash}}
        <section id='flash-message'>
          <h4>{{flash.message}}</h4>
          <h4>{{flash.action}}</h4>
        </section>
      {{/if}}
      {{#if person}}
        <h1 class='section-heading'>What would you like to do?</h1>
        <blockquote class='individual-name'>{{person.name}}</blockquote>
        <section class='ingredients'>
          <h2 class='section-heading'>Added Ingredients:</h2>
          {{#each person.selectedIngredients}}
            <p class='single-ingredient'>{{name}}</p>
          {{/each}}
        </section>
        <section class='add-ingredient'>
          <form id='add-ingredients-form' action="/add/ingredient" method="POST">
            <section class='form-input'>
              <label for="ingredient">Add Ingredient:</label>
              <input id="add-ingredient" name="ingredient" type="text" placeholder='name'>
            </section>
            <section class='form-input'>
              <button type="submit" class='add-button'>+</button>
            </section>
          </form>
        </section>
        <section class='ingredients'>
          <h2 class='section-heading'>Random Ingredients</h2>
          {{#if person.randomIngredients}}
            {{#each person.randomIngredients}}
              <p class='single-ingredient'>{{name}}</p>
            {{/each}}
          {{else}}
            <form id='random-ingredients' action="/add/random/ingredients" method='POST'>
              <button id='assign-ingredients' type='submit'></button>Get Random Ingredients!</button>
            </form>
          {{/if}}
        </section>
      {{/if }}`;
const theLogin = `{{#if flash}}
    <section id='flash-message'>
      <h4>{{flash.message}}</h4>
      <h4>{{flash.action}}</h4>
    </section>
  {{/if}}
  <section class='login'>
    <form id='login-form' action="/login" method="POST">
      <section class='form-input'>
        <label for="username">Username:</label>
        <input id="username" name="username" type="text">
      </section>
      <section class='form-input'>
        <label for="password">Password:</label>
        <input id="password" name="password" type="password">
      </section>
      <section class='form-input'>
        <button type="submit" id="login-button">Login</button>
      </section>
    </form>

    <a class='create-account' href="#">Create Account</a>
  </section>`;
const theCreateAccount = `<form class='create-account' action="/create/account" method="POST">
            <input class='form-input' type="text" name="username" placeholder="Username" />
            <input class='form-input' type="password" name="password" placeholder="Password" />
            <input class='form-input' type="password" name="password2" placeholder="Password2" />
            <input class='form-input' type="submit" name="button" value="Create Account" />
      </form>`;
const theProfile = `<script id='profileTemplate' type='text/x-handlebars'>
      <blockquote class='individual-name'>{{person.name}}</blockquote>
    </script>`;

const theUploadForm = `<h1 class='section-heading'>Upload Form</h1>
  <form id="image-upload" action="/add/image" method="POST">
    <input type="file" name="image" id="image" required>
    <input type="text" name="name" id="name" required>
    <input type="hidden" id="imageData" name="imageData" required>
    <button type="submit">Upload Image</button>
  </form>`
const mainTemplate = Handlebars.compile(theMain);
const headerTemplate = Handlebars.compile(theHeader);
const loginTemplate = Handlebars.compile(theLogin);
const createAccountTemplate = Handlebars.compile(theCreateAccount);
const uploadFormTemplate = Handlebars.compile(theUploadForm);
// const photosTemplate = Handlebars.compile(thePhotos)     
current = JSON.parse($('#current')[0].textContent);
function refresh(scope) {
  if (scope === "header") {
    $("header").html(headerTemplate(current));
  } else if (scope === "images") {
    // $(".photo-gallery").html(imagesTemplate(current));
  } else if (scope === "main") {
    if (current["loggedIn"]) {
      $("main").addClass("logged-in").html(mainTemplate(current));
    } else {
      $("main").removeClass("logged-in").html(loginTemplate(current));
    }
  } else if (scope === 'upload-form') {
    $('#image-upload').show().closest('h1').show()
    $('#upload-button').css('display', 'none');
    console.log($('h1').last().attr('css'))
  } else if (scope === undefined) {
    refresh("header");
    refresh("main");
  }
}