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
| Flash | notice/alert 両方 | notice（通常）+ alert（赤字） |

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
| `app/views/layouts/v2.html.erb` | v2 レイアウト（フッターリンク・モーダル領域を含む） |
| `app/views/shared/_nav.html+v2.erb` | 共通ナビパーシャル（全コンテンツページに挿入） |
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

### 共通ナビゲーション構造

全コンテンツページに `shared/_nav.html+v2.erb` を挿入する。パンくずリストの直後（`<hr>` の後）に `render 'shared/nav'` を書く。

```erb
<p>[パンくず]</p>
<hr>

<%= render 'shared/nav' %>
<hr>

<h1>...</h1>
```

ナビの内容（左から右）：

| 条件 | 表示 |
|------|------|
| 接続中（`remember_record?`） | 接続中記録リンク（`measure_record_path`） |
| 未接続 | 現在地から接続ボタン（`geolocation_controller`） |
| 常時 | ホーム \| 店舗検索 |
| ログイン済み | お気に入り店舗 \| ユーザー名（`users#show` リンク） |
| 未ログイン | ユーザー登録 \| ログイン |

ログアウトリンクはナビに置かず `users#show` に配置する。

フッター（レイアウトが自動挿入）には情報系リンクを配置する：お知らせ / FAQ / 着丼とは / 利用規約 / プライバシーポリシー

### 共通パーシャル

| ファイル | 用途 |
|---------|------|
| `app/views/shared/_nav.html+v2.erb` | 全コンテンツページ共通ナビ（接続ボタン・主要リンク・認証リンク） |
| `app/views/line_statuses/_queue_table.html+v2.erb` | 行列状況テーブル（measure/result/show で共用）。`tbody_id` ローカル変数を渡すと `<tbody id="...">` を付与できる（省略時は属性なし） |
| `app/views/line_statuses/_form_fields.html+v2.erb` | 接続先・待ち行列数・コメントフォームフィールド（records#new / 追加報告で共用） |

### 日時表示の統一

| ヘルパー | 出力例 | 用途 |
|---------|--------|------|
| `format_datetime` | `2024/01/01(月) 12:34` | 一覧テーブルの日時列 |
| `format_datetime_detail` | `2024/01/01(月) 12:34:56` | 詳細テーブルの接続日時・着丼日時 |
| `format_only_detail_time` | `12:34:56` | 行列状況テーブルの時刻列 |

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
- 「現在地から接続」ボタンを `shared/_nav` パーシャルに配置（接続中は接続中記録リンクを表示）

**近くの店舗の動作:**

1. 共通ナビの「現在地から接続」ボタン → `geolocation#navigate` が現在地を取得
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
- 「この店舗に接続する」ボタンは非設置（共通ナビの「現在地から接続」から導線を統一）
- お気に入りを Font Awesome アイコン付きフォーム → `button_to`（`.btn-link` スタイル）に変更
- ページネーションを横並び表示、現在ページを太字で強調
- 行列列を `format_line_status` ヘルパーで「店外 10人」「着席」形式に表示
- リタイア記録の待ち時間横に `[リタイア]` を表示
- 日時は `format_datetime`（`2024/01/01(月) 12:34` 形式）で表示

**お気に入りの動作:**
- ログイン済み: `button_to` で Turbo Stream 経由の登録/解除、`#favorite_form` を即時切り替え
- 未ログイン: `link_to` で `prepare_favorite` アクション経由のリダイレクト

---

---

### faqs#index / show（よくある質問）

**対応ファイル:**

| ファイル | 内容 |
|---------|------|
| `app/views/faqs/index.html+v2.erb` | よくある質問一覧 |
| `app/views/faqs/show.html+v2.erb` | 質問詳細 |

**v1 からの変更点:**

