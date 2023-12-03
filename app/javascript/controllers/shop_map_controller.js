import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["map"];
  static values = {
    latitude: Number,
    longitude: Number,
    name: String,
  };

  connect() {
    if (window.google) {
      this.createMap();
    }
  }

  async createMap() {
    const position = {
      lat: this.latitudeValue,
      lng: this.longitudeValue,
    };
    this.map = new google.maps.Map(this.mapTarget, {
      center: position,
      zoom: 16,
      mapTypeControl: false,
      streetViewControl: false,
    });

    new google.maps.Marker({
      map: this.map,
      position: position,
      title: this.nameValue,
    });
  }
}
