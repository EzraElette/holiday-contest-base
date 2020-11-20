  const sessionTemplate = {
    flash: { message: 'test message', action: 'do nothing' },
    person: {
      name: "Rodney",
      selectedIngredients: [
        { name: "Turkey", details: "info" },
        { name: "Yam" },
        { name: "Pie" },
      ],
    },
    loggedIn: true,      
  };
let PrivateData = (function (template) {
  let current;
  class UserInterface {
    constructor({ flash, person, selectedIngredients, randomIngredients, loggedIn }) {
      this.flash = flash;
      this.person = person;
      this.selectedIngredients = selectedIngredients;
      this.randomIngredients = randomIngredients;
      this.loggedIn = loggedIn;
    }

    makeUpdate(json) {
      let keys = Object.keys(json);
      let subkeys = keys.map(key => Object.keys(json[key]))
      for (let index = 0; index < keys.length; index++) {
        for (let idx = 0; idx < subkeys[index].length; idx++) {
          let currentKey = keys[index];
          let currentSubkey = subkeys[idx];
          let currentValue = json[currentKey][currentSubkey]
          this.update(currentKey, currentSubkey, currentValue);
        }
      }
    }
    update(key, property, value) {
      if (!this.isLoggedIn()) return;
      if (this[key] === undefined || this[key][property] === undefined) {
        this.flashMessage("sorry, we couldn't find that", "please try adding that first")
      } else {
        this[key][property] = value;
        this.flashMessage('successfully updated', 'you can change more!')
      }
    }
    create(key, property, value) {
      if (!this.isLoggedIn()) return;
      if (this[key][property]) {
        this.flashMessage('cannon create this property', 'please try again')
      } else {
        this[key][property] = value;
        this.flashMessage(`${value} was added to the database`, 'You can add more!')
      }
    }

    read(key, property) {
      if (key && property) {
        return this[key][property];
      } else if (!property) {
        return this[key]
      } else if (!key) {
        return this;
      }
    }

    flashMessage(message, action) {
      this.flash = { message, action };
    }

    resetFlash() {
      this.flash = null;
    }

    login() {
      this.login = true;
    }

    isLoggedIn() {
      if (!this.loggedIn) {
        this.flashMessage('You cannot perform this action', 'please log in')
      } else {
        return true;
      }
    }
  }

  class Session {
    constructor() {
      current = new UserInterface(template);
    }
    update(json) {
      current.makeUpdate(json)
    }

    logUserIn(json) {
      current = new UserInterface(json)
    }

    find(property, subproperty) {
      return current.read(property, subproperty)
    }

    updateTemplate(jquery, template) {
      jquery.html(template(current));
    }
  }
  
  return new Session()

})({})


// testing --- expected outputs 



console.log(PrivateData.logUserIn(sessionTemplate))  // Session {}
// console.log(PrivateData.find('person', 'name'));
// PrivateData.update({ person: { name: 'ezra' } });
// console.log(Object.getOwnPropertyNames(PrivateData)); // []
// PrivateData.logUserIn(sessionTemplate)

// console.log(PrivateData) // Session {}

// PrivateData.update({ person: { name: 'ezra' } });

// console.log(PrivateData.find('person', 'name')); // ezra
