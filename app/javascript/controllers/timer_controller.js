import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="timer"
export default class extends Controller {
  static targets = ["time", "started"];

  connect() {
    const timeElement = this.timeTarget;
    const startedElement = this.startedTarget;

    // Format time in HH:MM:SS.mmm
    const formatTime = (time) => {
      const hours = String(Math.floor(time / 3600)).padStart(2, "0");
      const minutes = String(Math.floor((time % 3600) / 60)).padStart(2, "0");
      const seconds = String(Math.floor(time % 60)).padStart(2, "0");
      const milliseconds = String(time % 1)
        .slice(2, 5)
        .padStart(3, "0");

      return `${hours}:${minutes}:${seconds}.${milliseconds}`;
    };

    // Start timer
    const startTime = new Date(startedElement.value).getTime();
    const updateTimer = () => {
      const currentTime = new Date().getTime();
      const elapsedTime = (currentTime - startTime) / 1000;

      timeElement.innerText = formatTime(elapsedTime);
    };

    this.timer = setInterval(updateTimer, 10);
  }

  end() {
    clearInterval(this.timer);
  }

  disconnect() {
    clearInterval(this.timer);
  }
}
