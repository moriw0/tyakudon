# プロセスガイド (Process Guide)

## 基本原則

### 1. 具体例を豊富に含める

抽象的なルールだけでなく、具体的なコード例を提示します。

**悪い例**:
```
変数名は分かりやすくすること
```

**良い例**:
```typescript
// ✅ 良い例: 役割が明確
const userAuthentication = new UserAuthenticationService();
const taskRepository = new TaskRepository();

// ❌ 悪い例: 曖昧
const auth = new Service();
const repo = new Repository();
```

### 2. 理由を説明する

「なぜそうするのか」を明確にします。

**例**:
```
## エラーを無視しない

理由: エラーを無視すると、問題の原因究明が困難になります。
予期されるエラーは適切に処理し、予期しないエラーは上位に伝播させて
ログに記録できるようにします。
```

### 3. 測定可能な基準を設定

曖昧な表現を避け、具体的な数値を示します。

**悪い例**:
```
コードカバレッジは高く保つこと
```

**良い例**:
```
コードカバレッジ目標:
- ユニットテスト: 80%以上
- 統合テスト: 60%以上
- E2Eテスト: 主要フロー100%
```

## Git運用ルール

### ブランチ戦略（Git Flow採用）

**Git Flowとは**:
Vincent Driessenが提唱した、機能開発・リリース・ホットフィックスを体系的に管理するブランチモデル。明確な役割分担により、チーム開発での並行作業と安定したリリースを実現します。

**ブランチ構成**:
```
main (本番環境)
└── develop (開発・統合環境)
    ├── feature/* (新機能開発)
    ├── fix/* (バグ修正)
    └── release/* (リリース準備)※必要に応じて
```

**運用ルール**:
- **main**: 本番リリース済みの安定版コードのみを保持。タグでバージョン管理
- **develop**: 次期リリースに向けた最新の開発コードを統合。CIでの自動テスト実施
- **feature/\*、fix/\***: developから分岐し、作業完了後にPRでdevelopへマージ
- **直接コミット禁止**: すべてのブランチでPRレビューを必須とし、コード品質を担保
- **マージ方針**: feature→develop は squash merge、develop→main は merge commit を推奨

**Git Flowのメリット**:
- ブランチの役割が明確で、複数人での並行開発がしやすい
- 本番環境(main)が常にクリーンな状態に保たれる
- 緊急対応時はhotfixブランチで迅速に対応可能（必要に応じて導入）

### コミットメッセージの規約

**Conventional Commitsを推奨**:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type一覧**:
```
feat: 新機能 (minor version up)
fix: バグ修正 (patch version up)
docs: ドキュメント
style: フォーマット (コードの動作に影響なし)
refactor: リファクタリング
perf: パフォーマンス改善
test: テスト追加・修正
build: ビルドシステム
ci: CI/CD設定
chore: その他 (依存関係更新など)

BREAKING CHANGE: 破壊的変更 (major version up)
```

**良いコミットメッセージの例**:

```
feat(task): 優先度設定機能を追加

ユーザーがタスクに優先度(高/中/低)を設定できるようになりました。

実装内容:
- Taskモデルにpriorityフィールド追加
- CLI に --priority オプション追加
- 優先度によるソート機能実装

破壊的変更:
- Task型の構造が変更されました
- 既存のタスクデータはマイグレーションが必要です

Closes #123
BREAKING CHANGE: Task型にpriority必須フィールド追加
```

### プルリクエストのテンプレート

**効果的なPRテンプレート**:

```markdown
## 変更の種類
- [ ] 新機能 (feat)
- [ ] バグ修正 (fix)
- [ ] リファクタリング (refactor)
- [ ] ドキュメント (docs)
- [ ] その他 (chore)

## 変更内容
### 何を変更したか
[簡潔な説明]

### なぜ変更したか
[背景・理由]

### どのように変更したか
- [変更点1]
- [変更点2]

## テスト
### 実施したテスト
- [ ] ユニットテスト追加
- [ ] 統合テスト追加
- [ ] 手動テスト実施

### テスト結果
[テスト結果の説明]

## 関連Issue
Closes #[番号]
Refs #[番号]

## レビューポイント
[レビュアーに特に見てほしい点]
```

## テスト戦略

### テストピラミッド

```
       /\
      /E2E\       少 (遅い、高コスト)
     /------\
    / 統合   \     中
   /----------\
  / ユニット   \   多 (速い、低コスト)
 /--------------\
```

**目標比率**:
- ユニットテスト: 70%
- 統合テスト: 20%
- E2Eテスト: 10%

### テストの書き方

**Given-When-Then パターン**:

```typescript
describe('TaskService', () => {
  describe('タスク作成', () => {
    it('正常なデータの場合、タスクを作成できる', async () => {
      // Given: 準備
      const service = new TaskService(mockRepository);
      const validData = { title: 'テスト' };

      // When: 実行
      const result = await service.create(validData);

      // Then: 検証
      expect(result.id).toBeDefined();
      expect(result.title).toBe('テスト');
    });

    it('タイトルが空の場合、ValidationErrorをスローする', async () => {
      // Given: 準備
      const service = new TaskService(mockRepository);
      const invalidData = { title: '' };

      // When/Then: 実行と検証
      await expect(
        service.create(invalidData)
      ).rejects.toThrow(ValidationError);
    });
  });
});
```

