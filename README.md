## ■ サービス概要
##### サービス名：BJJ Flow Tracker
##### サービスURL：https://bjjflowtracker.com/
<img src="app/assets/images/ogp.png" width="600" alt="ogp.png">

BJJ Flow Tracker は、ブラジリアン柔術の練習メモを”試合およびスパーリングの流れ”に沿ったフロー図として記録・可視化できるサービスです。

ブラジリアン柔術のようなポジション遷移や状況判断が鍵となる競技において、個々のテクニックを「記憶した技」ではなく「試合の中で使える技」として身につける手助けをします。

個々のテクニックをフロー図に沿って状況ごとに整理することで、「いつ・どこで・どのようにそのテクニックを使うのか」が頭の中で整理され、スパーリングの「このポジションからの脱出、先週習ったのに思い出せない…」といった歯痒さをグッと減らすことができます。

## ■ 開発背景

前提として、ブラジリアン柔術のテクニックは、特定のポジションや状況でしか使用することができません。そのため実際の試合では、自身と相手の双方がスタンディングからスタートした後、「その技が使える状況」に自力で遷移する必要があります。

つまり、特定の技を「試合で使用できる技」にするにあたっては、単に技を覚えるだけでなく、試合開始からその技を使える状態までの流れ（フロー）も理解・整理する必要があると考えています。

しかしながら、試合の流れに着目して練習記録がとれるサービスは現状ほとんど存在していません。結果として、自分を含め多くの人がテクニック単位または日付単位で練習内容を整理しています。
この記録方法では技同士の繋がりが見えづらく、試合やスパーリングに活用にするは不十分であると感じていました。

この課題を解決するため、「技の記憶」と「状況遷移の整理」を結びつけて視覚的に整理できる本サービスの開発に思い至った次第です。

## ■ メインの対象ユーザー

- ブラジリアン柔術を上達させたいと思いながらも、練習記録のつけ方が分からず、日々の練習をただこなしてしまっている方
- 練習記録はつけているが、見返す機会がなく記録を活かせていない方
- 習ったテクニックがなかなか頭に残らないと感じている方

## ■ サービス利用のイメージ
1. Technique メニューで技を登録・整理

    技ごとに、動きのコツや気づきを記録することができます。プリセットとして90個以上のテクニックが初期登録されていますが、足りない場合は新規登録を行ってください。
2. Flow Chart メニューで技を繋ぎ、試合の展開(得意パターン)を可視化

    Technique メニューで登録した技同士を繋げて、試合の展開を可視化することができます。「この技の次にどの技が使えるか」を整理することで、復習・戦略立案に役立てることができます。

本サービスで作成したフロー図は、試合の流れに沿って自分の知見を整理・集約した「自分専用の練習記録帳」として機能します。日々の練習やスパーリングの中で常にこのフローを思い浮かべながら動くことで、実戦での判断や振り返りにも役立ち、記録を見返す習慣が自然と生まれます。

## ■ サービスの差別化ポイント・推しポイント

| 観点 | 他サービスとの違い | 本サービスの強み
| --------- | --------- | --------- | 
| **インタラクティブな情報反映** | 定番の試合展開をまとめた情報提供型サービスはあるが、ユーザー自身の気づきを記録することはできない。 | 自分の練習ノートをフローチャート形式で整理・可視化できる。|
| **使用ハードル**  | 「BJJフローチャート作成サービス」自体は僅かながら存在するが、ユーザーがゼロからテクニック及び動きを登録する必要がある。 | あらかじめプリセットとなるテクニックが登録されており、ユーザーは既存のテクニックを組み合わせるだけで自分の試合展開を構築できる。 |

## ■ 機能紹介

