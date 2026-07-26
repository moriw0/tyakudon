## tyakudon (ちゃくどん)

このファイルは、このリポジトリで**どう働くか**だけを持つ。サービスが何であるか、どんな用語を使うか、なぜその設計になっているかは別のファイルにある。

| 知りたいこと | 読む場所 |
| --- | --- |
| サービスの説明とドメイン語彙（接続 / 着丼 / 着丼記録 / お気に入り店舗 など） | [`CONTEXT.md`](./CONTEXT.md) |
| 設計判断の記録と、その理由 | [`docs/adr/`](./docs/adr/) |
| v2 UI 移行の方針・命名規則・実装パターン | [`docs/v2_ui_migration.md`](./docs/v2_ui_migration.md) |
| Issue / PRD の扱い（GitHub Issues + `gh` CLI） | [`docs/agents/issue-tracker.md`](./docs/agents/issue-tracker.md) |
| triage ラベルの対応表 | [`docs/agents/triage-labels.md`](./docs/agents/triage-labels.md) |
| ドメインドキュメントの読み方（single-context 構成） | [`docs/agents/domain.md`](./docs/agents/domain.md) |
| 自律ループ (Ralph) の回し方 | [`docs/agents/loop.md`](./docs/agents/loop.md) |

ドメイン概念を名指しするとき（issue のタイトル、テスト名、UI のラベル、コミットメッセージ）は `CONTEXT.md` の用語をそのまま使う。用語集が `_Avoid_` に挙げた言い換えを持ち込まない。

**技術スタック:**

- Ruby on Rails 7.1
- PostgreSQL
- GoodJob (バックグラウンドジョブ)
- Hotwire (Turbo + Stimulus)
- Docker Compose (開発環境)
- Fly.io (本番環境)

## Critical Rules

### Code Organization

- 多数の小さいファイルを、少数の大きいファイルよりも優先
- 高凝集・低結合を意識
- ドメイン/機能単位で整理
- ビジネスロジックはモデル app/models/ に配置
    1. ActiveRecord: DBテーブルに紐づくモデル
    2. Concerns: 共有する振る舞いや、機能をまとめたモジュール
    3. PORO: それ以外の単独ロジック
- app/services/ は非推奨 (既存ファイルはモデルに移行予定で、新規実装では使わない)

### Code Style

- 適切なタイミングで RuboCop を実行してコードスタイルを整える
- 可能な限り不変性を保つ（オブジェクトや配列を変更しない）
- 本番環境に `puts` や `p` を残さない
- `rescue` で適切にエラーを処理する
- バリデーションはモデルに集約する

### Testing

- TDD: まずテストを書いてから実装
- カバレッジ: 80%以上
- Unit tests: モデル、ユーティリティ
- Integration tests: API エンドポイント、コントローラー (RequestSpec)
- E2E tests: 重要なユーザーフローに適用 (Capybara)

### Security

- シークレットは Rails credentials または `.env` で管理
- 全てのユーザー入力をバリデーションする
- SQL インジェクション防止（受付はパラメータ化クエリのみ）
- XSS 防止（HTML サニタイズ）
- 認証・認可を確認

## Git Workflow

- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- Never commit to main directly
- PRs require review
- All tests must pass before merge
