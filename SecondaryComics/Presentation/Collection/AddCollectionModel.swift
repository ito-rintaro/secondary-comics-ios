import Foundation
import Observation
import SecondaryComicsCore

/// コレクション新規登録モーダルの ViewModel（iOS 17 の @Observable）。
///
/// フロー: `GET /catalogs` でカタログ読込 → 検索/単一選択 → 所有情報入力（condition 必須）→
/// `POST /collection`。201 で受け取った `CollectionItem` を `onCreated` で親へ渡す
/// （親は一覧を再取得してモーダルを閉じる）。
@MainActor
@Observable
final class AddCollectionModel {
    private let listCatalogs: ListCatalogs
    private let createCollection: CreateCollection

    // カタログ選択
    var catalogState: LoadState<[Catalog]> = .idle
    var catalogSearch: String = ""
    var selectedCatalogId: String?

    // 所有情報（UI 初期値: condition=A / qty=1 / cost=0 / 文字列は空）
    var condition: Condition = .a
    var qty: Int = 1
    var cost: Int = 0
    var purchaseDate: String = ""
    var store: String = ""
    var location: String = ""
    var memo: String = ""

    // 送信状態
    var isSubmitting: Bool = false
    var submitError: String?

    /// 401（未認証）検知時の再ログイン導線。RootView が注入する。
    var onUnauthorized: (() -> Void)?
    /// 登録成功時に親へ作成済みアイテムを通知する（一覧再取得 + モーダルを閉じる）。
    var onCreated: ((CollectionItem) -> Void)?

    init(listCatalogs: ListCatalogs, createCollection: CreateCollection) {
        self.listCatalogs = listCatalogs
        self.createCollection = createCollection
    }

    /// 検索を適用した表示用カタログ一覧。
    var visibleCatalogs: [Catalog] {
        guard case let .loaded(catalogs) = catalogState else { return [] }
        return applyCatalogQuery(catalogs, search: catalogSearch)
    }

    /// カタログ未選択 / 送信中は登録ボタンを非活性にする。
    var canSubmit: Bool {
        selectedCatalogId != nil && !isSubmitting
    }

    /// モーダルを開いた時点でカタログを読み込む。
    func loadCatalogs() async {
        catalogState = .loading
        do {
            catalogState = .loaded(try await listCatalogs())
        } catch {
            if let apiError = error as? APIError, apiError == .unauthorized {
                onUnauthorized?()
            }
            catalogState = .failed(error.localizedDescription)
        }
    }

    /// 入力を検証・正規化して `POST /collection` を送る。
    func submit() async {
        guard let catalogId = selectedCatalogId, !catalogId.isEmpty else {
            submitError = "カタログを選択してください"
            return
        }

        submitError = nil
        isSubmitting = true
        defer { isSubmitting = false }

        // 正規化（qty>=1 / cost>=0 / trim）は NewCollectionInput.init が行う。
        let input = NewCollectionInput(
            catalogId: catalogId,
            condition: condition,
            qty: qty,
            cost: cost,
            purchaseDate: purchaseDate,
            store: store,
            location: location,
            memo: memo
        )

        do {
            let created = try await createCollection(input)
            onCreated?(created)
        } catch {
            if let apiError = error as? APIError, apiError == .unauthorized {
                onUnauthorized?()
            }
            submitError = error.localizedDescription
        }
    }
}
