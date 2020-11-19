class Session {
  constructor(current) {
    this.current = current;
  }

  update(json) {
    let self = this;
    let keys = Object.keys(json);
    keys.forEach((key) => (self.current[key] = json[key]));
  }

  updateTemplate(jquery, template) {
    let self = this;
    jquery.html(template(self.current));
  }
}
