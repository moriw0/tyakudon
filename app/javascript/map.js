let map, popup, Popup;
function initMap() {
  class Popup extends google.maps.OverlayView {
    position;
    containerDiv;
    constructor(position, content, url) {
      super();
      this.position = position;

      // Create the anchor tag with content and add the popup-bubble class
      const anchor = document.createElement("a");
      anchor.href = url;
      anchor.classList.add("popup-bubble");
      anchor.innerHTML = content;

      // This zero-height div is positioned at the bottom of the bubble.
      const bubbleAnchor = document.createElement("div");
      bubbleAnchor.classList.add("popup-bubble-anchor");
      bubbleAnchor.appendChild(anchor);

      // This zero-height div is positioned at the bottom of the tip.
      this.containerDiv = document.createElement("div");
      this.containerDiv.classList.add("popup-container");
      this.containerDiv.appendChild(bubbleAnchor);

      // Optionally stop clicks, etc., from bubbling up to the map.
      Popup.preventMapHitsAndGesturesFrom(this.containerDiv);
    }
    /** Called when the popup is added to the map. */
    onAdd() {
      this.getPanes().floatPane.appendChild(this.containerDiv);
    }
    /** Called when the popup is removed from the map. */
    onRemove() {
      if (this.containerDiv.parentElement) {
        this.containerDiv.parentElement.removeChild(this.containerDiv);
      }
    }
    /** Called each frame when the popup needs to draw itself. */
    draw() {
      const divPosition = this.getProjection().fromLatLngToDivPixel(
        this.position
      );
      // Hide the popup when it is far out of view.
      const display =
        Math.abs(divPosition.x) < 4000 && Math.abs(divPosition.y) < 4000
          ? "block"
          : "none";

      if (display === "block") {
        this.containerDiv.style.left = divPosition.x + "px";
        this.containerDiv.style.top = divPosition.y + "px";
      }

      if (this.containerDiv.style.display !== display) {
        this.containerDiv.style.display = display;
      }
    }
  }
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
        // DBから店舗情報を取得
        fetch("/ramen_shops.json")
          .then(function (response) {
            return response.json();
          })
          .then(function (data) {
            // 距離計算
            for (var i = 0; i < data.length; i++) {
              var shopLocation = {
                lat: data[i].latitude,
                lng: data[i].longitude,
              };
              var distance = getDistance(currentLocation, shopLocation);
              // 距離が100m以内の場合、マーカーを地図上に表示
              if (distance <= 500) {
                const url = "/ramen_shops/" + data[i].id;
                popup = new Popup(
                  new google.maps.LatLng(shopLocation.lat, shopLocation.lng),
                  data[i].name,
                  url
                );
                popup.setMap(map);
              }
            }
          })
          .catch(function (e) {
            console.log(e);
            alert("Failed to load shops.");
          });
      },
      function () {
        alert("Failed to get current location.");
      }
    );
  } else {
    alert("Geolocation is not supported by this browser.");
  }
}

window.initMap = initMap;

// 2点間の距離を計算する関数
function getDistance(start, end) {
  var R = 6371; // 地球の半径（km）
  var dLat = ((end.lat - start.lat) * Math.PI) / 180;
  var dLon = ((end.lng - start.lng) * Math.PI) / 180;
  var a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((start.lat * Math.PI) / 180) *
      Math.cos((end.lat * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  var d = R * c; // 2点間の距離（km）
  var distance = d * 1000; // kmからmに変換
  return distance;
}
