import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="image-uploader"
export default class extends Controller {
  static targets = ["image"];

  checkImage() {
    let image = this.imageTarget;

    const size_in_megabytes = image.files[0].size / 1024 / 1024;
    if (size_in_megabytes > 5) {
      alert("最大5MBまでアップロード可能です");
      image.value = "";
    }
  }
}
