import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["time", "startedAt", "endedAt", "waitTime"];

  connect() {
    const timeElement = this.timeTarget;
    const startedAtValue = this.startedAtTarget.textContent;

    const formatTime = (time) => {
      const hours = String(Math.floor(time / 3600)).padStart(2, "0");
      const minutes = String(Math.floor((time % 3600) / 60)).padStart(2, "0");
      const seconds = String(Math.floor(time % 60)).padStart(2, "0");
      const milliseconds = String(time % 1)
        .slice(2, 5)
        .padStart(3, "0");

      return `${hours}:${minutes}:${seconds}.${milliseconds}`;
    };

    const startTime = new Date(startedAtValue).getTime();
    const updateTimer = () => {
      const currentTime = new Date().getTime();
      const elapsedTime = (currentTime - startTime) / 1000;

      timeElement.innerText = formatTime(elapsedTime);
    };

    this.timer = setInterval(updateTimer, 1);
  }

  end() {
    clearInterval(this.timer);
    const endedAt = new Date();
    const startedAt = new Date(this.startedAtTarget.textContent);
    const waitTime = (endedAt - startedAt) / 1000;
    this.endedAtTarget.value = endedAt;
    this.waitTimeTarget.value = waitTime;
  }

  disconnect() {
    clearInterval(this.timer);
  }
}