| ログイン |
| --- |
| <p align="center">[![Image from Gyazo](https://i.gyazo.com/6f6c9eb7c923a46a83a8acc2c58e7ac3.png)](https://gyazo.com/6f6c9eb7c923a46a83a8acc2c58e7ac3) </p> |
| Googleアカウントを使って簡単にログインすることができます。ひとまずサービスを体験したい場合は、Googleアカウントを使わずゲストとしてログインすることも可能です。 |

| ステップガイド |
| --- |
| <p align="center" width="600"><img src="https://github.com/user-attachments/assets/d0b2c47c-fd90-45fe-8d91-3a7153955c5a" width="600" alt="Step-by-Step Guide GIF"></p> |
| 各ページにあるステップガイド開始ボタン、もしくはタイトル右隣にある <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="1.5em" height="1.5em" fill="none" stroke="currentColor" stroke-width="1.5"><path stroke-linecap="round" stroke-linejoin="round" d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 5.25h.008v.008H12v-.008Z"/></svg> をクリックすると、そのページの概要と使い方を案内するステップガイドが始まります。これによって、初めての方でも迷わず画面を操作できます。|

| テクニック管理 |
| --- |
| <p align="center" width="600"><img src="https://github.com/user-attachments/assets/c757a0ac-7912-4ae4-8d69-d4cc3ae540d4" width="600" alt="Technique GIF"></p> |
| それぞれの技に対して、気づきや動きのコツを記録できます。登録したテクニックは一覧から検索やカテゴリ別の絞り込みが可能。自分だけの「BJJノート」として知識を整理できます。 |

| チャート管理 |
| --- |
| <p align="center" width="600"><img src="https://github.com/user-attachments/assets/5def5cc1-7e12-48dc-b3ae-d38baa32da53" width="600" alt="Chart GIF"></p><p align="center"><a href="https://gyazo.com/345bbc5eea2d8309cabfe3116fc7c15f"><img src="https://i.gyazo.com/345bbc5eea2d8309cabfe3116fc7c15f.png" alt="Image from Gyazo" width="600"/></a></p> |
| 登録した技を繋げて、試合やスパーの展開を可視化することができます。さらに、各テクニック間の遷移条件（どんな状況からその技に移ることができるのか）を記録することで、戦略的な分析にも役立てることもできます。 |

| 言語(日英)切り替え |
| --- |
| <p align="center" width="600"><img src="https://github.com/user-attachments/assets/86d71a9a-6dde-4a9b-9230-042969d711c0" width="600" alt="Language Switcher GIF"></p> |
| 表示される言語を、日本語もしく英語に切り替えることができます（一部の固定ページは日本語のみの表示となります）。|

## ■ 技術スタック

| 機能 / カテゴリー      | 技術                               |
| ---------------------- | ---------------------------------- |
| バックエンド           | Ruby on Rails 7.2.2.1 / Ruby 3.3.8 |
| フロントエンド         | JavaScript / Hotwire               |
| CSS フレームワーク     | Tailwind CSS / daisyUI             |
| 環境構築               | Docker                             |
| インフラ               | Render / Cloudflare                |
| データベース           | PostgreSQL                         |
| セレクトボックスUI     | tom-select                         |
| ステップガイド         | Driver.js                          |
| チャート可視化         | G6                                 |
| ノードのツリー構造管理 | typed_dag                          |
| 認証機能               | Devise / OmniAuth-Google-OAuth2    |

## ■ 画面遷移図

[Figma - 画面遷移図](https://www.figma.com/design/50XTJ2AdMyuF8x4kjTbcvT/BJJ-Flow-Tracker)

## ■ ER 図
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

  transitions {
    int id PK "ID (NOT NULL)"
    int from_id FK "出発ノードID（NOT NULL）"
    int to_id FK "到達ノードID (NOT NULL)"
    string trigger "遷移条件"
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
    datetime created_at "作成日時 (NOT NULL)"
    datetime updated_at "更新日時 (NOT NULL)"
  }

  node_presets {
    int id PK "ID (NOT NULL)"
    int chart_preset_id FK "チャートID"
    int technique_preset_id FK "テクニックID"
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
  techniques ||--o{ transitions : "1:多(from)"
  techniques ||--o{ transitions : "1:多(to)"

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
