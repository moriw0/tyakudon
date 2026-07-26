# 自律ループ (Ralph)

`ready-for-agent` のチケットを、エージェントが 1 件ずつ実装して PR にするループ。[Ralph Wiggum の技法](https://www.aihero.dev/getting-started-with-ralph)を、このリポジトリの制約に合わせて変形したもの。

## 回し方

```
scripts/ralph-once.sh          1 回だけ。キューから 1 件、エージェントが選ぶ
scripts/ralph-once.sh 337      1 回だけ。#337 を指定
scripts/ralph.sh 5             上限 5 回の AFK ループ
```

反復上限は必須。既定値はない。キューが空になるとエージェントが `<promise>QUEUE_EMPTY</promise>` を出力し、そこで即終了する。終了時に macOS の通知が出る。

モデルは `RALPH_MODEL` で上書きできる。`ralph-once.sh` の既定は Opus、`ralph.sh` の既定は Sonnet。once で Opus を使うのは、品質が低かったときに「プロンプトが悪いのか、モデルが足りないのか」を切り分けられるようにするため。

```
RALPH_MODEL=sonnet scripts/ralph-once.sh 337
```

## 1 イテレーションの中身

手順の本体は [`scripts/ralph-prompt.md`](../../scripts/ralph-prompt.md) にある。スクリプトはそれを毎回そのまま `claude -p` に渡すだけ。

1. キューを引く（open / `ready-for-agent` / `blocked_by == 0` / assignee なし）
2. 1 件選ぶ — **どれをやるかはエージェントが判断する**
3. `gh issue edit --add-assignee @me` で claim
4. `.claude/worktrees/issue-<n>/` に worktree を作る
5. `implement` スキルの手順で実装（内部で `tdd`）
6. フルスイート + RuboCop
7. `code-review` スキル。CRITICAL / HIGH かつ範囲内なら直して 6 に戻る
8. PR を出す（`Closes #<n>`）
9. worktree を削除

## 翌朝、何を見るか

```
gh pr list
gh issue list --label ready-for-human
```

- **通常の PR** — レビューしてマージする。マージが依存の解決を兼ねるので、`blocked_by` が減って次のイテレーションのキューが広がる
- **draft PR** — エージェントが詰まったもの。PR 本文と issue コメントに「どこで詰まったか」「何を判断してほしいか」が書いてある。続きをやるか、閉じるかを決める
- **`ready-for-human` ラベル** — 打ち切られたチケット。ループはもう掴まない

ログは `tmp/ralph/<timestamp>-iter<n>.log`（gitignore 済み）。成功時の記録は PR に集約してあるので、ログを開くのは何かおかしいときだけでいい。

## ループが止まるとき

3 つある。どれも異常ではない。

- **キューが空** — 全部終わったか、残りが全部 blocked / `ready-for-human` になった。どちらかは最終出力に書いてある
- **反復上限に到達** — もう一度回せばいい
- **異常終了** — スクリプトが exit code を返して止まる。ログを見る

依存が未解決のチケットは、blocker の PR をマージするまでキューに現れない。**マージしないとキューが枯れる**のは設計どおりで、レビューが追いつかないまま PR が積み上がるのを防いでいる。

## Ralph からの変形点

原型は PRD.md と progress.txt でタスクを管理し、エージェントに仕様の分解から実装まで丸ごと任せる。このリポジトリでは 3 点を変えた。

**状態は GitHub issues に一本化した。** チケット、依存関係、完了判定がすでに GitHub 側にある。progress.txt を足すと二重管理になる。「前回の判断」は git log と PR から読む。

**成果物は PR で、マージは人間。** `main` は保護されていて（必須チェック `RuboCop` / `Rspec`、force push 禁止、`enforce_admins`）、そもそも直接コミットできない。結果として、依存の解決とレビューが同じイベントになった。

**仕様の分解はループの外に置いた。** 塊 → チケットへの分解にはこのリポジトリの判断が濃く入っていて、そこが品質の源泉になっている。実際 #334 では「導線ゼロ」の誤判定が起票段階で 1 件混入し、人間の推敲で捕まっている。ここを自動化すると、誤った前提のまま複数の PR が出る。ループは分解の**下流**だけを担う。

したがって、ある塊のチケットを消化しきるとループは止まる。次の塊のチケットは人間が起こす（`to-tickets` / `to-spec` / `grill-with-docs` などのスキルが使える）。起こしたら同じスクリプトをまた回すだけ。

## 環境の前提

- **worktree の symlink は相対パスで作る。** compose の mount が `.:/rails` なので、ホストの絶対パスはコンテナ内で解決できない
- **`.ENV` と `config/master.key`** は gitignore されていて worktree に存在しない。symlink で通す
- **`app/assets/builds/application.css`** も gitignore。worktree では `bin/rails dartsass:build` が要る。これがないとレイアウトを描画する spec が `Sprockets::Rails::Helper::AssetNotFound` で落ちる
- **テスト DB はリポジトリ全体で 1 つ。** worktree を分けても並列には回せない。実行は直列
- **`docker compose` は必ずリポジトリ本体のディレクトリから打つ。** プロジェクト名がカレントディレクトリ名から決まるため、worktree の中から `docker compose up` を打つと `issue-337` のような別プロジェクトが立ち上がり、空の DB volume を持つ二重のスタックができる。初回の実行で実際に起きたので、`up` / `down` は deny リストで塞いである
- **権限は `.claude/settings.json` の allow / deny リスト**で制御する。`--dangerously-skip-permissions` は使わない。deny リストで `gh pr merge` / `gh issue close` / `main` への push / force push を機械的に塞いでいる
