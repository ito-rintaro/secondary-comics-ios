# iOS ネイティブ版（SwiftUI）ハンドオフ仕様書

> 既存の Web 版（React + TypeScript / クリーンアーキテクチャ）を **iOS ネイティブ（Swift / SwiftUI）** で
> 作り直すために、Claude Code へ渡す情報を 1 枚にまとめたもの。
> **バックエンド（API・認証・画像配信）は Web 版と完全共通**で、iOS 版は同じ API を叩く新規クライアントになる。
> Web 版のコードは再利用しない（再利用するのは **仕様・契約・計算式・配色** だけ）。
>
> 関連: [architecture.md](./architecture.md)（Web の層構成）/ [openapi.yaml](./openapi.yaml)（API 契約）/
> [docs_for_input/](../docs_for_input/)（プロダクト要件）

---

## 0. このドキュメントの使い方（Claude Code 向け）

1. まず [openapi.yaml](./openapi.yaml) を読み、API クライアント層（型 + fetch）を生成する。これが最も確実な出発点。
2. §3 のドメイン計算式を Swift の純粋関数 / `struct` として実装する（Web の Domain 層と 1:1）。
3. §6 の配色トークンを `Color` 定義に落とす。
4. §7 の画面仕様を SwiftUI のナビゲーション（`TabView` 中心）へ翻訳する。
5. §8 のアーキテクチャ方針（Repository 抽象で Demo↔API 差し替え）を踏襲する。

**スコープ注意（§5）**: バックエンドは現状 **GET のみ稼働**。コレクションの登録/編集/削除 API は未提供。
iOS 版 MVP は「閲覧 + 集計表示」に絞れる。書き込みは後続フェーズ。

---

## 1. プロダクト要約

プレミア漫画（初版・帯付き・特装・サイン本）の **コレクション管理 × 相場確認** を一体で提供するサービス。
コレクターが「自分の蔵書が今いくらの価値か」「どれが値上がりしているか」を把握できる状態を目指す。

- 2 つの軸: **マイコレクション**（自分の所有品・含み損益）と **マーケット**（相場・12ヶ月推移）。
- 詳細な背景は [docs_for_input/00_overview.md](../docs_for_input/00_overview.md)。

---

## 2. そのまま流用する共通バックエンド（改変不要）

| 要素 | 内容 | 取得元 |
|---|---|---|
| API | `GET /collection`（本人のコレクション） / `GET /market/summary`（全ユーザー共通の相場サマリ）・`GET /market`（成約ログ） | [openapi.yaml](./openapi.yaml) |
| 認証 | Amazon Cognito。`Authorization: Bearer <IDトークン>` を付与。サーバが JWT の `sub` で本人データに絞る | §4 |
| 画像 | API は S3 オブジェクトキー（ファイル名のみ）を返す。CloudFront ドメイン + `/images/` を前置して表示 | §6.2 |

> **重要**: `userId` はリクエストに含めない。サーバが ID トークンの `sub` から判定する。
> マーケットは本人データではなく **グローバル**なので `sub` 絞り込みはされない（全員同じ相場が見える）。

---

## 3. ドメインモデルと計算式（Swift 実装仕様）

Web の `src/domain/` の純 TypeScript を Swift へ 1:1 で移植する。**計算式はここが正**。

### 3.1 CollectionItem（コレクションの所有品）

| フィールド | 型 | 意味 |
|---|---|---|
| `id` | String | 識別子 |
| `title` | String | 作品名（必須） |
| `author` | String | 著者 |
| `publisher` | String | 出版社 / レーベル |
| `volume` | String | 巻数（"全6巻" 等の自由文字列） |
| `year` | String | 発行年（文字列） |
| `condition` | Condition | 状態ランク（§3.3） |
| `qty` | Int | 所有数（>= 1） |
| `cost` | Int | 取得価格（1 点・円） |
| `market` | Int | 現在相場（1 点・円） |
| `marketSource` | MarketSource | 相場の出所（§3.3） |
| `flags` | ConditionFlags | 初版/帯/特装（§3.3） |
| `purchaseDate` | String | 購入日 `YYYY-MM-DD`（未入力は空文字） |
| `store` | String | 購入店 |
| `location` | String | 保管場所 |
| `memo` | String | メモ |
| `imageUrl` | String | S3 オブジェクトキー（空可。§6.2 で解決） |
| `updatedAt` | Int64 | 最終更新（epoch ミリ秒） |

### 3.2 マーケット（成約ログ＋相場サマリの 2 層）

マーケットは「出品 1 件に月次 `history[12]` を持つ」旧 `MarketRecord` をやめ、**成約ログ（1 レコード = 1 価格）** と **相場サマリ（catalog 単位で集計・導出）** の 2 層に分かれる。相場一覧カード・価格チャートの供給源は `MarketSummary`。

