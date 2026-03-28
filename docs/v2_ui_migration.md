# v2 UI 移行ガイド

## 概要

Bootstrap 5 + Google Fonts (Noto Sans JP) + 固定ヘッダーに依存した現行 UI から、
ブラウザデフォルト重視のミニマルデザインシステムへ段階的に移行する。

一括置換はリスクが高いため、**Cookie フラグ + per-action opt-in + Rails variants** の組み合わせで、
既存ユーザーへの影響をゼロに保ちながらページ単位で移行する。

---

## デザイン方針

`docs/prototypes/` 配下の静的 HTML プロトタイプで確立した方針を Rails 本体に移植する。

| 項目 | v1（現行） | v2（新） |
|------|-----------|---------|
| CSS フレームワーク | Bootstrap 5 | なし（v2.css のみ） |
| フォント | Noto Sans JP (Google Fonts) | system sans-serif |
| レイアウト幅 | 固定ヘッダー + コンテナ | max-width: 800px, margin: auto |
| セクション区切り | カード、ボーダー | `<hr>` |
| ボタン | Bootstrap `.btn-primary` 等 | `.btn` / `.btn-block` / `.btn-link` |
| フォーム | `bootstrap_form_with` | `form_with` |
| 表 | Bootstrap テーブル | ブラウザデフォルト |
| Flash | notice/alert 両方 | alert のみ（赤字、記号なし） |

### CSS 設計原則

- ブラウザのデフォルトスタイルを最大限活用する
- クラスは最小限。構造が正しければ見た目は自然に整う
- レスポンシブ: 480px 以下で補助列（作者・コメント・写真・ジャンル等）を非表示

---

## 切り替え方法

| 操作 | 効果 |
|------|------|
| `/?v2=1` にアクセス | Cookie をセット → 以降すべてのページで v2 が有効 |
| `/?v2=0` にアクセス | Cookie を削除 → v1 に戻る |
| Cookie なし / フラグ未対応ページ | 通常通り v1 が表示される |

フラグをオンにしても、v2 対応済みのページのみ新デザインで表示される。
未対応ページは Cookie があっても v1 レイアウトのままなので、デザイン混在は起きない。

---

## 実装構造

### レイアウト切り替えの仕組み

```
ApplicationController
  ├── before_action :handle_v2_flag   # ?v2=1/0 で Cookie を操作
  └── layout :resolve_layout          # Cookie + opt-in の両方を確認

resolve_layout
  → cookies[:v2_ui].present? && @v2_layout == true ? "v2" : "application"
```

ページを v2 に対応させるには、各コントローラーのアクションに `use_v2_layout!` を呼ぶだけ。

```ruby
# 例: records_controller.rb
before_action :use_v2_layout!, only: %i[measure result show]
```

`use_v2_layout!` は内部で `request.variant = :v2` も設定するため、
Rails の variant 機能によりビューファイルが自動で切り替わる。

### ビューファイルの命名規則

| ファイル名 | 使われるタイミング |
|-----------|-----------------|
| `show.html.erb` | 通常（v1） |
| `show.html+v2.erb` | `request.variant = :v2` のとき |
| `create.turbo_stream.erb` | Turbo Stream レスポンス（v1） |
| `create.turbo_stream+v2.erb` | Turbo Stream レスポンス（v2） |

### 主要ファイル一覧

| ファイル | 役割 |
|---------|------|
| `app/assets/stylesheets/v2.css` | v2 専用 CSS（Bootstrap 不使用） |
| `app/views/layouts/v2.html.erb` | v2 レイアウト（最小構成） |
| `app/controllers/application_controller.rb` | Cookie フラグ制御、`use_v2_layout!` |

---

## 移行済みページ

### records#result（結果画面）

**対応ファイル:**

| ファイル | 内容 |
|---------|------|
| `app/views/records/result.html+v2.erb` | メインビュー |

**v1 からの変更点:**

- `bootstrap_form_with` → `form_with`
- 待ち時間を HH:MM:SS → 「5分18秒」形式に変更（`format_wait_time_human` ヘルパー）
- h1 を「着丼記録 No.X」に統一（v1 の「ちゃくどんレコード」から変更）
- 行列テーブルヘッダー「ひとこと」→「コメント」
- コメントフィールドのラベル・プレースホルダーを平易な表現に変更

