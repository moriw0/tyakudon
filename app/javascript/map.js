let map, popup, Popup;

window.initMap = () => {
  class Popup extends google.maps.OverlayView {
    position;
    containerDiv;
    constructor(position, shopName, url) {
      super();
      this.position = position;

      // Create the anchor tag with content and add the popup-bubble class
      const anchor = document.createElement("a");
      anchor.classList.add("popup-bubble");
      anchor.innerHTML = shopName;

      // Add click event listener to the anchor tag
      anchor.addEventListener("click", function (event) {
        event.preventDefault();
        Turbo.visit(`${url}/records/new`, {
          action: "replace",
          frame: "modal",
        });
      });

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
              popup = new Popup(
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
        alert("現在地が取得できませんでした");
      }
    );
  } else {
    alert("お使いのブラウザではサポートされていません");
  }
};
