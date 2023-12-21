import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="checkboxes"
export default class extends Controller {
  static targets = ["toggleAllCheckbox"];

  toggle() {
    const checkboxes = this.element.querySelectorAll("input[type=checkbox]");
    const isChecked = this.toggleAllCheckboxTarget.checked;

    checkboxes.forEach((checkbox) => (checkbox.checked = isChecked));
  }
}
