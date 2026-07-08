import Foundation

/// 成約ログ（`MarketSale`）を catalog 単位の相場サマリ（`MarketSummary`）に畳み込む。
///
/// これはサーバの `GET /market/summary` が行う集計をクライアント側で再現したもので、
/// モックモード（実 API 不在）で「成約イベント列 → そこから導いたサマリ」を作るために使う。
/// 実 API 使用時は本関数は呼ばれず、サーバ導出済みのサマリをそのまま受け取る。
///
/// 導出仕様（OpenAPI の `MarketSummary.history` と一致）:
/// - 成約が 1 件以上ある catalog のみサマリ化する（0 件は含めない）。
/// - `history` は末尾＝当月の 12 ヶ月ぶんの月次擬似系列。各月は当月成約の平均価格（四捨五入）。
///   成約の無い月は直前月をキャリー（前方フィル）、最初の成約より前は最初の非空値でバックフィル。
/// - `price` は history 末尾、`change` は `changeRate(history)`。
/// - `sampleCount` は集計に使った成約点数、`lastSoldAt` は直近成約日。
/// - 書誌（title/author/…/flags/imageUrl）は直近成約のものを採用する。
///
/// `asOf` は「当月（history 末尾のバケット）」を決める基準日。既定は現在時刻。
public func deriveMarketSummaries(from sales: [MarketSale], asOf: Date = Date()) -> [MarketSummary] {
    let calendar = Calendar(identifier: .gregorian)
    let asOfComponents = calendar.dateComponents([.year, .month], from: asOf)
    guard let asOfYear = asOfComponents.year, let asOfMonth = asOfComponents.month else { return [] }
    let asOfBucket = asOfYear * 12 + (asOfMonth - 1)

    // catalogId を初出順に保ちながらグルーピングする。
    var order: [String] = []
    var groups: [String: [MarketSale]] = [:]
    for sale in sales {
        if groups[sale.catalogId] == nil { order.append(sale.catalogId) }
        groups[sale.catalogId, default: []].append(sale)
    }

    return order.compactMap { catalogId in
        guard let group = groups[catalogId], !group.isEmpty else { return nil }
        return summary(for: catalogId, sales: group, asOfBucket: asOfBucket)
    }
}

/// 単一 catalog の成約列を 1 件の `MarketSummary` に畳み込む。
private func summary(for catalogId: String, sales: [MarketSale], asOfBucket: Int) -> MarketSummary {
    // 各月バケットへ成約価格を集約する（過去 12 ヶ月・末尾＝当月）。
    // 12 ヶ月より古い成約は先頭バケットへ、未来日の成約は末尾バケットへクランプする。
    var sums = [Int](repeating: 0, count: 12)
    var counts = [Int](repeating: 0, count: 12)
    for sale in sales {
        guard let bucket = monthBucket(sale.soldAt) else { continue }
        let index = min(11, max(0, 11 - (asOfBucket - bucket)))
        sums[index] += sale.price
        counts[index] += 1
    }

    // 各月の平均（四捨五入）。成約の無い月は nil のまま。
    var monthly: [Int?] = (0..<12).map { counts[$0] > 0 ? Int((Double(sums[$0]) / Double(counts[$0])).rounded()) : nil }

    // バックフィル: 最初の非空値より前を最初の非空値で埋める。
    if let firstIndex = monthly.firstIndex(where: { $0 != nil }), let firstValue = monthly[firstIndex] {
        for i in 0..<firstIndex { monthly[i] = firstValue }
    }
    // 前方フィル: 空月を直前月でキャリーする。
    var carry = monthly.first.flatMap { $0 } ?? 0
    let history: [Int] = monthly.map { value in
        if let value { carry = value }
        return carry
    }

    // 書誌・直近成約は soldAt 最大（YYYY-MM-DD は辞書順＝時系列）を採用する。
    let latest = sales.max { $0.soldAt < $1.soldAt } ?? sales[0]

    return MarketSummary(
        catalogId: catalogId,
        title: latest.title,
        author: latest.author,
        publisher: latest.publisher,
        volume: latest.volume,
        flags: latest.flags,
        imageUrl: latest.imageUrl,
        price: history.last ?? 0,
        change: changeRate(history),
        history: history,
        sampleCount: sales.count,
        lastSoldAt: latest.soldAt
    )
}

/// "YYYY-MM-DD" を 年*12 + (月-1) の月インデックスへ変換する。解析不能なら nil。
private func monthBucket(_ soldAt: String) -> Int? {
    let parts = soldAt.split(separator: "-")
    guard parts.count >= 2, let year = Int(parts[0]), let month = Int(parts[1]) else { return nil }
    return year * 12 + (month - 1)
}
