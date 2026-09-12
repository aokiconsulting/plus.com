# ESTIMATE — 株式会社Plus 見積・請求アプリ

現場でスマホから見積書・請求書を作り、その場でお客様に渡すためのアプリです。
Developer：あおきコンサルティング株式会社

- `app/` … アプリ本体（ブラウザで開くだけで動く1ファイル構成＋ホーム画面に追加できる設定）
- `supabase/` … クラウド保存（Supabase）の初期設定SQL
- `docs/` … 開発仕様書と、Claude内で動く試作品
- `.github/workflows/` … GitHub Pages への自動公開

---

## 1. できること（Ver.1）

| 機能 | 内容 |
|---|---|
| 見積作成 | お客様→現場→基本情報→明細→確認の5ステップ。自動計算・下書きの自動保存 |
| 見積書・請求書 | いまの様式と同じレイアウトで表示。ロゴ・角印つき。担当者名入り |
| 請求書 | 見積から1ボタンで変換。月日・立替経費・お振込先・お支払期限。未送付／送付済／入金済 |
| 顧客管理 | 代表番号・担当者携帯（タップで電話）、メール（タップで送信）、住所（タップで地図） |
| マスター | 工事項目89件・商品。Excelで書き出し／取り込み。テンプレート5種 |
| 権限 | 管理者（全権限）／作成者（作成のみ）。スタッフ登録・パスワード再設定は管理者 |
| クラウド同期 | 全員で同じデータ。同期中／同期済み／エラーを画面右上に表示。最後に同期した人も表示 |
| 社内管理 | 原価・粗利・粗利率の円グラフ（管理者のみ）。粗利率が低いと警告 |

---

## 2. 公開までの手順（初回のみ・所要30分ほど）

### 手順A：GitHub に置く

1. GitHub にログインし「New repository」→ 名前 `plus-estimate` → **Private** で作成
2. このフォルダの中身をそのままアップロード（パソコンなら「Add file → Upload files」にフォルダごとドラッグ）
3. リポジトリの **Settings → Pages → Build and deployment → Source** を **GitHub Actions** にする
4. 数分待つと `https://<ユーザー名>.github.io/plus-estimate/` でアプリが開きます
   - この時点では「端末内モード」（1台の中だけに保存）で動きます

### 手順B：クラウド保存（Supabase）をつなぐ

1. https://supabase.com で無料アカウントを作り「New project」（リージョンは Northeast Asia (Tokyo)）
2. 左メニュー **SQL Editor** → `supabase/schema.sql` の中身を貼り付けて **Run**
3. 左メニュー **Authentication → Providers → Email** で
   - Enable Email provider：ON
   - Confirm email：OFF（招待メールだけで運用するため）
4. **Authentication → URL Configuration** の Site URL と Redirect URLs に、手順Aで出来たアプリのURLを入れる
5. **Project Settings → API** から `Project URL` と `anon public` の2つをコピー
6. `app/config.js` を開いて2つを貼り付け、保存してGitHubに反映（数分で公開に反映されます）

```js
window.APP_CONFIG = {
  supabaseUrl: "https://xxxxxxxx.supabase.co",
  supabaseAnonKey: "eyJhbGciOi..."
};
```

### 手順C：管理者用の裏方（Edge Function）を入れる

管理者がアプリの中でスタッフのアカウント作成・パスワード変更・削除をするための小さなプログラムです。

1. パソコンに Supabase CLI を入れる（https://supabase.com/docs/guides/cli ）
2. このフォルダで次を実行

```
supabase login
supabase link --project-ref <プロジェクトの参照ID>   # Project Settings → General にあります
supabase functions deploy admin-users
```

入れなくてもアプリは動きます。その場合、スタッフの追加は Supabase の **Authentication → Users → Invite user** で招待し、パスワードは「本人に再設定メールを送る」を使ってください。

### 手順D：最初のログイン

