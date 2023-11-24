import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["time", "startedAt", "endedAt", "waitTime"];

  connect() {
    const timeElement = this.timeTarget;
    const startedAtValue = this.data.get("startedAt");

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

    const pathArray = window.location.pathname.split("/");
    const recordId = pathArray[pathArray.length - 2];

    //一定周期でwait_timeをpost
    //wait_timeをpost
    setTimeout(() => this.postCurrentWaitTime(recordId), 3000);
  }

  postCurrentWaitTime(recordId) {
    const currentWaitTime = this.calculateWaitTime();
    const token = document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute("content");

    fetch("/cheer_messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
      },
      body: JSON.stringify({
        id: recordId,
        current_wait_time: currentWaitTime,
      }),
    })
      .then((response) => {
        return response.json();
      })
      .then((data) => {
        console.log(data);
      })
      .catch((e) => {
        console.log(e);
      });
  }

  end() {
    clearInterval(this.timer);
    this.calculateWaitTime();
    this.endedAtTarget.value = endedAt;
    this.waitTimeTarget.value = waitTime;
  }

  calculateWaitTime() {
    const endedAt = new Date();
    const startedAt = new Date(this.data.get("startedAt"));
    return (endedAt - startedAt) / 1000;
  }

  disconnect() {
    clearInterval(this.timer);
  }
}
