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
before_action :use_v2_layout!, only: %i[measure result show new create]
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
| `app/views/layouts/v2.html.erb` | v2 レイアウト（ナビ・フッター・モーダル領域を含む） |
| `app/controllers/application_controller.rb` | Cookie フラグ制御、`use_v2_layout!`、`redirect_if_connecting` |
| `config/locales/views.ja.yml` | v2 UI 文言の i18n 管理（ビュー専用、`ja.yml` とは分離） |

### UI 文言管理（i18n）

v2 ビューのハードコード文字列はすべて `config/locales/views.ja.yml` で管理する。
ビュー内では Rails lazy lookup `t('.key')` を使用する。

```yaml
# config/locales/views.ja.yml の構造
ja:
  layouts:
    v2:
      nav: { ... }
      footer: "着丼 - ラーメン待ち時間記録システム"
  records:
    measure: { ... }
    result: { ... }
    show: { ... }
  line_statuses:
    queue_table: { ... }
    form_fields: { ... }
  ramen_shops:
    show: { ... }
    near_shops: { ... }
  likes:
    add_like: { ... }
```

パーシャルの lazy lookup はパーシャル自身のパスを基準に解決されるため、
呼び出し元に依存せず `t('.key')` をそのまま使用できる。

### 共通パーシャル

| ファイル | 用途 |
|---------|------|
| `app/views/line_statuses/_queue_table.html+v2.erb` | 行列状況テーブル（measure/result/show で共用）。`tbody_id` ローカル変数を渡すと `<tbody id="...">` を付与できる（省略時は属性なし） |
| `app/views/line_statuses/_form_fields.html+v2.erb` | 接続先・待ち行列数・コメントフォームフィールド（records#new / 追加報告で共用） |

### 日時表示の統一

| ヘルパー | 出力例 | 用途 |
|---------|--------|------|
| `format_datetime` | `2024/01/01(月) 12:34` | 一覧テーブルの日時列 |
| `format_datetime_detail` | `2024/01/01(月) 12:34:56` | 詳細テーブルの接続日時・着丼日時 |
| `format_only_detatil_time` | `12:34:56` | 行列状況テーブルの時刻列 |

区切り文字は `/` に統一（`.` は使わない）。

### 二重接続ガード

`ApplicationController` の `redirect_if_connecting` を `before_action` として使うと、
`cookies[:record_id]` が存在する場合（接続中）にルートパスへリダイレクトする。
現在 `ramen_shops#near_shops` に適用済み。

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
| `app/views/line_statuses/_form_fields.html+v2.erb` | 接続先・待ち行列数・コメントの共通フィールド（records#new と共有） |
| `app/views/line_statuses/new.turbo_stream+v2.erb` | モーダル挿入 |
| `app/views/line_statuses/create.turbo_stream+v2.erb` | 行追加 + モーダル閉鎖 |
| `app/javascript/controllers/v2_modal_controller.js` | モーダル表示制御 |

**v1 からの変更点:**

- 応援メッセージセクションを削除（将来的に機能ごと廃止予定）
- 行列状況を Bootstrap accordion → `line_statuses/_queue_table` パーシャルに変更
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

### records#new（接続フォーム）

**対応ファイル:**

| ファイル | 内容 |
|---------|------|
| `app/views/records/new.turbo_stream+v2.erb` | `#modal` にモーダルを挿入 |
| `app/views/records/_new.html+v2.erb` | モーダルラッパー |
| `app/views/records/_form.html+v2.erb` | フォームパーシャル |
| `app/views/records/new_with_errors.turbo_stream+v2.erb` | エラー時 `#new_record_form` を更新 |
| `app/views/line_statuses/_form_fields.html+v2.erb` | 接続先・待ち行列数・コメントの共通フィールド |
| `app/javascript/controllers/record_form_controller.js` | 接続ボタン押下時に `started_at` を設定 |

**v1 からの変更点:**

