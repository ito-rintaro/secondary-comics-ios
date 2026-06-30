import Foundation

// カタログ選択 UI 用の検索（クライアント側）。

/// `search` で部分一致（大文字小文字無視）したカタログを返す。
/// 対象は `title` / `author` / `publisher` / `volume` / `year` を空白連結した文字列。
/// `search` が空なら全件を返す。
public func applyCatalogQuery(_ catalogs: [Catalog], search: String = "") -> [Catalog] {
    let needle = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    guard !needle.isEmpty else { return catalogs }
    return catalogs.filter { $0.searchText.lowercased().contains(needle) }
}