### カバレッジ目標

**測定可能な目標**:

```json
// jest.config.js
{
  "coverageThreshold": {
    "global": {
      "branches": 80,
      "functions": 80,
      "lines": 80,
      "statements": 80
    },
    "./src/services/": {
      "branches": 90,
      "functions": 90,
      "lines": 90,
      "statements": 90
    }
  }
}
```

**理由**:
- 重要なビジネスロジック(services/)は高いカバレッジを要求
- UI層は低めでも許容
- 100%を目指さない (コストと効果のバランス)

## コードレビュープロセス

### レビューの目的

1. **品質保証**: バグの早期発見
2. **知識共有**: チーム全体でコードベースを理解
3. **学習機会**: ベストプラクティスの共有

### 効果的なレビューのポイント

**レビュアー向け**:

1. **建設的なフィードバック**
```markdown
## ❌ 悪い例
このコードはダメです。

## ✅ 良い例
この実装だと O(n²) の時間計算量になります。
Map を使うと O(n) に改善できます:

```typescript
const taskMap = new Map(tasks.map(t => [t.id, t]));
const result = ids.map(id => taskMap.get(id));
```
```

2. **優先度の明示**
```markdown
[必須] セキュリティ: パスワードがログに出力されています
[推奨] パフォーマンス: ループ内でのDB呼び出しを避けましょう
[提案] 可読性: この関数名をもっと明確にできませんか？
[質問] この処理の意図を教えてください
```

3. **ポジティブなフィードバックも**
```markdown
✨ この実装は分かりやすいですね！
👍 エッジケースがしっかり考慮されています
💡 このパターンは他でも使えそうです
```

**レビュイー向け**:

1. **セルフレビューを実施**
   - PR作成前に自分でコードを見直す
   - 説明が必要な箇所にコメントを追加

2. **小さなPRを心がける**
   - 1PR = 1機能
   - 変更ファイル数: 10ファイル以内を推奨
   - 変更行数: 300行以内を推奨

3. **説明を丁寧に**
   - なぜこの実装にしたか
   - 検討した代替案
   - 特に見てほしいポイント

### レビュー時間の目安

- 小規模PR (100行以下): 15分
- 中規模PR (100-300行): 30分
- 大規模PR (300行以上): 1時間以上

**原則**: 大規模PRは避け、分割する

## 自動化の推進（該当する場合）

### 品質チェックの自動化

**自動化項目と採用ツール**:

1. **Lint チェック**
   - **RuboCop** (with rubocop-rails, rubocop-rspec, rubocop-performance)
     - Ruby/Rails のコーディング規約を統一
     - 潜在的なバグや非推奨パターンを自動検出
     - 多くの問題は `-a` オプションで自動修正可能
     - 設定ファイル: `.rubocop.yml`

2. **テスト実行**
   - **RSpec**
     - BDD スタイルのテストフレームワーク
     - FactoryBot でテストデータを効率的に管理
     - SimpleCov でカバレッジ測定（オプション）

3. **セキュリティチェック**
   - **Brakeman**
     - Rails アプリケーションの脆弱性を静的解析
     - SQL インジェクション、XSS などを検出

4. **依存関係チェック**
   - **Bundler Audit**
     - Gemfile.lock の既知の脆弱性をチェック

**実装方法**:

**1. CI/CD (GitHub Actions)**
```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2.2
          bundler-cache: true
      - name: Setup Database
        run: |
          bundle exec rails db:create RAILS_ENV=test
          bundle exec rails db:schema:load RAILS_ENV=test
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
      - name: Run RuboCop
        run: bundle exec rubocop
      - name: Run RSpec
        run: bundle exec rspec
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
      - name: Run Brakeman (オプション)
        run: bundle exec brakeman -q -z
```

**2. Pre-commit フック**

Docker 環境での Git フック:
```bash
# .git/hooks/pre-commit
#!/bin/sh
echo "Running RuboCop..."
docker compose exec app bundle exec rubocop || exit 1

echo "Running RSpec..."
docker compose exec app bundle exec rspec || exit 1

echo "All checks passed!"
```

フックに実行権限を付与:
```bash
chmod +x .git/hooks/pre-commit
```

**導入効果**:
- コミット前に自動チェックが走り、不具合コードの混入を防止
- PR 作成時に自動で CI 実行され、マージ前に品質を担保
- 早期発見により、修正コストを最大80%削減（バグ検出が本番後の場合と比較）

**この構成を選んだ理由**:
- Rails エコシステムにおける標準的かつ実績のある構成
- Docker Compose 開発環境と親和性が高い
- RuboCop による静的解析と RSpec による動的テストで包括的な品質保証

## チェックリスト

- [ ] ブランチ戦略が決まっている
- [ ] コミットメッセージ規約が明確である
- [ ] PRテンプレートが用意されている
- [ ] テストの種類とカバレッジ目標が設定されている
- [ ] コードレビュープロセスが定義されている
- [ ] CI/CDパイプラインが構築されている
