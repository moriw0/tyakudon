import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="like"
export default class extends Controller {
  submit(event) {
    event.preventDefault();
    event.stopPropagation();
    this.element.requestSubmit();
  }
}
