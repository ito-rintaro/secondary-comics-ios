import Foundation

/// `POST /collection` のリクエストボディ（OpenAPI の `NewCollectionInput`）。
///
/// 書誌（title/author/…/flags/imageUrl）はカタログ由来のためサーバが補完し、
/// `market` / `marketSource` はサーバがマーケットから導出、`id` / `updatedAt` はサーバが採番するため
/// **いずれも含めない**。必須は `catalogId` と `condition` のみ。
///
/// Encodable のみ（送信専用）。正規化（qty>=1 / cost>=0 / 文字列 trim）は `init` で行う。
public struct NewCollectionInput: Encodable, Sendable, Equatable {
    public let catalogId: String
    public let condition: Condition
    public let qty: Int
    public let cost: Int
    public let purchaseDate: String
    public let store: String
    public let location: String
    public let memo: String

    /// 入力値を正規化して生成する。
    /// - `qty` は `max(1, _)`、`cost` は `max(0, _)`。
    /// - 文字列フィールドは前後空白を trim。
    public init(
        catalogId: String,
        condition: Condition,
        qty: Int = 1,
        cost: Int = 0,
        purchaseDate: String = "",
        store: String = "",
        location: String = "",
        memo: String = ""
    ) {
        self.catalogId = catalogId.trimmingCharacters(in: .whitespacesAndNewlines)
        self.condition = condition
        self.qty = max(1, qty)
        self.cost = max(0, cost)
        self.purchaseDate = purchaseDate.trimmingCharacters(in: .whitespacesAndNewlines)
        self.store = store.trimmingCharacters(in: .whitespacesAndNewlines)
        self.location = location.trimmingCharacters(in: .whitespacesAndNewlines)
        self.memo = memo.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
