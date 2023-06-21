// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
//= require jquery3
//= require popper
//= require bootstrap-sprockets
import "@hotwired/turbo-rails";
import "controllers";

window.initMap = () => {
  console.log("initMap was called");
  const event = new CustomEvent("map-loaded", {
    bubbles: true,
    cancelable: true,
  });
  window.dispatchEvent(event);
};
