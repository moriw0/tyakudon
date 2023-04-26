let map, popup, Popup;
function initMap() {
  const shop = { lat: 35.64826049515011, lng: 139.74171842709964 };
  map = new google.maps.Map(document.getElementById("map"), {
    center: shop,
    zoom: 18,
  });

  class Popup extends google.maps.OverlayView {
    position;
    containerDiv;
    constructor(position, content) {
      super();
      this.position = position;

      const contentDiv = document.createElement("div");
      contentDiv.classList.add("popup-bubble");
      contentDiv.innerHTML = content;

      const bubbleAnchor = document.createElement("div");
      bubbleAnchor.classList.add("popup-bubble-anchor");
      bubbleAnchor.appendChild(contentDiv);

      this.containerDiv = document.createElement("div");
      this.containerDiv.classList.add("popup-container");
      this.containerDiv.appendChild(bubbleAnchor);

      Popup.preventMapHitsAndGesturesFrom(this.containerDiv);
    }
    onAdd() {
      this.getPanes().floatPane.appendChild(this.containerDiv);
    }
    onRemove() {
      if (this.containerDiv.parentElement) {
        this.containerDiv.parentElement.removeChild(this.containerDiv);
      }
    }
    draw() {
      const divPosition = this.getProjection().fromLatLngToDivPixel(
        this.position
      );
      const display =
        Math.abs(divPosition.x) < 4000 && Math.abs(divPosition.y) < 4000
          ? "block"
          : "none";

      if (display === "block") {
        this.containerDiv.style.left = divPosition.x + "px";
        this.containerDiv.style.top = divPosition.y + "px";
      }

      if (this.containerDiv.style.display !== display) {
        this.containerDiv.style;
        this.containerDiv.style.display = display;
      }
    }
  }

  popup = new Popup(new google.maps.LatLng(shop.lat, shop.lng), "Hello world!");
  popup.setMap(map);
}

window.initMap = initMap;
