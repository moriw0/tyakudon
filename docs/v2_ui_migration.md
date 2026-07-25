# v2 UI 移行ガイド

Bootstrap 5 + Google Fonts (Noto Sans JP) + 固定ヘッダーに依存した v1 UI から、ブラウザデフォルト重視のミニマルな v2 UI へ段階的に移行する。

一括置換はリスクが高いため、**Cookie フラグ + アクション単位の opt-in + Rails variants** の組み合わせで、既存ユーザーへの影響をゼロに保ちながらページ単位で移行する。

このファイルは**移行中ずっと変わらない規約**を扱う。どのアクションが移行済みかという進捗は [issue #332](https://github.com/moriw0/tyakudon/issues/332) のチェックリストで管理する（増減する情報をこのファイルに置くと必ず腐るため）。

関連: [ADR-0002 Google Maps を UI から廃止する](./adr/0002-drop-google-maps-from-the-ui.md) / [ADR-0001 v2 で廃止する機能はコードとデータを温存する](./adr/0001-retire-features-but-keep-code-and-data.md)

---

## デザイン方針

`docs/prototypes/` 配下の静的 HTML プロトタイプで確立した方針を Rails 本体に移植する。

| 項目 | v1 | v2 |
|------|-----|-----|
| CSS フレームワーク | Bootstrap 5 | なし（`v2.css` のみ） |
| フォント | Noto Sans JP (Google Fonts) | system sans-serif |
| レイアウト幅 | 固定ヘッダー + コンテナ | `max-width: 800px`, `margin: auto` |
| セクション区切り | カード、ボーダー | `<hr>` |
| ボタン | Bootstrap `.btn-primary` 等 | `.btn` / `.btn-block` / `.btn-link` |
| フォーム | `bootstrap_form_with` | `form_with` |
| 表 | Bootstrap テーブル | ブラウザデフォルト |
| Flash | notice/alert 両方 | notice（通常）+ alert（赤字） |
| 地図 | Google Maps 埋め込み | なし（ADR-0002） |
| 画像 | アバター・ヘッダー画像 | 着丼写真のみ |

### CSS 設計原則

- ブラウザのデフォルトスタイルを最大限活用する
- クラスは最小限。構造が正しければ見た目は自然に整う
- レスポンシブ: 480px 以下で補助列（作者・コメント・写真・ジャンル等）を非表示
- 幅の広いテーブルは列を隠さず横スクロールで対応する

---

## 切り替え方法

| 操作 | 効果 |
|------|------|
| `?v2=1` を付けてアクセス | Cookie をセット → 以降すべてのページで v2 が有効 |
| `?v2=0` を付けてアクセス | Cookie を削除 → v1 に戻る |
| Cookie なし / opt-in していないアクション | v1 が表示される |

フラグをオンにしても、opt-in 済みのアクションだけが v2 で表示される。未対応アクションは Cookie があっても v1 のままなので、1ページ内でデザインが混ざることはない。

UI 上の切り替え導線は `ApplicationHelper#toggle_ui_path`（既存クエリパラメータを保持しつつ `v2` パラメータだけ差し替える）を使い、v2 は `shared/_nav`、v1 は `layouts/_common_links` に置いている。

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

アクションを v2 に対応させるには `use_v2_layout!` を呼ぶだけ。

```ruby
# 例: records_controller.rb
before_action :use_v2_layout!, only: %i[measure result show new create]
```

`use_v2_layout!` は内部で `request.variant = :v2` も設定するため、Rails の variant 機能によりビューファイルが自動で切り替わる。

### ビューファイルの命名規則

| ファイル名 | 使われるタイミング |
|-----------|-----------------|
| `show.html.erb` | 通常（v1） |
| `show.html+v2.erb` | `request.variant = :v2` のとき |
| `create.turbo_stream.erb` | Turbo Stream レスポンス（v1） |
| `create.turbo_stream+v2.erb` | Turbo Stream レスポンス（v2） |

### 主要ファイル

| ファイル | 役割 |
|---------|------|
| `app/assets/stylesheets/v2.css` | v2 専用 CSS（Bootstrap 不使用） |
| `app/views/layouts/v2.html.erb` | v2 レイアウト（フッターリンク・モーダル領域を含む） |
| `app/views/shared/_nav.html+v2.erb` | 共通ナビパーシャル（全コンテンツページに挿入） |
| `app/controllers/application_controller.rb` | Cookie フラグ制御、`use_v2_layout!`、`redirect_if_connecting` |
| `app/helpers/application_helper.rb` | `toggle_ui_path` |
| `config/locales/views.ja.yml` | v2 UI 文言の i18n 管理（ビュー専用、`ja.yml` とは分離） |

---

## UI 文言管理 (i18n)

v2 ビューのハードコード文字列はすべて `config/locales/views.ja.yml` で管理し、ビュー内では Rails の lazy lookup `t('.key')` を使う。

パーシャルの lazy lookup はパーシャル自身のパスを基準に解決されるため、呼び出し元に依存せず `t('.key')` をそのまま書ける。

---

## 共通ナビゲーション構造

全コンテンツページで、パンくずリストの直後（`<hr>` の後）に `render 'shared/nav'` を書く。

```erb
<p>[パンくず]</p>
<hr>

<%= render 'shared/nav' %>
<hr>

<h1>...</h1>
```

ナビの内容（左から右）:

| 条件 | 表示 | リンク先 |
|------|------|---------|
| 常時 | 新着記録 \| 店舗検索 | `root_path` / `ramen_shops_path` |
| ログイン済み | お気に入り店舗の記録 \| ユーザー名 | `favorite_records_path` / `users#show` |
| ログイン済み・接続中（`remember_record?`） | 接続中記録 | `measure_record_path` |
| ログイン済み・未接続 | 現在地から接続ボタン | `geolocation_controller` |
| 未ログイン | ユーザー登録 \| ログイン | `new_user_path` / `login_path` |
| 常時 | 旧UIへ切り替え | `toggle_ui_path(enable_v2: false)` |

お気に入り**店舗**の一覧（`users#favorite_shops`）はナビに置かず、`users#show` のステータス表からのみ辿る。ナビにあるのはお気に入り店舗の**記録**一覧なので、ラベルで区別すること（[CONTEXT.md](../CONTEXT.md) の「お気に入り店舗」を参照）。

ログアウトリンクはナビに置かず `users#show` に配置する。

フッター（レイアウトが自動挿入）には情報系リンクを置く: お知らせ / FAQ / 着丼とは / 利用規約 / プライバシーポリシー

`before_action :disable_connect_button` を使うと「現在地から接続」ボタンを無効化できる（`remember_record?` の場合を除く）。

---

## 共通パーシャル

| ファイル | 用途 |
|---------|------|
| `shared/_nav.html+v2.erb` | 全コンテンツページ共通ナビ |
| `shared/_google_login.html+v2.erb` | Google ログインボタン。`label` ローカル変数でラベルを差し替えられる |
| `shared/_agreement.html+v2.erb` | 利用規約・プライバシーポリシーへのリンク + 送信ボタン |
| `line_statuses/_queue_table.html+v2.erb` | 行列状況テーブル（measure/result/show で共用）。`tbody_id` を渡すと `<tbody id="...">` を付与 |
| `line_statuses/_form_fields.html+v2.erb` | 接続先・待ち行列数・コメントのフォームフィールド（`records#new` と追加報告で共用） |
| `new_records/_records_table.html+v2.erb` | 着丼記録一覧テーブル（ホーム・ランディングページで共用）|
| `records/_photo_thumb.html.erb` | 着丼写真のサムネイル。variant を持たず v1/v2 共用 |
| `records/_wait_time_cell.html.erb` | 待ち時間セル（リタイア表示を含む）。variant を持たず v1/v2 共用 |

---

## 実装パターン

### Google ログインボタン

`button_to` で `/auth/google_oauth2` に POST する。`turbo: false` が必須。

```erb
<%= button_to '/auth/google_oauth2', method: :post, data: { turbo: false }, class: 'btn btn-block' do %>
  Googleアカウントでログインする
<% end %>
```

### いいね・お気に入りの分岐

ログイン状態でフォームを切り替える。

- ログイン済み: `button_to` で Turbo Stream 経由の追加/削除。`#favorite_form` / `#like_form` を即時差し替え
- 未ログイン: `link_to` で `prepare` / `prepare_favorite` アクション経由のリダイレクト

Font Awesome アイコンは使わず `.btn-link` スタイルのテキストにする。

### モーダル

Bootstrap Modal ではなく `v2_modal_controller.js` を使う。レイアウトの `<div id="modal">` を Turbo Stream で置き換える。

1. リンク（`data-turbo-stream: true`）→ GET → `new.turbo_stream+v2.erb` が `#modal` にフォームを挿入
2. `v2_modal_controller` が connect → `body.overflow = hidden`
3. 送信 → POST → `create.turbo_stream+v2.erb` が対象を更新 + `#modal` をリセット
4. `v2_modal_controller` が disconnect → `body.overflow = ""`

### 日時表示の統一

| ヘルパー | 出力例 | 用途 |
|---------|--------|------|
| `format_datetime` | `2024/01/01(月) 12:34` | 一覧テーブルの日時列 |
| `format_datetime_detail` | `2024/01/01(月) 12:34:56` | 詳細テーブルの接続日時・着丼日時 |
| `format_only_detatil_time` | `12:34:56` | 行列状況テーブルの時刻列（メソッド名は `detatil` と綴りが誤っている） |

区切り文字は `/` に統一（`.` は使わない）。待ち時間は `format_wait_time_human`（「5分18秒」形式）、行列状況は `format_line_status`（「店外 10人」「着席」形式）を使う。

### 二重接続ガード

`before_action :redirect_if_connecting` を使うと、接続中（`cookies[:record_id]` が存在）の場合にルートパスへリダイレクトする。`ramen_shops#near_shops` に適用済み。

---

## 移行時の落とし穴

- **`create` / `update` にも opt-in が必要。** バリデーション失敗時に `render 'new'` / `render 'edit'` するアクションで `use_v2_layout!` を呼んでいないと、エラー時だけ v1 レイアウトで再描画される。
- **Turbo Stream アクションにも opt-in と variant が必要。** `filter.turbo_stream+v2.erb` を用意せず opt-in だけ足すと、`filter.turbo_stream.erb` が使われて v1 パーシャルが描画される。
- **`layout` をハードコードしているコントローラーは `resolve_layout` が効かない。** `LandingPageController` は `layout 'lp'` だったため、`layout :resolve_lp_layout` を定義して Cookie を見て `'v2'` / `'lp'` を返すようにしている。
- **`spec/requests/v2_ui_flag_spec.rb` は「opt-in していないルート」を1本必要とする。** 移行が進んでそのルートが v2 対応になるたびに、spec の参照先を別のルートへ差し替える必要がある。移行完了時にはこの spec 自体が不要になる。

---

## 廃止手順（全アクション移行完了後）

1. `ApplicationController` の `resolve_layout` / `handle_v2_flag` / `use_v2_layout!` を opt-out 式に変更し、既定を v2 に反転する
2. 本番で安定を確認する
3. `layout "v2"` 直書きに変更し、フラグ機構（`handle_v2_flag` / `use_v2_layout!` / `toggle_ui_path` / `v2_ui_flag_spec`）を削除
4. `v2.html.erb` を `application.html.erb` に昇格し、`+v2` サフィックスを全ファイルから外す
5. v1 ビュー（`app/views/**/*.html.erb` の v1 版）、`lp.html.erb`、`layouts/_admin_links` / `_common_links` / `_header` / `_footer` / `_side_menu_links` / `_links_for_*`、`home/_tabmenu` を削除
6. `application.scss` と Bootstrap / Font Awesome / Google Fonts / Google Maps JS API の依存を削除
7. v1 でのみ使われていた Stimulus コントローラーを削除
8. ADR-0001 に沿って、廃止機能のビュー層だけを削除する（モデル・ジョブ・データは残す）

---

## 注意事項

- `application.html.erb` は移行完了まで変更しない
- Bootstrap クラスを v2 ビューに残さない
- Stimulus 属性（`data-controller`, `data-action`, `data-*-target`）は v1/v2 共通で維持する
- Turbo Stream のターゲット ID（`line_statuses`, `modal`）は維持する
- `csrf_meta_tags` は v2 レイアウトにも必須
