import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="like"
export default class extends Controller {
  static values = { url: String };

  submit(event) {
    event.preventDefault();
    event.stopPropagation();
    this.element.requestSubmit();
  }

  redirect() {
    window.location.href = this.urlValue;
  }
}
