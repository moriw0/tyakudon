import "@hotwired/turbo-rails";
import "controllers";
import * as ActiveStorage from "@rails/activestorage";
ActiveStorage.start();
import "bootstrap";
import { fas } from "@fortawesome/free-solid-svg-icons";
import { far } from "@fortawesome/free-regular-svg-icons";
import { fab } from "@fortawesome/free-brands-svg-icons";
import { library } from "@fortawesome/fontawesome-svg-core";
import "@fortawesome/fontawesome-free";
import "trix";
import "@rails/actiontext";
library.add(fas, far, fab);

window.initMap = () => {
  console.log("initMap was called");
  const event = new CustomEvent("map-loaded", {
    bubbles: true,
    cancelable: true,
  });
  window.dispatchEvent(event);
};
