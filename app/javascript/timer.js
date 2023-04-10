document.addEventListener("turbo:load", () => {
  // タイマーデータを管理するMyStorageクラス
  class MyStorage {
    constructor(app) {
      this.app = app;
      this.storage = localStorage;
      this.data = JSON.parse(this.storage[this.app] || "{}");
    }

    getItem(key) {
      return this.data[key];
    }

    setItem(key, value) {
      this.data[key] = value;
      return this;
    }

    resetItem() {
      this.data = {};
      return this;
    }

    save() {
      this.storage[this.app] = JSON.stringify(this.data);
    }
  }

  // 変数とローカルストレージを定義
  const storage = new MyStorage("timer");
  const elapsedTimeEl = document.getElementById("time");
  const startBtn = document.getElementById("start");
  const stopBtn = document.getElementById("stop");
  const endBtn = document.getElementById("end");
  const retireBtn = document.getElementById("retire");
  const resetBtn = document.getElementById("reset");

  let startTime;
  let elapsedTime;
  let storedElapsedTime = storage.getItem("storedElapsedTime") || 0;
  let timerID;

  // 経過時間をフォーマットする関数
  const formatElapsedTime = (time) => {
    const h = String(time.getUTCHours()).padStart(2, "0");
    const m = String(time.getUTCMinutes()).padStart(2, "0");
    const s = String(time.getUTCSeconds()).padStart(2, "0");
    const ms = String(time.getUTCMilliseconds()).padStart(3, "0");

    return `${h}:${m}:${s}.${ms}`;
  };

  // 経過時間を更新する関数
  const updateElapsedTime = () => {
    const currentTime = Date.now();
    elapsedTime = new Date(currentTime - startTime + storedElapsedTime);
    elapsedTimeEl.textContent = formatElapsedTime(elapsedTime);
  };

  // URLからラーメンショップIDを抽出
  const ramenShopId = Number(location.pathname.match(/\d+$/)[0]);

  // 各ボタンに対応した関数
  const startTimer = () => {
    updateButtonStates(true, false, false, true, true);
    startTime = Date.now();
    if (!storage.getItem("startedAt")) {
      storage.setItem("ramenShopId", ramenShopId).save();
      storage.setItem("startedAt", new Date(startTime)).save();
    }
    timerID = setInterval(updateElapsedTime, 10);
  };

  const stopTimer = () => {
    updateButtonStates(false, true, true, false, false);
    clearInterval(timerID);
    storedElapsedTime += Date.now() - startTime;
  };

  const endTimer = () => {
    updateButtonStates(false, true, true, false, false);
    clearInterval(timerID);
    storedElapsedTime += Date.now() - startTime;
    submitElapsedTime();
    storage.resetItem().save();
    storedElapsedTime = 0;
    elapsedTime = 0;
  };

  const resetTimer = () => {
    updateButtonStates(false, true, true, true, true);
    elapsedTimeEl.textContent = "00:00:00.000";
    clearInterval(timerID);
    storage.resetItem().save();
    storedElapsedTime = 0;
    elapsedTime = 0;
  };

  // タイマーの状態に応じてボタン状態を更新
  const updateButtonStates = (start, stop, end, reset, retire) => {
    startBtn.disabled = start;
    stopBtn.disabled = stop;
    endBtn.disabled = end;
    resetBtn.disabled = reset;
    retireBtn.disabled = retire;
  };

  // ボタン用のイベントリスナー
  startBtn.addEventListener("click", startTimer);
  stopBtn.addEventListener("click", stopTimer);
  endBtn.addEventListener("click", endTimer);
  resetBtn.addEventListener("click", resetTimer);
  retireBtn.addEventListener("click", () => {
    clearInterval(timerID);
  });

  // 経過時間をRailsのRecordsコントローラーのcreateアクションに送信する関数
  const submitElapsedTime = () => {
    const endedAt = new Date();
    const startedAt = storage.getItem("startedAt");
    const csrfToken = document.querySelector("[name=csrf-token]").content;
    const url = `/ramen_shops/${ramenShopId}/records`;

    let recordData = {
      ramen_shop_id: ramenShopId,
      started_at: startedAt,
      ended_at: endedAt,
      elapsed_time: elapsedTime,
    };

    fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
      },
      body: JSON.stringify(recordData),
    })
      .then((response) => {
        if (response.ok) {
          alert("チャクドンレコードを投稿しました");
        } else {
          alert("エラーが発生しました。");
        }
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  };

  const connectedRamenShopId = storage.getItem("ramenShopId");
  // ストレージ内のshopIdとURLのshopIdが一致する場合、タイマーを再開する
  if (ramenShopId == connectedRamenShopId) {
    storedElapsedTime =
      Date.now() - storage.getItem("unloadTime") + storedElapsedTime;
    startTimer();
  } else {
    if (connectedRamenShopId) {
      const result = confirm(
        "接続中の店舗に遷移しますか？でなければ接続履歴をリセットします！"
      );

      if (result) {
        location.href = `/ramen_shops/${connectedRamenShopId}`;
      } else {
        resetTimer();
      }
    } else {
      resetTimer();
    }
  }

  // unload時、経過時間をストレージに保存する
  window.addEventListener("beforeunload", () => {
    clearInterval(timerID);
    storedElapsedTime = elapsedTime.getTime();
    storage.setItem("storedElapsedTime", storedElapsedTime).save();
    storage.setItem("unloadTime", Date.now()).save();
  });
});
