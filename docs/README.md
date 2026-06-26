# アーキテクチャ（フォルダ構成と役割）

secondary-comics-ios（SwiftUI / iOS 17+）の構造を 1 枚にまとめたもの。仕様の正は [../ios-handoff.md](../ios-handoff.md)。

## 全体像

**2 モジュール構成**。純 Swift の `Core`（ビジネスの正）と、SwiftUI アプリ `SecondaryComics`（見せ方）。
依存は常に内側（Core / Domain）向き。

```
secondary-comics-ios/
├─ Core/                  純 Swift パッケージ（SwiftUI 非依存・テスト対象）
│   └─ Sources/SecondaryComicsCore/
│       ├─ Domain/        モデル + 計算式（アプリの「正」）
│       └─ Application/   ユースケース + Repository protocol + 検索/フィルタ/ソート
│
└─ SecondaryComics/       iOS アプリ（SwiftUI）
    ├─ App/               起動・DI（Demo↔API を決める合成ルート）・環境設定（dev/prod）
    ├─ Infrastructure/    データ取得の実装（Demo / 実API）・認証（Cognito）・通信・画像URL解決
    └─ Presentation/      画面（View）と ViewModel・配色/整形・ログイン
```

## 各フォルダの役割

### Core（ビジネスロジック・SwiftUI 非依存）

| フォルダ | 担っている内容 |
|---|---|
| `Core/.../Domain/Model/` | データの型（CollectionItem / MarketRecord / Condition など）。§3.1–3.3 |
| `Core/.../Domain/Calculation/` | **計算式の正**。含み損益・評価額・サマリー・変化率。§3.4 |
| `Core/.../Application/Port/` | `CollectionRepository` / `MarketRepository` protocol（**Demo↔API 差し替えの接合点**）。§8 |
| `Core/.../Application/UseCase/` | データ取得を依頼する薄い指揮役（`ListCollection` など）。§8 |
| `Core/.../Application/Query/` | 検索・フィルタ・ソート（すべてクライアント側）。§7.3 |
| `Core/Tests/` | 計算式・クエリの単体テスト（`swift test` で実行・シミュレータ不要） |

### SecondaryComics（見せ方・SwiftUI）

| フォルダ | 担っている内容 |
|---|---|
| `App/` | アプリ起動（`@main`）と **DI コンテナ `AppContainer`** + 環境設定 `AppConfig`。`config.useAPI` で Demo / 実API を配線。`AppConfig.current` が dev/prod を切替（§4） |
| `Infrastructure/Repository/` | Repository protocol の実装。Demo（`*RepositoryDemo`）と 実API（`*RepositoryAPI`：`GET /collection` `/market`）の両方 |
| `Infrastructure/Network/` | `APIClient`（Bearer 付与・401 判定・JSON デコード）+ `APIError`。§4 |
| `Infrastructure/Auth/` | Cognito 認証。`AuthService` / `TokenProvider`（Amplify 実装 + Demo 用 Stub）・Amplify 構成。§4 |
| `Infrastructure/Image/` | 画像 URL の解決（S3キー → CloudFront URL）。§6.2 |
| `Presentation/Theme/` | 配色トークン（§6.1）と表示フォーマット・色クラス（§3.5） |
| `Presentation/Common/` | 再利用 View（画像・状態バッジ・空/エラー表示・ロード状態） |
| `Presentation/Auth/` | ログイン画面と `AuthViewModel`（セッション状態・サインイン/アウト）。§4, §7 |
| `Presentation/Collection/` | マイコレクション画面（一覧・詳細）と ViewModel。§7.1 |
| `Presentation/Market/` | マーケット画面（一覧・詳細・12ヶ月チャート）と ViewModel。§7.2 |
| `Presentation/Root/` | `TabView`（コレクション / マーケット）+ 401 で再ログイン導線。§7 |

## 押さえる 3 点

1. **ドメインの正は Core、見せ方の判断は SecondaryComics**。計算・絞り込みのルールは Core にあり、アプリ側に重複しない。
2. **差し替えの接合点は Repository protocol（`Application/Port`）だけ**。View も ViewModel も protocol しか見ないので、実装を変えても上流は無改修。
3. **Demo か実 API かを決めるのは `App/AppContainer`**。`config.useAPI = false` で Demo モード（実 API・認証なしに全画面が動く）に戻せる。

## 実 API 接続（実装済み）

`Infrastructure/Network`・`Infrastructure/Auth`・`Infrastructure/Repository/*RepositoryAPI` で実 API + Cognito 認証を実装済み。
`App/AppContainer` が `AppConfig.useAPI` を見て Demo / 実 API を組み立てる。**Core（Domain / Application）と Presentation の主要部は無改修**で済むのがこの構造の狙い。

### dev / prod 環境の切り替え

- ビルド構成（`Debug/Release × Dev/Prod`）+ スキーム **Comics Dev / Comics Prod** で分離。
- コンパイルフラグ `DEV` / `PROD` に応じて `AppConfig.current` が `dev` / `prod` を返す。
- Amplify は `AppConfig` の値からプログラム的に構成（環境別 JSON は不要）。
- バンドル ID も環境別（dev: `...secondary-comics.dev` / prod: `...secondary-comics`）で TestFlight 配布を両立。
