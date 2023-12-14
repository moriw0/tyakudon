import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tabs"
export default class extends Controller {
  static targets = ["tab"];

  connect() {
    this.highlightCurrentTab();
  }

  highlightCurrentTab() {
    const currentPath = window.location.pathname;

    this.tabTargets.forEach((tab) => {
      const tabPath = tab.dataset.path;
      tab.classList.toggle("selected-tab", tabPath === currentPath);
    });
  }
}