1. 最初の管理者は **あおきコンサルティング株式会社（aoki.consulting.co@gmail.com）** としてあらかじめ登録してあります
2. アプリのログイン画面で **「新規アカウント作成」** → 氏名・このメールアドレス・パスワード **123456** を入れると、管理者としてログインできます
3. 「管理者ログイン」は管理者の確認つきの入口です。作成者のアカウントでは入れません
4. 管理者の追加・削除・権限の変更は「設定 → スタッフと権限」で行います（管理者が0人になる操作はできません）。未登録のメールで「新規アカウント作成」した人は「作成者」になります
5. 以後のスタッフは、管理者が「設定 → スタッフと権限 → ＋登録」で名前・メール・権限・初期パスワード（6文字以上）を登録すればすぐログインできます（手順Cを入れている場合）
   - お試し用の顧客3件・見積3件が最初から入っています（`config.js` の `demoData`）。本運用に入るときは「設定 → 会社情報・書類の設定 → サンプルデータを削除」で消せます

### 手順E：スマホのホーム画面に追加

- iPhone：Safari でアプリを開く → 共有ボタン → 「ホーム画面に追加」
- Android：Chrome で開く → メニュー → 「ホーム画面に追加」（またはインストール）

---

## 3. 運用でよくあること

| やりたいこと | 場所 |
|---|---|
| 単価をまとめて直す | 設定 → 商品・工事マスター → Excelで書き出す → 直して → Excelから取り込む |
| ロゴ・角印を変える | 設定 → 会社情報・書類の設定 → 画像を選ぶ |
| 振込先・支払期限を変える | 設定 → 会社情報・書類の設定 |
| 自分のパスワードや氏名を変える | 設定 → アカウント → パスワードを変更／氏名を変更 |
| パスワードを忘れた | ログイン画面の「パスワードをお忘れの方」（メールでリンクが届く）。管理者が「設定 → スタッフと権限」から直接変えることもできます |
| スタッフの追加・削除・パスワード変更 | 設定 → スタッフと権限（管理者のみ） |
| 退職した人 | 設定 → スタッフと権限 → その人 → 停止中（過去の書類に名前は残る） |

---

## 4. ファイルの説明

```
app/
  index.html      アプリ本体（見た目・動き・書類のレイアウトすべて）
  config.js       クラウド接続の設定（URLとキー）
  manifest.json   ホーム画面に追加したときの名前・アイコン
  sw.js           通信が弱いときも画面が開くようにする仕組み
  icons/          アプリアイコン
supabase/
  schema.sql              初期設定（1回実行）
  functions/admin-users/  管理者用の裏方（アカウント作成・パスワード変更・削除）
  reference_schema_v2.sql Ver.2で移行予定のテーブル設計（参考。まだ実行しない）
docs/
  仕様書.md               開発仕様書
  prototype/              Claude内で動く試作品（クラウド接続なし）
```

---

## 5. 仕組みの補足（開発者向け）

- フロントエンドは依存なしの単一HTML。`window.storage.get/set/delete(key, shared)` という保存口だけを抽象化しており、
  - `config.js` が空 → Claude Artifacts の `window.storage`（あれば）／なければ端末内
  - `config.js` あり → Supabase の `app_state` テーブル（JSONを1行で保持）
- 共有データは `key = plus_estimate_shared_v2`、個人の下書きは `u:<uid>:...`。RLS で本人以外は下書きを読めません。
- 同期は「保存→600ms後にpush」「15秒ごと／画面復帰時／Realtime通知でpull」。`updatedAt` が新しい側を採用（行単位のマージは Ver.2 で `reference_schema_v2.sql` に移行して対応）。
- 認証は Supabase Auth（メール＋パスワード、6文字以上）。役割（管理者／作成者）は `app_state` 内の `staff` で管理し、管理者が画面から変更します。初期管理者は aoki.consulting.co@gmail.com。
- `config.js` が空の試作品モードでは、パスワードは SHA-256 のハッシュで `staff.pwHash` に保持します（平文は保存しません）。
- 管理者によるアカウント作成・パスワード変更・削除は Edge Function `admin-users`（service role で実行、呼び出し元が管理者かを `app_state.staff` で検証）。未デプロイ時はアプリが招待手順を案内します。
- Excel入出力は SheetJS（CDN）を必要時に読み込み。読めない環境ではCSVに自動フォールバック。

## 6. これから（Ver.2〜）

- 本物のPDF生成とメール添付・LINE送信
- 現場写真の添付、案件管理、入金・売上集計、納品書・領収書
- 行単位のデータ管理（同時編集の上書き防止）、見積番号のサーバー採番
- LINE連携、カレンダー連携、経営ダッシュボード
