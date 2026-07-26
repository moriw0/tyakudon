# Ralph ループ: 1 イテレーションの手順

あなたは AFK エージェントです。このプロンプトは毎回まっさらなコンテキストで渡されます。前回のイテレーションの記憶はありません。状態は GitHub issues と git にしかないので、必要な情報はそこから読み直してください。

**1 回の実行で、チケットを 1 件だけ片付けます。** 複数のチケットにまたがってはいけません。

## 0. 前提を読む

- `CLAUDE.md` — このリポジトリでの働き方
- `CONTEXT.md` — ドメイン語彙。issue のタイトル、テスト名、UI のラベル、コミットメッセージで概念を名指しするときは、ここの用語をそのまま使う。`_Avoid_` に挙がった言い換えを持ち込まない
- `docs/adr/` — 設計判断。作業する領域に関わるものを読む
- `docs/v2_ui_migration.md` — v2 UI 移行の方針・命名規則・実装パターン

## 1. キューを引く

キューの定義は次の 4 条件をすべて満たす issue です。

- open である
- `ready-for-agent` ラベルが付いている
- `blocked_by == 0`（GitHub ネイティブの issue dependencies で判定する。本文の散文ではない）
- assignee がいない

```
gh issue list --label ready-for-agent --state open --json number,title \
  --jq '.[] | .number' \
| while read -r n; do
    gh api "repos/{owner}/{repo}/issues/$n" \
      --jq 'select(.issue_dependencies_summary.blocked_by == 0)
            | select((.assignees | length) == 0)
            | "\(.number)\t\(.title)"'
  done
```

**キューが空なら、他に何もせず `<promise>QUEUE_EMPTY</promise>` とだけ出力して終了してください。** 「全部終わった」場合と「残りが全部 blocked か `ready-for-human` になった」場合を区別する必要はありません。どちらも「いま自動で進められる仕事がない」であり、停止が正しい。ただし最終出力の 1 段落で、どちらなのかは書いてください。

## 2. チケットを 1 件選ぶ

**優先順位はあなたが判断します。** 番号順や依存の数といった機械的な規則は与えません。キューに残ったチケットの本文を読み、いま着手すべき 1 件を自分で決めてください。判断の根拠は最終出力に 1 行で書くこと。

選んだら、そのチケットと親 issue（本文の `## Parent` にある）を `gh issue view <n> --comments` で読み、受け入れ条件を把握します。

## 3. claim する

```
gh issue edit <n> --add-assignee @me
```

これがこのイテレーション最初の書き込みです。以降で詰まっても、assignee は外しません（次のイテレーションが同じチケットを掴まないため）。

## 4. worktree を用意する

ブランチ名は `<type>/<issue番号>-<slug>` の形にします（例: `fix/337-v2-layout-leak`）。type は Conventional Commits の語彙から選びます。

```
N=<issue番号>
BR=<ブランチ名>
WT=.claude/worktrees/issue-$N

git fetch origin
git worktree add "$WT" -b "$BR" origin/main
```

続いて下ごしらえをします。`.ENV` と `config/master.key` は gitignore されているため worktree に存在せず、これがないと Rails が起動しません。

**symlink は必ず相対パスにしてください。** compose の mount が `.:/rails` なので、ホストの絶対パスはコンテナ内で解決できません。

```
ln -s ../../../.ENV "$WT/.ENV"
ln -s ../../../../config/master.key "$WT/config/master.key"
```

さらに、ビルド済み CSS（`app/assets/builds/application.css`）も gitignore されているため worktree にありません。これがないとレイアウトを描画する spec が `Sprockets::Rails::Helper::AssetNotFound` で落ちます。

```
docker compose exec -w "/rails/$WT" app bin/rails dartsass:build
```

以降の**ファイルの変更**はすべて `$WT` の中で行います。リポジトリ本体の作業ツリーには一切触れないでください。

ただし `docker compose` だけは別です。**必ずリポジトリ本体のディレクトリから打ってください。** compose のプロジェクト名はカレントディレクトリ名から決まるため、worktree の中から `docker compose up` を打つと `issue-337` という別プロジェクトが立ち上がり、空の DB volume を持つ二重のスタックができます（初回の実行で実際に起きました）。

コンテナに対して打ってよいのは、本体のディレクトリからの `exec` だけです。

```
docker compose exec -w "/rails/$WT" app <コマンド>
```

## 5. 実装する

`~/.claude/skills/implement/SKILL.md` を読み、その手順に従って実装してください。このスキルはモデルから自動起動できない設定になっているため、ファイルを読んで内容に従う形を取ります。

- テストを先に書ける箇所では `tdd` スキルを使う
- 単体の spec はこまめに、フルスイートは最後に 1 回
- コミットは Conventional Commits（`fix:` / `refactor:` / `test:` / `docs:` / `feat:`）

