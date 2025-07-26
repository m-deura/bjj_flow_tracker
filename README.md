## サービス概要

Flowque（Flow + Technique）は、ブラジリアン柔術の練習メモを”試合およびスパーリングの流れ”に沿ったフロー図として記録・可視化できるサービスです。

ブラジリアン柔術のようなポジション遷移や状況判断が鍵となる競技において、個々のテクニックを「記憶した技」ではなく「試合の中で使える技」として身につける手助けをします。

個々のテクニックをフロー図に沿って状況ごとに整理することで、「いつ・どこで・どのようにそのテクニックを使うのか」が頭の中で整理され、スパーリングの「このポジションからの脱出、先週習ったのに思い出せない…」といった歯痒さをグッと減らすことができます。

## サービスを作りたい理由

前提として、ブラジリアン柔術のテクニックは、特定のポジションや状況でしか使用することができません。そのため実際の試合では、自身と相手の双方がスタンディングからスタートした後、「その技が使える状況」に自力で遷移する必要があります。

つまり、特定の技を「試合で使用できる技」にするにあたっては、単に技を覚えるだけでなく、試合開始からその技を使える状態までの流れ（フロー）も理解・整理する必要があると考えています。

その一方で、日々の練習記録はテクニックごとや日付ごとにまとめる人が多いように見受けられます（自分もその一人です！）。この練習記録の取り方では技同士の繋がりが見えづらく、試合やスパーリングに活用するには不十分であると感じていました。

この課題を解決するため、「技の記憶」と「状況遷移の整理」を結びつけて視覚的に整理できる本サービスの作成に思い至った次第です。

## ユーザー層について

- ブラジリアン柔術を上達させたいと思いながらも、練習記録のつけ方が分からず、日々の練習をただこなしてしまっている方
- 練習記録はつけているが、見返す機会がなく記録を活かせていない方
- 習ったテクニックがなかなか頭に残らないと感じている方

## サービス利用のイメージ

- 練習中に学んだことは、忘れないうちにクイックメモで素早く記録！後からじっくりフロー図に整理・集約することで、効率的にテクニックに関する学びを蓄積できます。
- 本サービスで作成したフロー図は、試合の流れに沿って自分の知見を整理・集約した「自分専用の練習記録帳」として機能します。日々の練習やスパーリングの中で常にこのフローを思い浮かべながら動くことで、実戦での判断や振り返りにも役立ち、記録を見返す習慣が自然と生まれます。

## ユーザーの獲得について

- 同じ道場に所属している会員に対して周知
- Xを利用した拡散（場合によっては道場のSNSで周知してもらうなど？）

## サービスの差別化ポイント・推しポイント

- ブラジリアン柔術のテクニックに特化した入力フィールド（練度タグやアクションタイプタグ）
- 試合開始のポジション(TOP/BOTTOM)からだけでなく、サイドポジションやバックなど特定のポジションから始まる技のつながりを再利用可能な「部品」として定義し、フロー図化可能
- 練習中、咄嗟に記録したいときに役立つクイックメモページ
- 気軽に練習記録が見返せるスマホ操作を意識したUI

## 機能候補

### 【 MVPリリースまで 】

- ユーザー登録機能
- ログイン機能
- メインフロー表示機能  ※メインフロー：試合開始のポジション(TOP/BOTTOM)をルートノードとするフロー。
- フローパーツ表示機能 ※フローパーツ：特定の状況から展開される一連のテクニックを独立させたフロー。メインフロー上で再利用できる。
- テクニックノート編集機能
- メインフロー編集機能
- フローパーツ作成機能
- フローパーツ編集機能
- フローパーツ削除機能
- クイックメモ編集機能
- クイックメモ一括取り込み機能
- お気に入り登録機能
- お気に入り一覧機能
- お気に入り解除機能

### 【本リリースまで】

- お問い合わせページ作成
- テクニックノート共有機能
- ゲストログイン機能
- テクニックノート検索機能（マルチ検索・オートコンプリート）
- テクニック名オートコンプリート機能
- 多言語(英語)対応
- PWA対応
- テクニックノート・フローパーツ共有機能（要検討）
- テクニックノートサンプル準備
- チャートサンプル準備

