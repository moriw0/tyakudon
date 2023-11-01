import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="line-status"
export default class extends Controller {
  static targets = ["lineNumberField", "lineNumberInput"];

  updateNumberInput(event) {
    const lineTypeRadio = event.target;
    const lineNumberInput = this.lineNumberInputTarget;
    const lineNumberField = this.lineNumberFieldTarget;

    if (lineTypeRadio.value === "seated") {
      lineNumberField.style.display = "none";
      lineNumberInput.value = 0;
    } else {
      lineNumberField.style.display = "block";
      lineNumberInput.value = "";
    }
  }
}