- Bootstrap accordion を廃止 → `h2`（質問）+ `p`（回答）のシンプルな構造に変更
- index: `detail` フィールドは表示せず、`detail` が存在する場合のみ「詳細を見る」リンクを表示
- show: `h1` で質問を表示、`detail` を本文として出力
- 管理者向け編集・削除リンクをページ末尾に配置

**注意点:**

- `v2_ui_flag_spec` の「opt-in なし」検証で使っていた `faqs_path` を `new_shop_register_request_path` に変更済み（`faqs_controller.rb` に `use_v2_layout!` を追加したため）

---

### landing_page#index（ランディングページ）

**対応ファイル:**

| ファイル | 内容 |
|---------|------|
| `app/controllers/landing_page_controller.rb` | `resolve_lp_layout` で v2/lp を切り替え |
| `app/views/landing_page/index.html+v2.erb` | メインビュー |
| `app/views/landing_page/_usage_steps.html+v2.erb` | 登録ステップ（ol リスト） |
| `app/views/landing_page/_faqs.html+v2.erb` | FAQ 抜粋（最大5件） |

**v1 からの変更点:**

- `LandingPageController` は `layout 'lp'` をハードコードしていたため、`ApplicationController#resolve_layout` が効かなかった。`layout :resolve_lp_layout` メソッドで `cookies[:v2_ui]` を確認して `'v2'` / `'lp'` を返すよう変更
- ヘッダー画像・キャッチコピー画像を廃止。テキストのみのシンプルな構成に変更
- `dl`（接続/着丼の用語説明）は `dt > strong` で用語を強調
- CTA ボタンは 2 つとも `.btn` クラスで統一
- 利用手順は `_usage_steps` パーシャル（`ol.steps-list` リスト）に切り出し。`<p>` マージンを `.steps-list li p { margin: 0.25em 0 0 }` でスコープして調整
- FAQ は `_faqs` パーシャルで `@faqs`（最大3件、`created_at: :desc`）を `dl > dt > strong / dd` で表示し、末尾に「全てのよくある質問を見る」リンクを配置
- 新着着丼テーブルは `new_records/_records_table` パーシャルを `records: @new_records`（5件）で呼び出し

**注意点:**

- `LandingPageController` は `before_action :disable_connect_button` を持つため、nav パーシャルの「現在地から接続」ボタンが無効化される（`remember_record?` の場合を除く）
- `@faqs` は `LandingPageController#index` で `Faq.order(created_at: :desc).limit(3)` としてセットしている

---

## 未移行ページ

### Phase 2e: 管理・低優先度（対象外検討可）

| ページ | アクション | 備考 |
|--------|-----------|------|
| 記録編集 | `records#edit` | 管理者用 |
| 店舗登録申請 | `shop_register_requests#new` | |
| FAQ 管理 CRUD | `faqs#new/edit/create/update/destroy` | 管理者用 |
| 管理者お知らせ CRUD | `admin/announcements#*` | 管理者用 |
| ユーザー編集 | `users#edit` | 本人のみ |
| ユーザー一覧 | `users#index` | 管理者用 |

---

### favorite_records#index（お気に入り記録）

**対応ファイル:**

| ファイル | 内容 |
|---------|------|
| `app/views/favorite_records/index.html+v2.erb` | メインビュー |
| `app/views/favorite_records/_filter_form.html+v2.erb` | 絞り込みモーダル |
| `app/views/favorite_records/filter.turbo_stream+v2.erb` | フィルタ後のモーダル差し替え |

**v1 からの変更点:**

- タブメニュー (`home/tabmenu`) を廃止
- `bootstrap_form_with` → `form_with`
- フィルタ UI をモーダル構造で維持しつつ v2 スタイルに変更
- `_filter_form.html+v2.erb` でチェックボックス `id` を明示し、店舗名ラベルクリックでトグル可能に
- テーブル列: 店舗名 / 待ち時間（詳細リンク付き）/ 接続日時 / 状況
- 未ログイン・お気に入りなし・記録なしの3状態を個別に処理

