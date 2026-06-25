import SwiftUI

/// 表示フォーマット（Presentation の関心事・計算とは分離）。
enum Format {
    private static let grouping: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale(identifier: "ja_JP")
        f.maximumFractionDigits = 0
        return f
    }()

    /// 例: ¥35,000 / ¥-1,600（負号は数値側に付く）。
    static func yen(_ n: Int) -> String {
        let grouped = grouping.string(from: NSNumber(value: n)) ?? "\(n)"
        return "¥" + grouped
    }

    /// 含み損益用。正のとき "+" を前置。例: +¥35,000 / ¥-1,600 / ¥0。
    static func signedYen(_ n: Int) -> String {
        (n > 0 ? "+" : "") + yen(n)
    }

    /// 例: +18.0% / -5.0%（0 は "+0.0%"）。
    static func percent(_ rate: Double) -> String {
        let sign = rate >= 0 ? "+" : ""
        return sign + String(format: "%.1f", rate * 100) + "%"
    }
}

/// 損益・変化率の色クラス。
extension Theme {
    /// 損益: n>0 → 緑 / n<0 → 赤 / 0 → 標準テキスト。
    static func plColor(_ n: Int) -> Color {
        if n > 0 { return plus }
        if n < 0 { return minus }
        return text
    }

    /// 変化率: rate>=0 → 緑 / それ未満 → 赤（0 は plus 扱い）。
    static func changeColor(_ rate: Double) -> Color {
        rate >= 0 ? plus : minus
    }
}
