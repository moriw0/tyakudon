import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["startedAt"];

  fetchStartAt() {
    this.startedAtTarget.value = new Date().toISOString();
  }
}