**注意点:**

- `use_v2_layout!` を `filter` アクションにも適用が必要（Turbo Stream レスポンス時に `request.variant = :v2` をセットするため）
- `filter.turbo_stream+v2.erb` がないと `filter.turbo_stream.erb` が使われ、v1 パーシャル（`_filter_form.html.erb`）が描画される

---

### users#favorite_shops（お気に入り店舗）

**対応ファイル:**

| ファイル | 内容 |
|---------|------|
| `app/views/users/favorite_shops.html+v2.erb` | メインビュー |

**v1 からの変更点:**

- `render 'show_layout'` + `_favorite_shops` パーシャル構造 → 単一ビューに統合
- Bootstrap list-group → シンプルなテーブルに変更
- テーブル列: 店舗名（リンク）/ 最新の待ち時間
- 待ち時間は `format_wait_time_human` のみ（時刻なし）、記録なしは「記録なし」表示

---

### ramen_shops#index（店舗検索）

**対応ファイル:**

| ファイル | 内容 |
|---------|------|
| `app/views/ramen_shops/index.html+v2.erb` | メインビュー |

**v1 からの変更点:**

- タブメニュー (`home/tabmenu`) を廃止
- `shared/_search_form` パーシャル → ビュー内インライン `search_form_for` に統合
- `render @ramen_shops`（v1 パーシャル）→ シンプルなテーブルに変更
- テーブル列: 店舗名（リンク）/ 平均待ち時間（`shop.average_wait_time`）
- 件数は `@result_count` を `small` タグで表示
- 0件時に店舗登録リクエストリンクを表示

---

### users#show（ユーザープロフィール）

**対応ファイル:**

| ファイル | 内容 |
|---------|------|
| `app/views/users/show.html+v2.erb` | メインビュー |

**v1 からの変更点:**

- v1 の `_show_layout` / `_show` 2段パーシャル構造 → 単一ビューに統合
- アバター画像を廃止（v2 デザイン方針：外部フォント・画像なし）
- `_stats` パーシャルをインライン展開（レコード数・お気に入り店）
- 着丼記録を Bootstrap リスト（`_record_overview`）→ シンプルなテーブルに変更
- テーブル列: 店舗名・待ち時間・接続日時・状況・詳細
- 状況列は `format_line_status(record.line_statuses.first)` で表示
- 詳細リンクは `record_path(record, back: 'user')` で戻り先を指定
- 未有効化ユーザーの表示をシンプルなテーブル行に変更

---

### sessions#new（ログイン）

**対応ファイル:**

| ファイル | 内容 |
|---------|------|
| `app/views/sessions/new.html+v2.erb` | メインビュー |
| `app/views/shared/_google_login.html+v2.erb` | Googleログインボタン |

**v1 からの変更点:**

- `bootstrap_form_with` → `form_with`
- メール・パスワード・ログイン保持チェックボックス・送信ボタン
- Google OAuth ボタンを `_google_login.html+v2.erb` パーシャルに切り出し
- パスワードを忘れた方・新規登録リンクを `<hr>` 後に配置

---

### users#new（新規登録）

**対応ファイル:**

| ファイル | 内容 |
|---------|------|
| `app/views/users/new.html+v2.erb` | メインビュー |
| `app/views/shared/_google_login.html+v2.erb` | Googleログインボタン |
| `app/views/shared/_agreement.html+v2.erb` | 利用規約・プライバシーポリシー表示 + 送信ボタン |

**v1 からの変更点:**

- アバター投稿フィールドを廃止（v2 デザイン方針：外部フォント・画像なし）
- `_agreement` パーシャルの同意チェックボックス・Stimulus による submit disabled 制御を廃止（テキスト表示のみ）
- バリデーションエラーは `@user.errors.full_messages` を `<ul>` で上部に表示
- `use_v2_layout!` を `create` アクションにも適用（バリデーション失敗時の `render 'new'` で variant が効くように）

