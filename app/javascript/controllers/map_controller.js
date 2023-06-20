import { Controller } from "@hotwired/stimulus";
import { Popup } from "popup";

export default class extends Controller {
  static targets = ["map"];

  connect() {
    console.log("mapController connected");

    if (window.google) {
      this.initializeMap();
    }
  }

  initializeMap() {
    this.setupMap();
    this.fetchCurrentLocation();
    console.log("init");
  }

  setupMap() {
    // 地図の初期化を行います。ここでは、仮に一つの中心座標を設定します。
    const initialLocation = {
      lat: 35.7000396,
      lng: 139.7752222,
    };
    this.map = new google.maps.Map(this.mapTarget, {
      center: initialLocation,
      zoom: 18,
    });
  }

  fetchCurrentLocation() {
    // Put the code related to fetching current location here...
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          var currentLocation = {
            // lat: position.coords.latitude,
            // lng: position.coords.longitude,
            lat: 35.7000396,
            lng: 139.7752222,
          };

          // Fetch shop information
          this.fetchNearShops(currentLocation);
        },
        function () {
          document.getElementById("loading-spinner").style.display = "none";
          alert("現在地が取得できませんでした");
        }
      );
    } else {
      document.getElementById("loading-spinner").style.display = "none";
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
    for (var i = 0; i < data.length; i++) {
      var shopLocation = {
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
