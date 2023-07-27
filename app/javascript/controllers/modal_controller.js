import { Controller } from "@hotwired/stimulus";
import { Modal } from "bootstrap";

export default class extends Controller {
  static targets = ["startedAt"];

  connect() {
    this.modal = new Modal(this.element);
    this.modal.show();
  }

  fetchStartAt() {
    const startedAt = new Date();
    this.startedAtTarget.value = startedAt;
  }

  close(event) {
    if (event.detail.success) {
      this.modal.hide();
    }
  }
}