#### MarketSale（成約ログ・`GET /market`）

| フィールド | 型 | 意味 |
|---|---|---|
| `id` | String | レコード識別子（mk-xxx） |
| `title` / `author` / `publisher` / `volume` | String | 作品情報（Catalog 由来） |
| `flags` | ConditionFlags | 初版/帯/特装（Catalog 由来） |
| `imageUrl` | String | S3 オブジェクトキー（Catalog 由来・空可） |
| `catalogId` | String | 参照する Catalog の id |
| `condition` | Condition | この成約個体の状態ランク |
| `price` | Int | 成約価格（円）＝単一 |
| `soldAt` | String | 成約日 `YYYY-MM-DD` |
| `seller` | String | 販売元 / ショップ名（空可） |

#### MarketSummary（相場サマリ・`GET /market/summary`）

catalog 単位に集計した読み取りモデル。成約が 1 件以上ある catalog のみ返る。`price` / `change` / `history` は旧 `MarketRecord` と名前も意味も据え置きで、既存のカード価格表示・折れ線チャートのロジックをそのまま流用できる。

| フィールド | 型 | 意味 |
|---|---|---|
| `catalogId` | String | 集計単位＝参照する Catalog の id（`Identifiable` の id） |
| `title` / `author` / `publisher` / `volume` | String | 作品情報（Catalog 由来） |
| `flags` | ConditionFlags | 初版/帯/特装（Catalog 由来） |
| `imageUrl` | String | S3 オブジェクトキー（Catalog 由来・空可） |
| `price` | Int | 現在価格（= `history` 末尾） |
| `change` | Double | 期間変化率 `(末尾 - 先頭) / 先頭`。0.18 → +18% |
| `history` | [Int] | 月次に畳んだ擬似系列（円）。要素数 12・末尾＝当月。成約の無い月は前方フィル、最初の成約より前はバックフィル |
| `sampleCount` | Int | 集計に使った成約点数（相場の信頼度の目安） |
| `lastSoldAt` | String | 直近成約日 `YYYY-MM-DD` |

> `seller` / 個別 `condition` / listing 単位の `id` / 旧 `listedAt` は catalog 単位の `MarketSummary` には無い。出品者などが要る場合は `GET /market`（成約ログ）から別途引く。ソートは `price` / `change` / `lastSoldAt` で行う。

### 3.3 値オブジェクト

```
Condition = S | A | B | C
  ラベル: S（新品・美品） / A（良い） / B（並） / C（傷み・難あり）

MarketSource = manual | auto | estimate
  manual=手入力 / auto=自動取得 / estimate=推定（現状は manual 固定）

ConditionFlags { firstEd: Bool（初版） , obi: Bool（帯付き） , special: Bool（特装/サイン） }
```

### 3.4 計算式（ここが Domain の核心 — そのまま移植）

```
// コレクション 1 件
含み損益  profitLoss(it)      = (it.market - it.cost) * it.qty
評価額    evaluation(it)      = it.market * it.qty
取得額    acquisitionCost(it) = it.cost * it.qty

// コレクション全体サマリー summarize(items)
count      = Σ it.qty                  // 登録点数（所有数合計）
totalCost  = Σ acquisitionCost(it)     // 総取得額
totalValue = Σ evaluation(it)          // 現在評価額
pl         = totalValue - totalCost    // 含み損益

// マーケット全体ヘッダ概況 summarizeMarket(summaries) -> MarketOverview
count    = summaries.count          // 相場のある銘柄数
topPrice = max(price)
avgPrice = mean(price)
avgChange= mean(change)

// 成約ログ → 相場サマリの畳み込み deriveMarketSummaries(sales)（サーバ集計のクライアント再現）
//   catalog 単位にグルーピング → 月次12バケットへ集約（当月平均）
//   空月は前方フィル、最初の成約より前はバックフィル → history[12] / price / change を導出

// 価格推移の変化率（先頭が 0/空なら 0）
changeRate(history) = history.isEmpty || history[0] == 0
                      ? 0
                      : (history.last - history.first) / history.first
```

### 3.5 表示フォーマット（Presentation の関心事 — 計算とは分離）

```
formatYen(n)        = "¥" + round(n).grouped(locale: ja_JP)   // 例: ¥35,000
formatSignedYen(n)  = (n > 0 ? "+" : "") + formatYen(n)        // 含み損益用
formatPercent(rate) = (rate >= 0 ? "+" : "") + (rate*100).fixed(1) + "%"  // 例: +18.0%

色クラス（§6.1 の色に対応）:
  損益:   n > 0 → plus(緑) / n < 0 → minus(赤) / 0 → 標準
  変化率: rate >= 0 → plus(緑) / それ未満 → minus(赤)   // 0 は plus 扱い
```

---

## 4. 認証（Amazon Cognito）

