import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="typing"
export default class extends Controller {
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

    await new Promise((resolve) => setTimeout(resolve, 10000));

    this.element.remove();
  }
}
