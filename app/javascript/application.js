import "@hotwired/turbo-rails";
import "controllers";
import "bootstrap";

window.initMap = () => {
  console.log("initMap was called");
  const event = new CustomEvent("map-loaded", {
    bubbles: true,
    cancelable: true,
  });
  window.dispatchEvent(event);
};
