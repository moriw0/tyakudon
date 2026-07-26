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
  claude --permission-mode acceptEdits --model "$MODEL" -p "$PROMPT" 2>&1 | tee "$LOG"
  STATUS="${PIPESTATUS[0]}"
  set -e

  if [ "$STATUS" -ne 0 ]; then
    notify "イテレーション ${i} が異常終了しました (exit ${STATUS})"
    exit "$STATUS"
  fi

  if grep -q "<promise>QUEUE_EMPTY</promise>" "$LOG"; then
    notify "キューが空になりました (${i} 回で終了)"
    exit 0
  fi
done

notify "反復上限 ${MAX} 回に到達しました"
