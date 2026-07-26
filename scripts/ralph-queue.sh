#!/usr/bin/env bash
#
# Ralph ループのキューを出力する。1 行 1 チケットで `<番号>\t<タイトル>`。
# キューが空なら何も出力しない。
#
# キューの定義は次の 4 条件をすべて満たす open issue:
#   - `ready-for-agent` ラベルが付いている
#   - blocked_by == 0 (GitHub ネイティブの issue dependencies)
#   - assignee がいない
#
# スクリプトに切り出してあるのは、パイプと while ループの複合コマンドが
# allow リストのパターンに分解できず、headless で承認待ちになって
# 止まるため。単一のスクリプト呼び出しなら allow できる。

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

gh issue list --label ready-for-agent --state open --json number --jq '.[].number' \
| while read -r n; do
    gh api "repos/{owner}/{repo}/issues/$n" \
      --jq 'select(.issue_dependencies_summary.blocked_by == 0)
            | select((.assignees | length) == 0)
            | "\(.number)\t\(.title)"'
  done
