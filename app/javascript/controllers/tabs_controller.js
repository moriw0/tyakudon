import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tabs"
export default class extends Controller {
  static targets = ["tab"];

  connect() {
    this.highlightCurrentTab();
  }

  highlightCurrentTab() {
    const currentPath = new URL(window.location.href).pathname;

    if (currentPath === "/") {
      const firstTab = this.tabTargets[0];
      firstTab.classList.toggle("selected-tab");
    } else {
      this.tabTargets.forEach((tab) => {
        const tabPath = tab.dataset.path;
        tab.classList.toggle("selected-tab", tabPath === currentPath);
      });
    }
  }
}