## 機能の実装方針
| 機能 / カテゴリ | 技術 |
| --- | --- |
| バックエンド | Ruby on Rails 7.2.2.1 / Ruby 3.3.8 |
| フロントエンド | JavaScript / Stimulus | 
| CSSフレームワーク | Tailwind CSS / daisyUI |
| 環境構築 | Docker |
| インフラ | Render / Cloudflare|
| データベース | PostgreSQL |
| 検索機能 | Stimulus Autocomplete |
| チャート可視化 | cytoscape.js |
| ノードレイアウト | dagre.js |
| ノードのツリー構造管理 | Ancestry |
| 認証機能 | Devise / OmniAuth-Google-OAuth2 |

## 画面遷移図
[Figma - Flowque画面遷移図](https://www.figma.com/design/50XTJ2AdMyuF8x4kjTbcvT/Flowque)

## ER図
```mermaid
erDiagram
  users {
    int id PK "ID (NOT NULL)"
    string provider "OAuthプロバイダー名 (NOT NULL)"
    string uid "OAuthプロバイダー上のuid (NOT NULL)"
    string name "ユーザー名 (NOT NULL)"
    string email "メールアドレス(NOT NULL)"
    string encrypted_password "暗号化済みパスワード (NOT NULL)"
    datetime remember_created_at "作成日時"
    string image "ユーザーアイコン"
    text quick_memo "Quick Memo"
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }

  techniques {
    int id PK "(NOT NULL)"
    int template_technique_id FK "テンプレートID (NOT NULL)"
    int user_id FK "ユーザーID (NOT NULL)"
    string name "テクニック名 (NOT NULL)"
    text note "練習ノート"
    bool is_submission "極め技？ (NOT NULL)"
    int mastery_level "enumを使い、技の習熟度を5段階で表現 (NOT NULL)"
    bool is_bookmarked "ブックマーク対象？ (NOT NULL)"
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }

  transitions {
    int id PK "ID (NOT NULL)"
    int from_technique_id FK "展開元テクニックID (NOT NULL)"
    int to_technique_id FK "展開先テクニックID (NOT NULL)"
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }

  charts {
    int id PK "ID (NOT NULL)"
    int template_chart_id FK "テンプレートID"
    int user_id FK "ユーザーID (NOT NULL)"
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }

  nodes {
    int id PK "ID (NOT NULL)"
    int chart_id FK "チャートID (NOT NULL)"
    int technique_id FK "テクニックID (NOT NULL)"
    string ancestry "ツリー構造上で本ノードに至るまでのパス"
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }


  template_techniques {
    int id PK "ID (NOT NULL)"
    string name "テンプレート名 (NOT NULL)"
    text note "サンプル練習ノート"
    bool is_submission "極め技？ (NOT NULL)"
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }

  template_transitions {
    int id PK "ID (NOT NULL)"
    int from_technique_id FK "展開元テクニックID (NOT NULL)"
    int to_technique_id FK "展開先テクニックID (NOT NULL)"
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }

  template_charts {
    int id PK "ID (NOT NULL)"
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }

  template_nodes {
    int id PK "ID (NOT NULL)"
    int template_chart_id FK "テンプレートチャートID (NOT NULL)"
    int template_technique_id FK "テンプレートテクニックID (NOT NULL)"
    string ancestry "ツリー構造上で本ノードに至るまでのパス"
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }

  users ||--o{ techniques : "1:多"
  users ||--o{ charts : "1:多"

  techniques ||--o{ nodes : "1:多"
  techniques ||--o{ transitions : "1:多 (from + to)"

  charts ||--o{ nodes : "1:多"
  
  template_techniques ||--o{ techniques     : "1:多"
  template_techniques ||--o{ template_nodes : "1:多"
  template_techniques ||--o{ template_transitions : "1:多 (from + to)"

  template_charts ||--o{ charts : "1:多"
  template_charts ||--o{ template_nodes : "1:多"

```
