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
  App/          エントリ + DI コンテナ（AppContainer）+ 環境設定（AppConfig）
  Infrastructure/ Demo リポジトリ + 画像 URL 解決（§6.2）
  Presentation/ Theme（配色 §6.1 / フォーマット §3.5）+ Collection / Market の View・ViewModel
SecondaryComics.xcodeproj/    Core をローカルパッケージとして参照
```

アーキテクチャ: Domain ← Application ← Presentation / Infrastructure（クリーンアーキテクチャ, §8）。
Repository は protocol で抽象化し、`Demo`（モック）↔ `Impl`（実 API）を DI で差し替える。
現状は **Demo モード**（実 API 不要で全画面が動作）。

## ビルド / テスト

```bash
# ドメイン層のテスト（シミュレータ不要・高速）
cd Core && swift test

# アプリのビルド
xcodebuild -project SecondaryComics.xcodeproj -scheme SecondaryComics \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build
```

Xcode で `SecondaryComics.xcodeproj` を開けばそのまま実行可能。

## 実装状況

- [x] **Phase 0** 足場（Xcode プロジェクト + DI + ダークテーマ）
- [x] **Phase 1** Domain 層（§3 の計算式 + テスト）
- [x] Presentation 基盤（配色トークン / フォーマッタ）
- [x] Demo リポジトリ + UI（コレクション/マーケット 一覧・詳細・検索/フィルタ/ソート・12ヶ月チャート）
- [ ] **Phase 4** 実 API 接続（要 `openapi.yaml` / dev 環境値 / 認証ライブラリ決定）

### Phase 4 に必要（未提供）
1. `openapi.yaml` — API 契約（DTO 生成元・最優先）
2. dev 環境の実値（§4: Cognito / API Gateway / CloudFront）
3. 認証ライブラリの決定（Amplify Swift 推奨）
