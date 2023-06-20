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
    // 現在地の緯度経度情報を取得
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        function (position) {
          var currentLocation = {
            // lat: 35.64826049515011, lng: 139.74171842709964 //三田本店
            // lat: position.coords.latitude,
            // lng: position.coords.longitude
            lat: 35.7000396,
            lng: 139.7752222,
          };
          // Google Maps APIを使用して地図を表示
          var map = new google.maps.Map(document.getElementById("map"), {
            center: currentLocation,
            zoom: 18,
          });

          google.maps.event.addListenerOnce(map, "idle", function () {
            document.getElementById("loading-spinner").style.display = "none";
          });

          // DBから店舗情報を取得
          fetch(
            `/near_shops.json?lat=${currentLocation.lat}&lng=${currentLocation.lng}`
          )
            .then(function (response) {
              return response.json();
            })
            .then(function (data) {
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
                popup.setMap(map);
              }
            })
            .catch(function (e) {
              console.log(e);
              alert("ショップ情報が取得できませんでした");
            });
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
}
