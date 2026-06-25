import Foundation

// コレクション 1 件あたりの計算式。
// Web の src/domain/ と 1:1。計算式はここが正。
public extension CollectionItem {
    /// 含み損益 = (market - cost) * qty
    var profitLoss: Int { (market - cost) * qty }

    /// 評価額 = market * qty
    var evaluation: Int { market * qty }

    /// 取得額 = cost * qty
    var acquisitionCost: Int { cost * qty }
}
