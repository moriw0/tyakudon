# アーキテクチャ設計ガイド

## 基本原則

### 1. 技術選定には理由を明記

**悪い例**:
```
- Node.js
- TypeScript
```

**良い例**:
```
- Node.js v24.11.0 (LTS)
  - 2026年4月までの長期サポート保証により、本番環境での安定稼働が期待できる
  - 非同期I/O処理に優れ、APIサーバーとして高いパフォーマンスを発揮
  - npmエコシステムが充実しており、必要なライブラリの入手が容易

- TypeScript 5.x
  - 静的型付けによりコンパイル時にバグを検出でき、保守性が向上
  - IDEの補完機能が強力で、開発効率が高い
  - チーム開発における型定義の共有により、コードの可読性と品質が担保される

- npm 11.x
  - Node.js v24.11.0に標準搭載されており、別途インストール不要
  - workspaces機能によりモノレポ構成に対応
  - package-lock.jsonによる依存関係の厳密な管理が可能
```

### 2. レイヤー分離の原則

各レイヤーの責務を明確にし、依存関係を一方向に保ちます:

```
UI → Models → Data (OK)
UI ← Models (NG)
UI → Data (NG)
```

⚠️ **Railsプロジェクトの場合**:
サービスレイヤーは使用せず、すべてのロジックを `app/models/` に配置します。
詳細は [アーキテクチャ設計書](../../../docs/architecture.md) を参照してください。

### 3. 測定可能な要件

すべてのパフォーマンス要件は測定可能な形で記述します。

## レイヤードアーキテクチャの設計

### 各レイヤーの責務

**UIレイヤー**:
```typescript
// 責務: ユーザー入力の受付とバリデーション
class CLI {
  // OK: サービスレイヤーを呼び出す
  async addTask(title: string) {
    const task = await this.taskService.create({ title });
    console.log(`Created: ${task.id}`);
  }

  // NG: データレイヤーを直接呼び出す
  async addTask(title: string) {
    const task = await this.repository.save({ title }); // ❌
  }
}
```

**データレイヤー**:
```typescript
// 責務: データの永続化
class TaskRepository {
  async save(task: Task): Promise<void> {
    await this.storage.write(task);
  }
}
```

## パフォーマンス要件の設定

### 具体的な数値目標

```
コマンド実行時間: 100ms以内(平均的なPC環境で)
└─ 測定方法: console.timeでCLI起動から結果表示まで計測
└─ 測定環境: CPU Core i5相当、メモリ8GB、SSD

タスク一覧表示: 1000件まで1秒以内
└─ 測定方法: 1000件のダミーデータで計測
└─ 許容範囲: 100件で100ms、1000件で1秒、10000件で10秒
```

## セキュリティ設計

### データ保護の3原則

1. **最小権限の原則**
```bash
# ファイルパーミッション
chmod 600 ~/.devtask/tasks.json  # 所有者のみ読み書き
```

2. **入力検証**
```typescript
function validateTitle(title: string): void {
  if (!title || title.length === 0) {
    throw new ValidationError('タイトルは必須です');
  }
  if (title.length > 200) {
    throw new ValidationError('タイトルは200文字以内です');
  }
}
```

3. **機密情報の管理**
```bash
# 環境変数で管理
export DEVTASK_API_KEY="xxxxx"  # コード内にハードコードしない
```

## スケーラビリティ設計

### データ増加への対応

**想定データ量**: [例: 10,000件のタスク]

**対策**:
- データのページネーション
- 古いデータのアーカイブ
- インデックスの最適化

```typescript
// アーカイブ機能の例: 古いタスクを別ファイルに移動
class ArchiveService {
  async archiveCompletedTasks(olderThan: Date): Promise<void> {
    const oldTasks = await this.repository.findCompleted(olderThan);
    await this.archiveStorage.save(oldTasks);
    await this.repository.deleteMany(oldTasks.map(t => t.id));
  }
}
```

## 依存関係管理

### バージョン管理方針

```json
{
  "dependencies": {
    "commander": "^11.0.0",  // マイナーバージョンアップは自動
    "chalk": "5.3.0"         // 破壊的変更のリスクがある場合は固定
  },
  "devDependencies": {
    "typescript": "~5.3.0",  // パッチバージョンのみ自動
    "eslint": "^9.0.0"
  }
}
```

**方針**:
- 安定版は固定(^でマイナーバージョンまで許可)
- 破壊的変更のリスクがある場合は完全固定
- devDependenciesはパッチバージョンのみ自動(~)

## チェックリスト

- [ ] すべての技術選定に理由が記載されている
- [ ] レイヤードアーキテクチャが明確に定義されている
- [ ] パフォーマンス要件が測定可能である
- [ ] セキュリティ考慮事項が記載されている
- [ ] スケーラビリティが考慮されている
- [ ] バックアップ戦略が定義されている
- [ ] 依存関係管理のポリシーが明確である
- [ ] テスト戦略が定義されている