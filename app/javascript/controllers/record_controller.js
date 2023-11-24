import { Controller } from "@hotwired/stimulus";
import consumer from "../channels/consumer";

// Connects to data-controller="record"
export default class extends Controller {
  static targets = ["recordId"];

  connect() {
    var pathArray = window.location.pathname.split("/");
    var recordId = pathArray[pathArray.length - 2];

    // let recordId = this.recordIdTarget.textContent.trim();
    this.subscribe(recordId);
    this.repetitionMessage(recordId);
  }

  subscribe(recordId) {
    this.recordChannel = consumer.subscriptions.create(
      {
        channel: "RecordChannel",
        id: recordId,
      },
      {
        connected() {
          console.log("connected", this);
        },
        received(data) {
          console.log(data);
        },
      }
    );
  }

  repetitionMessage(recordId) {
    const messages = ["メッセージ1", "メッセージ2", "メッセージ3"];
    function getRandomMessage() {
      const randomIndex = Math.floor(Math.random() * messages.length);
      return messages[randomIndex];
    }

    const channel = this.recordChannel;
    const message = () => {
      channel.perform("cheer", {
        id: recordId,
        content: getRandomMessage(),
      });
    };

    // message();
    this.timer = setInterval(message, 5000);
  }

  disconnect() {
    this.recordChannel.unsubscribe();
    clearInterval(this.timer);
    console.log("unsubscribed");
  }
}