Web は Amplify(JS) を使用。iOS は **Amplify Swift** または **AWS SDK for Swift** で同じユーザープールに接続する。

必要な設定値（Web の `.env.example` / `.env.dev` と同じ。実値は terraform output から取得）:

```
VITE_COGNITO_USER_POOL_ID   ← User Pool ID（例: ap-northeast-1_xxxxxxxxx）
VITE_COGNITO_CLIENT_ID      ← App Client ID
VITE_AWS_REGION             ← ap-northeast-1
VITE_API_BASE_URL           ← API Gateway のベース URL
VITE_IMAGE_BASE_URL         ← CloudFront ドメイン（画像配信元、末尾スラッシュ無し）
```

> ⚠️ これらは公開値だが **環境（dev/prod）ごとに異なる**。実値はこのリポジトリにはコミットされていない。
> 利用者に dev 環境の値を確認するか、terraform output / GitHub Environments の Variables から取得すること。

API リクエスト時の挙動（Web の `infrastructure/http/apiClient.ts` 相当を Swift で実装）:
- ログイン中ユーザーの **ID トークン**を `Authorization: Bearer <token>` で付与。
- トークンの取得・自動更新は Amplify に任せる。
- `401` は未認証 → 再ログイン導線へ。

---

## 5. スコープ（iOS MVP）

| 機能 | API | iOS MVP |
|---|---|---|
| コレクション一覧取得 | `GET /collection` ✅稼働 | **含む** |
| マーケット相場取得 | `GET /market/summary` ✅稼働 | **含む** |
| サマリー / 検索 / フィルタ / ソート / 集計 | クライアント側で算出 | **含む**（§3, §7） |
| コレクション 登録/編集/削除 | ❌未提供 | **含まない**（API 提供後） |
| 画像アップロード | ❌未提供 | **含まない** |
| 価格アラート / ウォッチリスト | ❌ | **含まない**（将来フェーズ） |

> 検索・フィルタ・ソート・集計は **すべてクライアント側**。サーバは生の配列を返すだけ（クエリパラメータ無し）。
> フィルタ/ソートの種別は §7.3 を参照。

---

## 6. デザイン仕様

### 6.1 配色トークン（ダークテーマ・実 HEX 値）

Web の `src/index.css` の CSS 変数。SwiftUI の `Color` 定義へそのまま移植する。

| トークン | HEX | 用途 |
|---|---|---|
| `bg` | `#0F1115` | 画面背景 |
| `panel` | `#181B22` | カード / パネル背景 |
| `panel2` | `#1F232C` | パネル内のひと段濃い面 |
| `line` | `#2A2F3A` | 罫線 / 境界 |
| `text` | `#E7E9EE` | 本文テキスト |
| `muted` | `#9AA3B2` | 補助テキスト |
| `accent` | `#E0245E` | ブランドカラー（ピンク。アクセントは 1 色に絞る） |
| `accent2` | `#3A8BFF` | サブアクセント（青） |
| `plus` | `#34C759` | **含み益・上昇**（緑） |
| `minus` | `#FF453A` | **含み損・下落**（赤） |

- 角丸: `radius = 12pt`。
- **色の意味は固定**: 緑=益、赤=損。装飾目的で色を増やさない（[ui-reference-research.md](./ui-reference-research.md)）。
- ダーク基調なので `colorScheme: .dark` 前提でよい。

### 6.2 画像 URL の解決ルール

Web の `src/presentation/imageSrc.ts` のロジックを Swift で再現する:

```
resolveImageSrc(imageUrl):
  value = imageUrl.trimmed()
  if value == ""                          → 画像なし。プレースホルダを表示
  if value が http(s): or data: で始まる  → そのまま使う（既存データ互換）
  それ以外（S3 キー）                      → "{VITE_IMAGE_BASE_URL}/images/{value}"
                                            （value 先頭の / は除去）
```

### 6.3 UI 要件（[06_screens.md](../docs_for_input/06_screens.md) より）

- **状態バッジ**: 初版（hot バッジ）・帯・特装/サインをカード上に表示。
- **空状態**: 未登録時のガイド表示。
- **相場の鮮度**: `marketSource`（手入力/自動/推定）を明示（誤った資産額をサイレントに見せない）。
- iOS は標準で SF フォント。Web は `-apple-system` 指定なので見た目は近い。

### 6.4 UX 方向性（任意・[ui-reference-research.md](./ui-reference-research.md) より）

証券アプリ（Robinhood / カビュウ等）の「資産を見せる」パターンが参考になる:
- **ヒーロー型サマリー**: 総評価額を特大表示 + 含み損益 + 変化率（色付き）。
- 一覧行に「名称・評価額・損益（色）・ミニ推移」。タップで詳細。
- 期間切替セグメント（1M/3M/6M/1Y）。

---

