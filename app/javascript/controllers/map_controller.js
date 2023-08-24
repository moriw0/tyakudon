import { Controller } from "@hotwired/stimulus";
import { Popup } from "popup";

export default class extends Controller {
  static targets = ["map", "spinner", "isTestMode"];

  connect() {
    if (window.google) {
      this.createMap();
    }
  }

  createMap() {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          let currentLocation;
          let isTestMode = this.isTestModeTarget.dataset.value === "true";
          if (isTestMode) {
            currentLocation = {
              lat: 35.7000396,
              lng: 139.7752222,
            };
          } else {
            currentLocation = {
              lat: position.coords.latitude,
              lng: position.coords.longitude,
            };
          }

          this.map = new google.maps.Map(this.mapTarget, {
            center: currentLocation,
            zoom: 18,
          });

          this.spinnerTarget.style.display = "none";
          this.mapTarget.style.display = "block";

          this.fetchNearShops(currentLocation);
        },
        (error) => {
          this.spinnerTarget.style.display = "none";
          console.error("現在地の取得中にエラーが発生しました:", error);
          alert("現在地が取得できませんでした");
        }
      );
    } else {
      this.spinnerTarget.style.display = "none";
      alert("お使いのブラウザではサポートされていません");
    }
  }

  fetchNearShops(location) {
    fetch(`/near_shops.json?lat=${location.lat}&lng=${location.lng}`)
      .then((response) => {
        return response.json();
      })
      .then((data) => {
        this.createPopups(data);
      })
      .catch((e) => {
        console.log(e);
        alert("ショップ情報が取得できませんでした");
      });
  }

  createPopups(data) {
    for (let i = 0; i < data.length; i++) {
      const shopLocation = {
        lat: data[i].latitude,
        lng: data[i].longitude,
      };
      const url = `/ramen_shops/${data[i].id}`;
      const popup = new Popup(
        new google.maps.LatLng(shopLocation.lat, shopLocation.lng),
        data[i].name,
        url
      );
      popup.setMap(this.map);
    }
  }
}
