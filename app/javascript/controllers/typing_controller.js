import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="typing"
export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.element.remove();
    }, 3000); //
  }
}
