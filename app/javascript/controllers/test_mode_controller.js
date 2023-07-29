import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="test-mode"
export default class extends Controller {
  static targets = ["modeCheckbox"];

  submitForm() {
    this.element.submit();
  }
}
