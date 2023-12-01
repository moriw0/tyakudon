import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["character"];

  initialize() {
    this.animationInterval = 2000;
  }

  connect() {
    this.intervalId = setInterval(
      () => this.animateCharacter(),
      this.animationInterval
    );

    this.endAnimationListener = () => this.endAnimation();
    document.addEventListener("typing:completed", this.endAnimationListener);
  }

  disconnect() {
    document.removeEventListener("typing:completed", this.endAnimationListener);
  }

  animateCharacter() {
    this.characterTarget.classList.remove("bounceIn", "bounceLoop");
    setTimeout(() => this.addBounceLoop(), 10);
  }

  addBounceLoop() {
    this.characterTarget.classList.add("bounceLoop");
  }

  endAnimation() {
    clearInterval(this.intervalId);
    this.characterTarget.classList.add("character-disappear");

    setTimeout(() => {
      this.disconnect();
      this.characterTarget.remove();
    }, 1000);
  }
}
