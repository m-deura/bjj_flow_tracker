## サービス概要

BJJ Flow Tracker は、ブラジリアン柔術の練習メモを”試合およびスパーリングの流れ”に沿ったフロー図として記録・可視化できるサービスです。

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
- SNSを利用した拡散

## サービスの差別化ポイント・推しポイント

| 観点 | 他サービスとの違い | 本サービスの強み
| --------- | --------- | --------- | 
| **インタラクティブな情報反映** | 定番の試合展開をまとめた情報提供型サービスはあるが、ユーザー自身の気づきを記録することはできない。 | 自分の練習ノートをフローチャート形式で整理・可視化できる。|
| **使用ハードル**  | 「BJJフローチャート作成サービス」自体は僅かながら存在するが、ユーザーがゼロからテクニック及び動きを登録する必要がある。 | あらかじめプリセットとなるテクニックが登録されており、ユーザーは既存のテクニックを組み合わせるだけで自分の試合展開を構築できる。 |

## 機能

- ログイン機能
- テクニック一覧機能
- テクニック作成機能
- テクニック編集機能
- テクニック削除機能
- チャート一覧機能
- チャート作成機能
- チャート編集機能
- チャート削除機能
- ゲストログイン機能
- テクニックノート検索機能（インスタンス検索）
- 多言語(英語)対応
- PWA 対応
- テクニック・チャート共有機能（要検討）
- テクニックサンプル準備
- チャートサンプル準備

## 機能の実装方針

| 機能 / カテゴリー      | 技術                               |
| ---------------------- | ---------------------------------- |
| バックエンド           | Ruby on Rails 7.2.2.1 / Ruby 3.3.8 |
| フロントエンド         | JavaScript / Hotwire               |
| CSS フレームワーク     | Tailwind CSS / daisyUI             |
| 環境構築               | Docker                             |
| インフラ               | Render / Cloudflare                |
| データベース           | PostgreSQL                         |
| セレクトボックスUI     | tom-select                         |
| ステップガイド         | intro.js                           |
| チャート可視化         | G6                                 |
| ノードのツリー構造管理 | typed_dag                          |
| 認証機能               | Devise / OmniAuth-Google-OAuth2    |

## 画面遷移図

[Figma - 画面遷移図](https://www.figma.com/design/50XTJ2AdMyuF8x4kjTbcvT/BJJ-Flow-Tracker)

## ER 図
```mermaid
erDiagram
  users {
    int id PK "ID (NOT NULL)"
    string provider "OAuthプロバイダー名 (NOT NULL)"
    string uid "OAuthプロバイダー上のuid (NOT NULL)"
    string name "ユーザー名 (NOT NULL)"
    string email "メールアドレス (NOT NULL)"
    string encrypted_password "暗号化済みパスワード (NOT NULL)"
    datetime remember_created_at "“ログイン状態を保持”が有効になった日時"
    string image "ユーザーアイコン"
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }

  techniques {
    int id PK "(NOT NULL)"
    int user_id FK "ユーザーID (NOT NULL)"
    int technique_preset_id FK "プリセットID (NULLならユーザー定義)"
    string name_ja "テクニック名(日本語) (NOT NULL)"
    string name_en "テクニック名(英語) (NOT NULL)"
    int category "enumを使い、テクニックのカテゴリーを表現"
    text note "練習ノート"
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }

  technique_presets {
    int id PK "(NOT NULL)"
    string name_ja "テクニック名(日本語) (NOT NULL)"
    string name_en "テクニック名(英語) (NOT NULL)"
    int category "enumを使い、テクニックのカテゴリーを表現"
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }

  charts {
    int id PK "ID (NOT NULL)"
    int user_id FK "ユーザーID"
    string name "チャート名 (NOT NULL)"
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }

  chart_presets {
    int id PK "ID (NOT NULL)"
    string name "チャート名 (NOT NULL)"
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }

  nodes {
    int id PK "ID (NOT NULL)"
    int chart_id FK "チャートID"
    int technique_id FK "テクニックID"
    string ancestry "ツリー構造上で本ノードに至るまでのパス"
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }

  node_presets {
    int id PK "ID (NOT NULL)"
    int chart_preset_id FK "チャートID"
    int technique_preset_id FK "テクニックID"
    string ancestry "ツリー構造上で本ノードに至るまでのパス"
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }

  edges {
    int id PK "ID (NOT NULL)"
    int from_id FK "出発ノードID（NOT NULL）"
    int to_id FK "到達ノードID (NOT NULL)"
    int flow "fromからtoまでのホップ数 (typed_dag用のカラム)"
    int count "flowカラムのホップ数で到達できる推移辺の数 (typed_dag用のカラム)"
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }

  edge_presets {
    int id PK "ID (NOT NULL)"
    int from_id FK "出発ノードID（NOT NULL）"
    int to_id FK "到達ノードID (NOT NULL)"
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }

  users ||--o{ techniques : "1:多"
  users ||--o{ charts : "1:多"

  techniques ||--o{ nodes : "1:多"

  technique_presets ||--o{ techniques : "1:多"
  technique_presets ||--o{ node_presets : "1:多"

  charts ||--o{ nodes : "1:多"

  chart_presets ||--o{ charts : "1:多"
  chart_presets ||--o{ node_presets : "1:多"

  nodes ||--o{ edges : "1:多(from)"
  nodes ||--o{ edges : "1:多(to)"

  node_presets ||--o{ edge_presets : "1:多(from)"
  node_presets ||--o{ edge_presets : "1:多(to)"
```
