# secondary-comics-ios

プレミア漫画の「コレクション管理 × 相場確認」アプリの iOS ネイティブ版（SwiftUI, iOS 17+）。
バックエンド（API・認証・画像）は Web 版と共通。仕様は [ios-handoff.md](./ios-handoff.md) を正とする。

アーキテクチャ資料は [docs/](./docs/README.md)（フォルダ構成と各フォルダの役割）。

## 構成

```
Core/                         ローカル Swift Package（純 Swift・SwiftUI 非依存）
  Sources/SecondaryComicsCore/
    Domain/      モデル + 計算式（§3）     ← profitLoss / evaluation / summarize / changeRate
    Application/ ports / use cases / query  ← Repository protocol, filter/sort/search（§7.3）
  Tests/                       計算式・クエリの単体テスト（17 件）
SecondaryComics/              iOS アプリ（Xcode の file-system-synchronized group）
  App/          エントリ + DI コンテナ（AppContainer）+ 環境設定（AppConfig: dev/prod）
  Infrastructure/ Demo / 実API リポジトリ + 通信（Network）+ 認証（Auth: Cognito）+ 画像 URL 解決（§6.2）
  Presentation/ Theme（配色 §6.1 / フォーマット §3.5）+ Auth（ログイン）+ Collection / Market の View・ViewModel
SecondaryComics.xcodeproj/    Core + Amplify Swift をパッケージとして参照
```

アーキテクチャ: Domain ← Application ← Presentation / Infrastructure（クリーンアーキテクチャ, §8）。
Repository は protocol で抽象化し、`Demo`（モック）↔ `API`（実 API）を DI で差し替える。
実 API + Cognito 認証を実装済み。`AppConfig.useAPI = false` で **Demo モード**（実 API・認証なしに全画面が動作）に戻せる。

## ビルド / テスト

```bash
# ドメイン層のテスト（シミュレータ不要・高速）
cd Core && swift test

# アプリのビルド（dev は Comics Dev / prod は Comics Prod スキーム）
xcodebuild -project SecondaryComics.xcodeproj -scheme "Comics Dev" \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build
```

Xcode で `SecondaryComics.xcodeproj` を開き、スキーム **Comics Dev**（dev）/ **Comics Prod**（prod）を選んで実行・Archive する。
TestFlight 配布は各スキームで Archive（Release 構成・環境別バンドル ID）。

## 実装状況

- [x] **Phase 0** 足場（Xcode プロジェクト + DI + ダークテーマ）
- [x] **Phase 1** Domain 層（§3 の計算式 + テスト）
- [x] Presentation 基盤（配色トークン / フォーマッタ）
- [x] Demo リポジトリ + UI（コレクション/マーケット 一覧・詳細・検索/フィルタ/ソート・12ヶ月チャート）
- [x] **Phase 4** 実 API 接続（`GET /collection` `/market/summary` + Cognito 認証 / Amplify Swift）
- [x] セッション永続化（再起動後の自動ログイン・オフライン起動でも状態維持）
- [x] dev / prod 環境分離（ビルド構成 + スキーム + 環境別バンドル ID）

### 残課題
1. `AppConfig.prod` の実値記入（現状 dev のみ。空だと prod ビルドで API/認証が無効）
2. dev 用バンドル ID（`...secondary-comics.dev`）の App ID 登録 + App Store Connect レコード作成
3. MFA / 新パスワード要求など Cognito の追加認証ステップ（MVP では非対応）
