#!/usr/bin/env bash
#
# Ralph ループを AFK で回す。1 イテレーション = 1 チケット = 1 PR。
#
#   scripts/ralph.sh 5
#
# 反復上限は必須。既定値は設けない。
# キューが空になるとエージェントが <promise>QUEUE_EMPTY</promise> を出力し、
# そこで即終了する。
#
# モデルは RALPH_MODEL で上書きできる (既定: sonnet)。

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

if [ $# -ne 1 ]; then
  echo "Usage: $0 <max-iterations>" >&2
  exit 1
fi

MAX="$1"
MODEL="${RALPH_MODEL:-sonnet}"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p tmp/ralph

notify() {
  osascript -e "display notification \"$1\" with title \"Ralph\"" 2>/dev/null || true
  echo "=== $1 ==="
}

PROMPT="$(cat scripts/ralph-prompt.md)"

for ((i = 1; i <= MAX; i++)); do
  LOG="tmp/ralph/${STAMP}-iter${i}.log"

  echo "=== iteration ${i}/${MAX} (model: ${MODEL}) ==="
  echo "=== log: ${LOG} ==="

  # 前のイテレーションが途中で死んで worktree を残していても、ここで掃除される
  git worktree prune

  set +e
  # テキスト出力は完了時まで一括バッファされる。--verbose を足しても変わらない。
  # stream-json はイベント発生順に届くので、生の JSONL を LOG に残しつつ、
  # コンソールには digest を流す。
  claude --permission-mode acceptEdits --model "$MODEL" \
    --output-format stream-json --verbose -p "$PROMPT" 2>&1 \
    | tee "$LOG" | scripts/ralph-digest.sh
  STATUS="${PIPESTATUS[0]}"
  set -e

  if [ "$STATUS" -ne 0 ]; then
    notify "イテレーション ${i} が異常終了しました (exit ${STATUS})"
    exit "$STATUS"
  fi

  # 判定はエージェントの最終報告 (result イベントの .result) だけを見る。
  # ログ全体を見てはいけない。stream-json にはツールの出力が丸ごと入るので、
  # gh pr view や git log が拾ってきた文章に紛れた文字列で誤判定する。
  # 実際、PR #351 の本文に書いた <promise>QUEUE_EMPTY</promise> という
  # 引用がログに入り、キューが残っているのに空と判定して止まった。
  if command -v jq >/dev/null 2>&1; then
    FINAL="$(jq -r 'select(.type == "result") | .result // empty' "$LOG" 2>/dev/null)"
    DENIALS="$(jq -r 'select(.type == "result") | (.permission_denials | length)' "$LOG" 2>/dev/null)"
    [ -n "${DENIALS:-}" ] && echo "=== 権限で弾かれたツール呼び出し: ${DENIALS} 件 ==="
  else
    # jq がなければ判定材料はログ全体しかない。誤判定しうるが、
    # 毎回止まるよりはましなので従来どおりにする。
    FINAL="$(cat "$LOG")"
  fi

  if printf '%s' "$FINAL" | grep -q "<promise>QUEUE_EMPTY</promise>"; then
    notify "キューが空になりました (${i} 回で終了)"
    exit 0
  fi

  # 正常なイテレーションは必ず PR を出すか (打ち切り時は draft)、
  # キューが空だと宣言するかのどちらかで終わる。どちらも起きていないなら
  # 空振りしている。承認待ちで止まった場合が代表例で、claude は exit 0 を
  # 返すため exit code では検知できない。放置すると残りの回数を
  # 黙って空振りし続けるので、ここで止める。
  # 最終報告そのものが取れなかった場合 (result イベントがない = 途中で
  # 死んだ) も、ここで引っかかって止まる。
  if ! printf '%s' "$FINAL" | grep -qE 'https://github\.com/[^ ]+/pull/[0-9]+'; then
    notify "イテレーション ${i} が PR を出さずに終了しました。ログを確認してください"
    exit 1
  fi
done

notify "反復上限 ${MAX} 回に到達しました"
