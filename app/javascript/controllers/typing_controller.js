import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="typing"
export default class extends Controller {
  static values = {
    timeout: { type: Number, default: 10000 },
    typingInterval: { type: Number, default: 50 },
    initialDelay: { type: Number, default: 500 },
  };

  connect() {
    this.showElementAfterDelay();
  }

  showElementAfterDelay() {
    setTimeout(() => {
      this.element.removeAttribute("hidden");
      this.typeMessage();
    }, this.initialDelayValue);
  }

  async typeMessage() {
    const message = this.element.textContent;
    this.element.textContent = "";

    await this.typeCharacters(message);
    await this.completeTyping();
  }

  async typeCharacters(message) {
    for (const char of message) {
      this.element.textContent += char;
      await this.delay(this.typingIntervalValue);
    }
  }

  async completeTyping() {
    await this.delay(this.safeTimeoutValue);
    this.emitTypingCompletedEvent();
    this.element.remove();
  }

  emitTypingCompletedEvent() {
    const event = new CustomEvent("typing:completed", { bubbles: true });
    document.dispatchEvent(event);
  }

  delay(duration) {
    return new Promise((resolve) => setTimeout(resolve, duration));
  }

  get safeTimeoutValue() {
    return this.timeoutValue || 10000;
  }
}