- Bootstrap Modal → v2-modal コントローラーによるモーダルに変更
- `bootstrap_form_with` → `form_with`
- `started_at` の設定を `modal_controller` から `record_form_controller` に移行
- フォームフィールドを `line_statuses/_form_fields.html+v2.erb` に切り出し、追加報告フォームと共通化
- 写真投稿フィールドを削除

**接続フォームの動作:**

1. near_shops の「接続する」リンク（`data-turbo-stream: true`）→ GET `records#new`
2. `new.turbo_stream+v2.erb` が `#modal` を `_new.html+v2.erb` で置き換え
3. `v2_modal_controller` が connect → モーダル表示
4. 接続ボタン押下時に `record-form#fetchStartAt` が `started_at` に現在時刻を設定
5. フォーム送信 → 成功: `measure` へリダイレクト / 失敗: `#new_record_form` をインライン更新

---

### ramen_shops#near_shops（近くの店舗）

**対応ファイル:**

| ファイル | 内容 |
|---------|------|
| `app/views/ramen_shops/near_shops.html+v2.erb` | 現在地周辺の店舗一覧テーブル |
| `app/javascript/controllers/geolocation_controller.js` | 位置情報取得後に near_shops へ遷移 |

**v1 からの変更点:**

- Google Maps 廃止 → シンプルなテーブル一覧に変更
- `near_shops` が JSON 専用 → HTML レスポンスを追加（`respond_to` ブロック）
- v2 レイアウトに「現在地から接続」ボタンを追加（接続中は接続中レコードへのリンク）

**近くの店舗の動作:**

1. v2 レイアウトの「現在地から接続」ボタン → `geolocation#navigate` が現在地を取得
2. `/near_shops?lat=X&lng=Y` へリダイレクト → テーブル形式で店舗一覧を表示
3. 各行の「接続する」リンク（`data-turbo-stream: true`）→ `records#new` モーダルを表示
4. 接続中に near_shops へアクセスすると `redirect_if_connecting` でルートへリダイレクト

---

### ramen_shops#show（店舗詳細）

**対応ファイル:**

| ファイル | 内容 |
|---------|------|
| `app/views/ramen_shops/show.html+v2.erb` | メインビュー |
| `app/views/ramen_shops/_favorite_form.html+v2.erb` | お気に入りフォーム（ログイン状態で分岐） |
| `app/views/ramen_shops/_add_favorite.html+v2.erb` | お気に入り登録ボタン |
| `app/views/ramen_shops/_remove_favorite.html+v2.erb` | お気に入り解除ボタン |
| `app/views/favorites/create.turbo_stream+v2.erb` | 登録後に解除ボタンへ切り替え |
| `app/views/favorites/destroy.turbo_stream+v2.erb` | 解除後に登録ボタンへ切り替え |

**v1 からの変更点:**

- Google Maps 埋め込み (`shop_map` パーシャル) を廃止 → `[地図]` テキストリンクのみ
- 着丼記録を Bootstrap リスト → シンプルなテーブル（待ち時間・行列・接続日時・記録者・コメント）に変更
- 「この店舗に接続する」ボタンは非設置（ナビの「現在地から接続」から導線を統一）
- お気に入りを Font Awesome アイコン付きフォーム → `button_to`（`.btn-link` スタイル）に変更
- ページネーションを横並び表示、現在ページを太字で強調
- 行列列を `format_line_status` ヘルパーで「店外 10人」「着席」形式に表示
- リタイア記録の待ち時間横に `[リタイア]` を表示
- 日時は `format_datetime`（`2024/01/01(月) 12:34` 形式）で表示

**お気に入りの動作:**
- ログイン済み: `button_to` で Turbo Stream 経由の登録/解除、`#favorite_form` を即時切り替え
- 未ログイン: `link_to` で `prepare_favorite` アクション経由のリダイレクト

---

## 未移行ページ（Phase 2 以降）

| 優先度 | ページ | アクション | 参考 HTML |
|--------|--------|-----------|-----------|
| 1 | ユーザー画面 | `users#show` | `docs/prototypes/user_final.html` |

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