---

### records#show（記録詳細）

**対応ファイル:**

| ファイル | 内容 |
|---------|------|
| `app/views/records/show.html+v2.erb` | メインビュー |
| `app/views/likes/_like_form.html+v2.erb` | いいねフォーム（ログイン状態で分岐） |
| `app/views/likes/_add_like.html+v2.erb` | いいね追加ボタン |
| `app/views/likes/_remove_like.html+v2.erb` | いいね削除ボタン |

**v1 からの変更点:**

- 待ち時間を `format_wait_time_human` で自然な形式に表示
- h1 を「着丼記録 No.X」に統一
- 行列テーブルヘッダー「ひとこと」→「コメント」
- 写真をテーブル内サムネイルとして表示し、クリックで別タブに原寸表示
- いいねを Font Awesome アイコン付きフォーム → `button_to`（`.btn-link` スタイル）に変更
- Bootstrap クラスをすべて除去

**いいねの動作:**
- ログイン済み: `button_to` で Turbo Stream 経由のいいね追加/削除
- 未ログイン: `link_to` で `prepare` アクション経由のリダイレクト

---

### records#measure（待機画面）

**対応ファイル:**

| ファイル | 内容 |
|---------|------|
| `app/views/records/measure.html+v2.erb` | メインビュー |
| `app/views/line_statuses/_line_status.html+v2.erb` | 行列状況の table row |
| `app/views/line_statuses/_new.html+v2.erb` | 追加報告モーダルフォーム |
| `app/views/line_statuses/new.turbo_stream+v2.erb` | モーダル挿入 |
| `app/views/line_statuses/create.turbo_stream+v2.erb` | 行追加 + モーダル閉鎖 |
| `app/javascript/controllers/v2_modal_controller.js` | モーダル表示制御 |

**v1 からの変更点:**

- 応援メッセージセクションを削除（将来的に機能ごと廃止予定）
- 行列の様子を Bootstrap accordion → シンプルな table に変更
- 追加報告フォームから写真投稿を削除
- タイマーのミリ秒表示をオフ（`data-timer-milliseconds-value="false"`）
- `<code>` タグ → `<span>` タグ（経過時間をページフォントに統一）
- `bootstrap_form_with` → `form_with`

**モーダルの動作:**
1. 追加報告リンク → GET → `new.turbo_stream+v2.erb` → `#modal` にフォーム挿入
2. `v2_modal_controller` が connect → `body.overflow = hidden`
3. 報告する → POST → `create.turbo_stream+v2.erb` → 行追加 + `#modal` リセット
4. `v2_modal_controller` が disconnect → `body.overflow = ""`

---

## 未移行ページ（Phase 2 以降）

| 優先度 | ページ | アクション | 参考 HTML |
|--------|--------|-----------|-----------|
| 1 | 店舗詳細 | `ramen_shops#show` | `docs/prototypes/shop_final.html` |
| 2 | 接続フォーム | `records#new` | `docs/prototypes/connect_final.html` |
| 3 | 近くの店舗 | `ramen_shops#near_shops` | `docs/prototypes/nearby_final.html` |
| 4 | ユーザー画面 | `users#show` | `docs/prototypes/user_final.html` |

---

## 廃止手順（全ページ移行完了後）

1. `ApplicationController` の `resolve_layout` / `handle_v2_flag` / `use_v2_layout!` を削除
2. `layout :resolve_layout` → `layout "v2"` または `v2.html.erb` を `application.html.erb` に昇格
3. `application.html.erb` / `application.scss` / Bootstrap 依存を削除
4. `app/views/**/*.html.erb`（v1 ビュー）を削除
5. `line_statuses_controller.rb` 等から `CheerMessage.request!` を削除（応援メッセージ廃止）

---

## 注意事項

- `application.html.erb` は v2 移行完了まで変更しない
- Bootstrap クラスは v2 ビューに残さない
- Stimulus 属性（`data-controller`, `data-action`, `data-*-target`）は v1/v2 共通で維持
- Turbo Stream のターゲット ID（`line_statuses`, `modal`）は維持
- `csrf_meta_tags` は v2 レイアウトにも必須