**注意点:**

- `create` アクションに `use_v2_layout!` を追加しないと、バリデーション失敗時に v1 レイアウトで `new` が再描画される

---

### password_resets#new / edit（パスワードリセット）

**対応ファイル:**

| ファイル | 内容 |
|---------|------|
| `app/views/password_resets/new.html+v2.erb` | メールアドレス入力フォーム |
| `app/views/password_resets/edit.html+v2.erb` | 新パスワード設定フォーム |

**v1 からの変更点:**

- `bootstrap_form_with` → `form_with`
- シンプルなフォーム 2 画面。v2 CSS のみでレイアウト
- `new` にログイン画面への戻りリンクを追加

---

### 共通パーシャル（認証フロー）

| ファイル | 用途 |
|---------|------|
| `app/views/shared/_google_login.html+v2.erb` | `button_to` で `/auth/google_oauth2` に POST。`turbo: false` が必要 |
| `app/views/shared/_agreement.html+v2.erb` | 利用規約・プライバシーポリシーへのリンクテキスト + 送信ボタン |

**Google ログインボタンの実装パターン:**

```erb
<%= button_to '/auth/google_oauth2', method: :post, data: { turbo: false }, class: 'btn btn-block' do %>
  Googleアカウントでログインする
<% end %>
```

---

### statics#terms / statics#privacy_policy（静的ページ）

**対応ファイル:**

| ファイル | 内容 |
|---------|------|
| `app/views/statics/terms.html+v2.erb` | 利用規約 |
| `app/views/statics/privacy_policy.html+v2.erb` | プライバシーポリシー |

**v1 からの変更点:**

- `div#statics-terms` / `div#statics-privacy_policy` ラッパーを除去
- パンくずリスト + `<hr>` を先頭に追加
- 本文テキストは変更なし

---

### new_records#index（ホーム・新着記録）

**対応ファイル:**

| ファイル | 内容 |
|---------|------|
| `app/views/new_records/index.html+v2.erb` | メインビュー |

**v1 からの変更点:**

- タブメニュー（`home/tabmenu`）を廃止
- `render @records`（v1 パーシャル）→ シンプルなテーブルに変更
- テーブル列: 店舗名（リンク）/ 待ち時間（詳細リンク）/ 接続行列 / 接続日時 / 記録者（リンク）
- 接続中レコード（`wait_time: nil`）は「接続中」テキストで `record_path` へリンク
- このページは root（ホーム）であるためパンくずリストなし（スタイルガイドの「ダッシュボードは h1 省略可」と同様の扱い）
- お気に入り店舗の記録フィードは `favorite_records#index` へ分離済み

**注意点:**

- `new_records#index` が root なため、`v2_ui_flag_spec` の「opt-in なし」テストで使用していた `root_path` を `announcements_path` に変更した。`AnnouncementsController` が v2 対応になった場合はテストの参照先を別ルートに更新すること

---

### announcements#index / show（お知らせ）

**対応ファイル:**

| ファイル | 内容 |
|---------|------|
| `app/views/announcements/index.html+v2.erb` | お知らせ一覧 |
| `app/views/announcements/show.html+v2.erb` | お知らせ詳細 |

**v1 からの変更点:**

- `section` / Bootstrap クラスを除去
- index: `ul` リスト → テーブル（日付 / タイトル列）に変更
- show: パンくずリスト + `<hr>` を先頭に追加、日付を `<small>` で h1 の上に配置
- show: Rich Text 本文（`@announcement.body`）はそのまま出力（ActionText が自動サニタイズ済み）

**注意点:**

- `v2_ui_flag_spec` の「opt-in なし」検証で使っていた `announcements_path` を `faqs_path` に変更し、その後 `FaqsController` が v2 対応になったため `new_shop_register_request_path` に更新済み

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
