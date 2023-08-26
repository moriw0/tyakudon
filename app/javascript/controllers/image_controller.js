import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="image"
export default class extends Controller {
  static targets = ["skeleton", "image"];

  connect() {
    const image = this.imageTarget;

    if (image.complete) {
      this.loaded();
    } else {
      image.addEventListener("load", this.loaded.bind(this));
    }
  }

  loaded() {
    const skeleton = this.skeletonTarget;
    skeleton.classList.add("loaded");
    skeleton.style.animation = "none";
  }
}
