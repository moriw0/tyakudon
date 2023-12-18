import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="sort-type"
export default class extends Controller {
  static targets = ["type"];

  connect() {
    this.highlightCurrentType();
  }

  highlightCurrentType() {
    const currentUrl = new URL(window.location.href);
    const currentSortType = currentUrl.searchParams.get("sort");

    if (!currentSortType) {
      const firstSortType = this.typeTargets[0];
      firstSortType.classList.toggle("selected-type");
    } else {
      this.typeTargets.forEach((type) => {
        const sortType = type.dataset.type;
        type.classList.toggle("selected-type", sortType === currentSortType);
      });
    }
  }
}
