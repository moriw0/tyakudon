#!/usr/bin/env bash
#
# claude --output-format stream-json の JSONL を、人が読める 1 行に落として流す。
# 標準入力から読み、標準出力に書く。ログは呼び出し側が tee で生のまま残す。
#
#   claude ... --output-format stream-json --verbose -p "$PROMPT" 2>&1 \
#     | tee "$LOG" | scripts/ralph-digest.sh
#
# JSON として読めない行 (stderr が混ざったものなど) は素通しする。
# jq がない環境では全部素通しする。

set -uo pipefail

if ! command -v jq >/dev/null 2>&1; then
  cat
  exit 0
fi

exec jq -rR --unbuffered '
  . as $line
  | (fromjson? // null) as $e
  | if $e == null then
      $line
    elif $e.type == "assistant" then
      $e.message.content[]?
      | if .type == "text" then
          (.text | gsub("\\s+"; " ")) as $t
          | $t | select(length > 0)
        elif .type == "tool_use" then
          ((.input.command // .input.file_path // .input.pattern // .input.prompt // "")
            | tostring | gsub("\\s+"; " ")) as $arg
          | "-> \(.name): \($arg[0:140])"
        else empty end
    elif $e.type == "user" then
      $e.message.content[]?
      | select(.type == "tool_result" and (.is_error == true))
      | ((.content | tostring) | gsub("\\s+"; " ")) as $c
      | "   ! \($c[0:200])"
    elif $e.type == "result" then
      "--- \($e.subtype): \($e.num_turns) turns / \(($e.duration_api_ms / 1000) | floor)s ---"
    else empty end
'
