import Foundation

/// 相場の出所。現状は manual 固定だが、将来 auto/estimate を区別する。
public enum MarketSource: String, Codable, Sendable, CaseIterable {
    case manual   // 手入力
    case auto     // 自動取得
    case estimate // 推定

    /// 鮮度の明示用ラベル（誤った資産額をサイレントに見せない）。
    public var label: String {
        switch self {
        case .manual: return "手入力"
        case .auto: return "自動取得"
        case .estimate: return "推定"
        }
    }
}
