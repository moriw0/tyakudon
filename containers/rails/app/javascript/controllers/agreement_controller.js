import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="agreement"
export default class extends Controller {
  static targets = ["checkbox", "submitButton"];

  updateButtonState() {
    const checkbox = this.checkboxTarget;
    const submitButton = this.submitButtonTarget;

    if (checkbox.checked) {
      submitButton.removeAttribute("disabled");
    } else {
      submitButton.setAttribute("disabled", true);
    }
  }
}
