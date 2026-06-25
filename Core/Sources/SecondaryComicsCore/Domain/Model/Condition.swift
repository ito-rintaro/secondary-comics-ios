import Foundation

/// 状態ランク。
public enum Condition: String, Codable, Sendable, CaseIterable {
    case s = "S"
    case a = "A"
    case b = "B"
    case c = "C"

    /// 表示ラベル。S（新品・美品）/ A（良い）/ B（並）/ C（傷み・難あり）。
    public var label: String {
        switch self {
        case .s: return "S（新品・美品）"
        case .a: return "A（良い）"
        case .b: return "B（並）"
        case .c: return "C（傷み・難あり）"
        }
    }
}