## 7. 画面仕様（SwiftUI への翻訳）

Web は「ヘッダのタブで 2 画面切替 + モーダル」構成（[06_screens.md](../docs_for_input/06_screens.md)）。
iOS では **`TabView`（マイコレクション / マーケット）** + 詳細は push 遷移 or `.sheet` が自然。

```
[未ログイン] → ログイン(Cognito) → TabView
                                     ├─ ① マイコレクション
                                     │     └─ 品詳細（.sheet or push）
                                     └─ ③ マーケット
                                           └─ ④ 相場詳細（.sheet or push, 12ヶ月チャート）
```

### 7.1 ① マイコレクション一覧
- 上部にサマリー: 登録点数 / 総取得額 / 現在評価額 / 含み損益（色付き）。→ §3.4 `summarize`。
- 作品カードのグリッド/リスト: 画像・タイトル・状態バッジ・評価額・含み損益（色）。
- 検索バー + フィルタ + ソート（§7.3）。
- 空状態のガイド。

### 7.2 ③ マーケット一覧
- 上部にサマリー: 銘柄数 / 最高額 / 平均価格 / 平均値上がり率。→ §3.4 `summarizeMarket`。
- 相場カード: 画像・タイトル・書誌メタ（著者/巻数/出版社）・現在価格・変化率（色）・**12ヶ月スパークライン**。seller / 個別 condition は catalog 単位のサマリには無いため表示しない。
- 検索 + ソート（§7.3）。
- カードタップで ④ 相場詳細（大きな 12ヶ月チャート、最安/最高/変動）。

> スパークライン: Web は SVG 自前描画。iOS は **Swift Charts**（`LineMark`）で `history`（12要素）を描く。

### 7.3 検索・フィルタ・ソート種別（クライアント側で適用）

```
コレクション:
  filter: ''(すべて) | firstEd(初版) | obi(帯) | special(特装) | profit(含み益) | loss(含み損)
  sort:   updated(更新新しい順, 既定) | marketDesc(相場高い順) | plDesc(損益大きい順) | titleAsc(タイトル順)
  search: title/author/publisher などへの部分一致

マーケット（相場サマリ MarketSummary を対象）:
  sort:   priceDesc(価格高い順, 既定) | trendDesc(値上がり率高い順) | recentDesc(直近成約順 = lastSoldAt 降順)
  search: title/author/publisher への部分一致（seller は持たない）
```

---

## 8. 推奨アーキテクチャ（SwiftUI）

Web のクリーンアーキテクチャ（[architecture.md](./architecture.md)）を踏襲すると、後で書き込み API が来ても差し替えが楽。

```
Domain          : CollectionItem / MarketSale / MarketSummary / Condition / ConditionFlags
                  + 純粋関数（profitLoss, evaluation, summarize, changeRate, deriveMarketSummaries …）  ← §3
Application      : ListCollection / ListMarketSummary ユースケース + Repository プロトコル（port）
Infrastructure   : CollectionRepositoryImpl（API） / ...Demo（モック）
                  + APIClient（Cognito トークン付与）+ 画像 URL 解決
Presentation     : SwiftUI View + ObservableObject（ViewModel）
```

- **Repository をプロトコルで抽象化**し、`Demo`（モックデータ）↔ `Impl`（実 API）を DI で差し替え。
  → API が落ちていてもプレビュー/開発できる（Web の `VITE_USE_API` 分岐と同じ思想）。
- Domain は UIKit/SwiftUI/URLSession に非依存の純 Swift にする（テスト容易性）。
- サーバ状態管理は素直に `async/await` + `ObservableObject` でよい。

---

## 9. 渡す資産チェックリスト

Claude Code に iOS 実装を依頼するとき、このドキュメントに加えて以下を渡す:

- [x] [openapi.yaml](./openapi.yaml) — API 契約（型・エラー・サンプル）。**最優先**
- [x] このドキュメント（`ios-handoff.md`）— ドメイン計算式・配色・画面・認証・スコープ
- [ ] **Cognito / API / CloudFront の実 dev 値**（§4。terraform output から。要確認）
- [ ] （任意）[docs_for_input/](../docs_for_input/) — 詳細な要件背景
- [ ] （任意）Web のスクリーンショット — 目指す見た目の参考

---

## 10. 着手前に決めること（オープン事項）

- [ ] **最低 iOS バージョン**（Swift Charts は iOS 16+、Observation は iOS 17+）。
- [ ] 認証ライブラリ: **Amplify Swift** か AWS SDK for Swift か。
- [ ] iOS MVP の範囲: 「閲覧のみ」で出すか、書き込み API 提供まで待つか。
- [ ] 詳細画面の出し方: push 遷移か `.sheet`（モーダル）か。
- [ ] 配布形態: TestFlight 内部配布から始めるか、App Store 公開前提か。
