import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="test-mode"
export default class extends Controller {
  static targets = ["modeCheckbox"];

  submitForm(event) {
    event.preventDefault();

    const url = this.element.action;
    const method = this.element.method;
    const data = new FormData(this.element);
    const headers = {
      Accept: "text/vnd.turbo-stream.html",
      "Turbo-Frame": "frame-id",
    };

    fetch(url, {
      method: method,
      body: data,
      headers: headers,
    })
      .then((response) => response.text())
      .then((html) => {
        let parser = new DOMParser();
        let doc = parser.parseFromString(html, "text/html");
        document.body.appendChild(doc.body.firstChild);
      });
  }
}
