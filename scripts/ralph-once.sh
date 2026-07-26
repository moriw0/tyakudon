#!/usr/bin/env bash
#
# Ralph ループを 1 回だけ回す。プロンプトを育てる段階と、初回の様子見に使う。
#
#   scripts/ralph-once.sh          キューから 1 件、エージェントが選ぶ
#   scripts/ralph-once.sh 337      #337 を指定して回す
#
# モデルは RALPH_MODEL で上書きできる (既定: opus)。
# 初回に opus を使うのは、品質が低かったときに「プロンプトが悪いのか
# モデルが足りないのか」を切り分けられるようにするため。

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

MODEL="${RALPH_MODEL:-opus}"
ISSUE="${1:-}"

mkdir -p tmp/ralph
LOG="tmp/ralph/$(date +%Y%m%d-%H%M%S)-once.log"

PROMPT="$(cat scripts/ralph-prompt.md)"

if [ -n "$ISSUE" ]; then
  PROMPT="${PROMPT}

---

## このイテレーションの指定

キューから選ぶ手順 (1 と 2) は飛ばし、**#${ISSUE} を実装してください**。
#${ISSUE} が open で assignee がおらず blocked_by が 0 であることだけ確認し、
そうでなければ理由を出力して何もせず終了してください。"
fi

git worktree prune

echo "=== ralph-once (model: ${MODEL}${ISSUE:+, issue: #$ISSUE}) ==="
echo "=== log: ${LOG} ==="

claude --permission-mode acceptEdits --model "$MODEL" -p "$PROMPT" 2>&1 | tee "$LOG"
