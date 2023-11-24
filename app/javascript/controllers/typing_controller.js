import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="typing"
export default class extends Controller {
  static values = {
    timeout: { type: Number, default: 10000 },
  };

  connect() {
    this.element.removeAttribute("hidden");
    this.typeMessage();
  }

  async typeMessage() {
    const message = this.element.textContent;
    this.element.textContent = "";

    for (let i = 0; i < message.length; i++) {
      this.element.textContent += message[i];
      await new Promise((resolve) => setTimeout(resolve, 50));
    }

    await new Promise((resolve) => setTimeout(resolve, this.safeTimeoutValue));

    this.element.remove();
  }

  get safeTimeoutValue() {
    return this.timeoutValue || 10000;
  }
}
