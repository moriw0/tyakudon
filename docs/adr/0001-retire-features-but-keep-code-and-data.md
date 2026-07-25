# v2 で廃止する機能はコードとデータを温存する

v2 UI 移行にあたり、応援メッセージ（OpenAI による励ましメッセージ生成）とアバターを画面から全廃した。どちらも将来復活させる可能性があるため、**呼び出し経路と v1 依存のビューだけを削除し、モデル・ジョブ・spec・DB のデータは残す**ことにした。

具体的には次のとおり。

| 機能 | 削除するもの | 残すもの |
|------|-------------|---------|
| 応援メッセージ | `LineStatusesController#create` の `CheerMessage.request!` 呼び出し、`resources :cheer_messages` route、`CheerMessagesController` とその request spec | `CheerMessage` モデル（OpenAI プロンプト定義を含む）、`SpeakCheerMessageJob`、factory、model spec、job spec、`cheer_messages` テーブルとレコード |
| アバター | `UsersHelper#avatar_for`、`shared/_image_uploader`、`component/_avatar.scss`、v1 ビューのアバター表示、strong params の `:avatar` | `User#avatar` (`has_one_attached`) とバリデーション、S3 上の既存添付 |

## なぜ

呼び出し元のないモデルやジョブが残るため、**デッドコードの掃除として誤って削除される**おそれがある。特に `CheerMessage` は CLAUDE.md に「主要機能」として掲載されており、コードと文書が食い違って見える。この ADR はその食い違いが意図的であることを示すために存在する。

温存を選んだ理由は機能ごとに違う。

- **応援メッセージ**: 価値があるのは OpenAI のプロンプト設計（`SETTING_DESCRIPTION` / `EXAMPLE_MESSAGES`）と生成ロジックで、これを捨てると復活時に作り直しになる。一方 `CheerMessagesController` は呼び出し元が存在せず、かつ `logged_in_user` が掛かっていない未認証エンドポイントだった。任意の `record_id` で OpenAI 課金ジョブを enqueue できるため、温存の対象から外して閉じた。
- **アバター**: ユーザーがアップロードした実データであり、消すと不可逆。S3 の保管コストは小さい。

## 復活させるときは

どちらもビュー側だけを書き足せば戻る。応援メッセージは v2 の `records#measure` に broadcast 先の DOM と `turbo_stream_from` を用意し、`LineStatusesController#create` から `CheerMessage.request!` を呼び直す。ただし `SpeakCheerMessageJob` が使う `gpt-3.5-turbo` は古いモデルなので、復活時に選び直すこと。

## 温存しないと決めたもの

`image_uploader_controller.js` は残すが、これは温存の判断ではない。着丼写真の投稿（`records#result`）で現役のため単に生きているだけで、アバター機能とは無関係。
