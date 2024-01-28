import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="image-uploader"
export default class extends Controller {
  static targets = ["image", "imagePrev"];
  reader = new FileReader();

  connect() {
    this.reader.onload = () => {
      const display_image = this.reader.result;
      this.imagePrevTarget.setAttribute("src", display_image);
      this.imagePrevTarget.style.display = "block";
    };

    this.reader.onerror = () => {
      alert("ファイルの読み込みに失敗しました");
    };
  }

  displayAfterCheck() {
    if (this.checkImage()) {
      this.displayImage();
    }
  }

  checkImage() {
    const image = this.imageTarget;

    if (image.files[0]) {
      const size_in_megabytes = image.files[0].size / 1024 / 1024;
      if (size_in_megabytes > 9) {
        alert("最大9MBまでアップロード可能です");
        image.value = "";
        return false;
      }
    } else {
      this.hideImage();
      return false;
    }

    return true;
  }

  displayImage() {
    const file = this.imageTarget.files[0];
    this.reader.readAsDataURL(file);
  }

  hideImage() {
    this.imagePrevTarget.setAttribute("src", "");
    this.imagePrevTarget.style.display = "none";
  }
}
