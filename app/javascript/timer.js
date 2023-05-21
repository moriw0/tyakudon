document.addEventListener("turbo:load", () => {
  let timer;
  const timeElement = document.getElementById("time");
  const startedElement = document.getElementById("started");
  const endedElement = document.getElementById("ended");

  window.history.replaceState(null, null, "/search");

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

  // Start the timer and update it every 50ms
  timer = setInterval(updateTimer, 10);

  // When 'ちゃくどん' button is clicked
  endedElement.addEventListener("click", () => {
    clearInterval(timer);
  });
});
