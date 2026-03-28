import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  navigate() {
    if (!navigator.geolocation) {
      alert("お使いのブラウザでは位置情報がサポートされていません");
      return;
    }
    navigator.geolocation.getCurrentPosition(
      (position) => {
        const lat = position.coords.latitude;
        const lng = position.coords.longitude;
        window.location = `/near_shops?lat=${lat}&lng=${lng}`;
      },
      () => {
        alert("現在地が取得できませんでした");
      }
    );
  }
}
