document.addEventListener("turbo:load", () => {
  const elapsedTimeEl = document.getElementById("time");
  const startBtn = document.getElementById("start");
  const stopBtn = document.getElementById("stop");
  const endBtn = document.getElementById("end");
  const retireBtn = document.getElementById("retire");
  const resetBtn = document.getElementById("reset");

  let startTime;
  let elapsedTime;
  let storedElapsedTime = Number(localStorage.stored_elapsed_time) || 0;
  let timerID;

  // 経過時間をフォーマットする関数
  const formatElapsedTime = (time) => {
    const h = String(time.getUTCHours()).padStart(2, '0');
    const m = String(time.getUTCMinutes()).padStart(2, '0');
    const s = String(time.getUTCSeconds()).padStart(2, '0');
    const ms = String(time.getUTCMilliseconds()).padStart(3, '0');

    return `${h}:${m}:${s}.${ms}`;
  };

  // 経過時間を更新する関数
  const updateElapsedTime = () => {
    const currentTime = Date.now()
    elapsedTime = new Date(currentTime - startTime + storedElapsedTime);
    elapsedTimeEl.textContent = formatElapsedTime(elapsedTime);
  };

  const startTimer = () => {
    startBtn.disabled = true;
    stopBtn.disabled = false;
    endBtn.disabled = false;
    resetBtn.disabled = true;
    retireBtn.disabled = true;
    startTime = Date.now()
    timerID = setInterval(updateElapsedTime, 10);
  }

  const stopTimer = () => {
    startBtn.disabled = false;
    stopBtn.disabled = true;
    endBtn.disabled = true;
    resetBtn.disabled = false;
    retireBtn.disabled = false;
    clearInterval(timerID);
    storedElapsedTime += (Date.now() - startTime);
    // submitElapsedTime("stop");
  }

  const resetTimer = () => {
    startBtn.disabled = false;
    stopBtn.disabled = true;
    endBtn.disabled = true;
    resetBtn.disabled = true;
    retireBtn.disabled = true;
    elapsedTimeEl.textContent = "00:00:00.000";
    clearInterval(timerID);
    localStorage.removeItem("stored_elapsed_time");
    storedElapsedTime = 0;
    elapsedTime = 0;
  }

  startBtn.addEventListener("click", startTimer);
  stopBtn.addEventListener("click", stopTimer);
  resetBtn.addEventListener("click", resetTimer);

  // リタイアボタンを押したときの処理
  retireBtn.addEventListener("click", () => {
    clearInterval(timerID);
    // submitElapsedTime("retire");
  });
  
  // // 経過時間をRailsのRecordsコントローラーのcreateアクションに送信する関数
  // const submitElapsedTime = (action) => {
  //   const currentTime = new Date().getTime();
  //   const elapsedTime = Math.floor((currentTime - startTime) / 1000);
  //   const csrfToken = document.querySelector('[name=csrf-token]').content;
  //   const ramenShopId = <%= @ramen_shop.id %>;

  //   fetch("/records", {
  //     method: "POST",
  //     headers: {
  //       "Content-Type": "application/json",
  //       "X-CSRF-Token": csrfToken,
  //     },
  //     body: JSON.stringify({
  //       ramen_shop_id: ramenShopId,
  //       action: action,
  //       time: elapsedTime,
  //     }),
  //   })
  //   .then((response) => {
  //     if (response.ok) {
  //       window.location.href = "/";
  //     } else {
  //       alert("エラーが発生しました。");
  //     }
  //   })
  //   .catch((error) => {
  //     console.error("Error:", error);
  //   });
  // };

  // ローカルストレージに経過時間が格納されている場合、タイマーを再開する
  if (storedElapsedTime) {
    let unloadTime = Number(localStorage.unload_time) || 0;
    storedElapsedTime = Date.now() - unloadTime + storedElapsedTime;
    startTimer()
  }

  window.addEventListener("beforeunload", ()=> {
    clearInterval(timerID);
    storedElapsedTime = elapsedTime.getTime()
    localStorage.setItem("stored_elapsed_time", storedElapsedTime);
    localStorage.setItem("unload_time", Date.now());
  });
});