## 6. 検証する

```
docker compose exec -w "/rails/$WT" app bundle exec rspec
docker compose exec -w "/rails/$WT" app bundle exec rubocop
```

**フルスイートが緑で、RuboCop に新規の違反がないこと。** どちらかが落ちている状態で PR を出してはいけません。

テスト DB はリポジトリ全体で 1 つしかありません。並列で回さないでください。

## 7. レビューする

`code-review` スキルを使います。Standards 軸（このリポジトリの規約準拠）と Spec 軸（元 issue の受け入れ条件との一致）の 2 本が走ります。

- **CRITICAL / HIGH で、かつチケットの範囲内**の指摘 → 直して 6 に戻る
- **MEDIUM 以下**の指摘 → 直さない。PR 本文の「レビュー所見」に列挙する
- **CRITICAL / HIGH でも、チケットの範囲外**の指摘（例: このコントローラー全体が太い）→ 直さない。PR 本文に書き、必要なら 禁止事項 7 に従って新規 issue を立てる

## 8. PR を出す

```
git -C "$WT" push -u origin "$BR"
```

PR 本文は `generate-pr-body` スキルに従って組み立てます。必ず含めるもの:

- `Closes #<issue番号>`
- レビュー所見（7 で直さなかったもの。なければ「なし」と書く）
- 範囲外で気づいたこと（起票した issue へのリンクを含む）

## 9. 後片付け

```
git worktree remove "$WT"
```

worktree を残したまま終了しないでください。次のイテレーションのノイズになります。

---

## 詰まったときの出口

次のいずれかに当たったら、そのチケットは**そこで打ち切ります**。粘らないでください。

1. フルスイートを緑にする試行が **3 回**失敗した
2. 受け入れ条件に、コードを読んでも判断できない曖昧さがある
3. チケットに書かれている前提が崩れていることを見つけた（例: 「導線ゼロ」とされたコードに実は導線があった）

打ち切るときの手順:

1. そこまでの作業をコミットして push する
2. **draft** PR を作る（`gh pr create --draft`）。本文に「どこで詰まったか」「何を確認したか」「人間に何を判断してほしいか」を書く
3. `gh issue comment <n>` で同じ内容を要約して残す
4. `gh issue edit <n> --remove-label ready-for-agent --add-label ready-for-human`
5. worktree を削除する

ラベルの付け替えを忘れないでください。これを忘れると、次のイテレーションが同じチケットを掴んで同じ場所で詰まります。

打ち切ってもループは止まりません。次のイテレーションが別のチケットを取ります。

---

## 禁止事項

**絶対にしないこと**

1. `main` への直接 push、PR のマージ、issue のクローズ。issue は PR がマージされたときに `Closes #<n>` で閉じる
2. チケットに列挙されていないファイルの削除。ADR-0001 が「廃止機能のコードとデータは温存する」と決めているため、削除してよいのはチケットが明示的に列挙したものだけ
3. `Gemfile` / `Gemfile.lock` / `db/schema.rb` / マイグレーション / `.github/workflows/` / `compose.yaml` の変更
4. テストを通すためにテストを緩めること。ただし**チケットが名指ししている spec ファイルの書き換えは作業対象**（system spec の v2 化などは、その書き換え自体がチケットの中身）
5. リポジトリ本体の作業ツリーでのファイル変更。すべて worktree の中で行う
6. `docker compose up` / `docker compose down`。コンテナはすでに起動している。触ってよいのは本体のディレクトリからの `docker compose exec -w "/rails/$WT" app ...` だけ

**やらずに記録すること**

7. チケットの範囲外で見つけた問題は直さない。`gh issue create --label needs-triage` で新規 issue を立て、PR 本文からリンクする
8. `CONTEXT.md` / `docs/adr/` / `docs/v2_ui_migration.md` は変更しない。矛盾を見つけたら issue コメントに書く。これらは「変わらない情報」として置かれており、黙って書き換えると設計判断の履歴が壊れる
9. 追跡 issue（#332 など）のチェックボックスは触らない。マージ時に人間が更新する

**必ず守ること**

10. 1 イテレーション = 1 チケット = 1 PR
11. コミットメッセージと PR 本文で、ドメイン概念は `CONTEXT.md` の用語をそのまま使う

---

## 最終出力

作業が終わったら、次を 1 段落ずつで報告してください。

- 選んだチケットと、それを選んだ理由
- やったこと
- PR の URL（draft ならその旨）
- 次のイテレーションに引き継ぐ注意点があれば

キューが空だった場合は `<promise>QUEUE_EMPTY</promise>` を出力したうえで、空になった理由（全完了か、残りが blocked / `ready-for-human` か）を 1 段落で書いてください。
