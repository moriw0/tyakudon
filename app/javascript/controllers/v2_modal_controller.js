import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.body.style.overflow = "hidden"
  }

  disconnect() {
    document.body.style.overflow = ""
  }

  close(event) {
    event.preventDefault()
    this.element.outerHTML = '<div id="modal"></div>'
  }
}
