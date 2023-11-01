import { Controller } from "@hotwired/stimulus";
import { Popover } from "bootstrap";

// Connects to data-controller="popover"
export default class extends Controller {
  connect() {
    new Popover(this.element);
  }
}
