let map, popup, Popup;
let isDragging = false;
let startY = 0;
let startHeight = 0;

window.initMap = () => {
  class Popup extends google.maps.OverlayView {
    position;
    containerDiv;
    constructor(position, content, url) {
      super();
      this.position = position;

      // Create the anchor tag with content and add the popup-bubble class
      const anchor = document.createElement("a");
      anchor.classList.add("popup-bubble");
      anchor.innerHTML = content;

      // Add click event listener to the anchor tag
      anchor.addEventListener("click", function () {
        fetch(`${url}.json`)
          .then((response) => response.json())
          .then((shop) => {
            const shopInfo = document.getElementById("shop-info");
            const recordsList = shop.records
              .map((record) => {
                const createdAt = new Date(record.created_at);
                const createdAtString = `登録日：${createdAt.getFullYear()}/${
                  createdAt.getMonth() + 1
                }/${createdAt.getDate()} ${createdAt.getHours()}:${createdAt
                  .getMinutes()
                  .toString()
                  .padStart(2, "0")}`;

                const elapsedTimeDate = new Date(record.elapsed_time);
                const elapsedTimeHours = elapsedTimeDate
                  .getUTCHours()
                  .toString()
                  .padStart(2, "0");
                const elapsedTimeMinutes = elapsedTimeDate
                  .getUTCMinutes()
                  .toString()
                  .padStart(2, "0");
                const elapsedTimeSeconds = elapsedTimeDate
                  .getUTCSeconds()
                  .toString()
                  .padStart(2, "0");
                const elapsedTimeMilliseconds = elapsedTimeDate
                  .getUTCMilliseconds()
                  .toString()
                  .padStart(3, "0");
                const elapsedTimeString = `${elapsedTimeHours}:${elapsedTimeMinutes}'${elapsedTimeSeconds}"${elapsedTimeMilliseconds}`;

                return `<li>${createdAtString} - ${elapsedTimeString}</li>`;
              })
              .join("");
            shopInfo.innerHTML = `
                <h3>${shop.name}</h3>
                <p>${shop.address}</p>
                <div class="d-grid gap-2">
                  <a class="btn btn-warning" href="${url}">セツゾク！</a>
                </div>
                <h4>チャクドンレコード</h4>
                <ul>${recordsList}</ul>
              `;
            showBottomSheet();
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

            const closeButton = document.getElementById("close-button");
            closeButton.addEventListener("click", hideBottomSheet);

            const bottomSheet = document.getElementById("bottom-sheet");
            map.addListener("click", hideBottomSheet);

            const dragHandle = document.getElementById("drag-handle");
            dragHandle.addEventListener("mousedown", handleDragStart);
            document.addEventListener("mousemove", handleDragMove);
            document.addEventListener("mouseup", handleDragEnd);
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

function showBottomSheet() {
  const bottomSheet = document.getElementById("bottom-sheet");
  if (bottomSheet.offsetHeight < 50) {
    bottomSheet.style.height = "50vh";
  }
  bottomSheet.classList.remove("hidden");
  bottomSheet.classList.add("shown");
  document.getElementById("map").style.height = "50vh";
}

function hideBottomSheet() {
  const bottomSheet = document.getElementById("bottom-sheet");
  bottomSheet.classList.remove("shown");
  bottomSheet.classList.add("hidden");
  document.getElementById("map").style.height = "100vh";
}
function handleDragStart(event) {
  event.preventDefault();
  isDragging = true;
  startY = event.clientY;
  startHeight = document.getElementById("bottom-sheet").offsetHeight;
}

function handleDragMove(event) {
  if (!isDragging) return;
  const deltaY = event.clientY - startY;
  const newHeight = startHeight - deltaY;
  const mapHeight = 50;
  const maxHeight = window.innerHeight - 56;
  const finalHeight = Math.min(newHeight, maxHeight);
  document.getElementById("bottom-sheet").style.height = `${finalHeight}px`;
  document.getElementById("map").style.height = `${mapHeight}vh`;
}

function handleDragEnd() {
  isDragging = false;
  if (document.getElementById("bottom-sheet").offsetHeight < 50) {
    hideBottomSheet();
  } else if (
    document.getElementById("bottom-sheet").offsetHeight >=
    window.innerHeight - 56
  ) {
    document.getElementById("bottom-sheet").style.height = `${
      window.innerHeight - 56
    }px`;
  } else {
    document.getElementById("bottom-sheet").style.height = "50vh";
  }
}
