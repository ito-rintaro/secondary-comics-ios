import Foundation

/// 初版 / 帯 / 特装（サイン）のフラグ。
public struct ConditionFlags: Codable, Sendable, Equatable {
    public var firstEd: Bool // 初版
    public var obi: Bool     // 帯付き
    public var special: Bool // 特装 / サイン

    public init(firstEd: Bool = false, obi: Bool = false, special: Bool = false) {
        self.firstEd = firstEd
        self.obi = obi
        self.special = special
    }
}
