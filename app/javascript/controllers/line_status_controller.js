import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="line-status"
export default class extends Controller {
  static targets = ["lineNumberInput"];

  updateNumberInput(event) {
    const lineTypeRadio = event.target;
    const lineNumberInput = this.lineNumberInputTarget;

    if (lineTypeRadio.value === "seated") {
      lineNumberInput.disabled = true;
      lineNumberInput.value = "";
    } else {
      lineNumberInput.disabled = false;
      lineNumberInput.value = "";
    }
  }
}
