import Foundation

/// 価格推移の変化率。
/// 先頭が 0 または空配列なら 0。それ以外は (末尾 - 先頭) / 先頭。
public func changeRate(_ history: [Int]) -> Double {
    guard let first = history.first, let last = history.last, first != 0 else {
        return 0
    }
    return Double(last - first) / Double(first)
}
