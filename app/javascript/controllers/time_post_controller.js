import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    interval: { type: Number, default: 180000 },
  };

  static targets = ["startedAt"];

  timeoutId = null;

  connect() {
    this.startRepeatingTask();
  }

  disconnect() {
    this.stopRepeatingTask();
    this.clearTimeout();
    this.saveRemainingTime();
  }

  get safeInterval() {
    return this.intervalValue || 180000;
  }

  startRepeatingTask() {
    const remainingTime = this.getRemainingTime();

    if (remainingTime > 0) {
      this.timeoutId = setTimeout(() => {
        this.executeTask();
        this.scheduleNextTask();
      }, remainingTime);
    } else {
      this.scheduleNextTask();
    }
  }

  scheduleNextTask() {
    this.timer = setInterval(() => this.executeTask(), this.safeInterval);
  }

  executeTask() {
    try {
      localStorage.setItem("nextExecuteTime", Date.now() + this.safeInterval);

      const pathArray = window.location.pathname.split("/");
      const recordId = pathArray[pathArray.length - 2];
      this.postCurrentWaitTime(recordId);
    } catch (error) {
      console.error("Error setting nextExecuteTime in localStorage:", error);
    }
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
    }).catch((e) => {
      console.log(e);
    });
  }

  calculateWaitTime() {
    const endedAt = new Date();
    const startedAt = new Date(this.startedAtTarget.textContent);
    return (endedAt - startedAt) / 1000;
  }

  stopRepeatingTask() {
    clearInterval(this.timer);
  }

  clearTimeout() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
  }

  saveRemainingTime() {
    try {
      const remainingTime =
        parseInt(localStorage.getItem("nextExecuteTime"), 10) - Date.now();
      localStorage.setItem(
        "remainingTime",
        remainingTime > 0 ? remainingTime : 0
      );
    } catch (error) {
      console.error("Error saving remaining time to localStorage:", error);
    }
  }

  getRemainingTime() {
    try {
      return parseInt(localStorage.getItem("remainingTime"), 10) || 0;
    } catch (error) {
      console.error(
        "Error retrieving remaining time from localStorage:",
        error
      );
      return 0;
    }
  }
}
