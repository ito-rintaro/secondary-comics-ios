import SwiftUI

/// 配色トークン（Web の src/index.css の CSS 変数）。
/// 色の意味は固定: 緑=益、赤=損。装飾目的で色を増やさない。
enum Theme {
    static let bg = Color(hex: 0x0F1115)      // 画面背景
    static let panel = Color(hex: 0x181B22)   // カード / パネル背景
    static let panel2 = Color(hex: 0x1F232C)  // パネル内のひと段濃い面
    static let line = Color(hex: 0x2A2F3A)    // 罫線 / 境界
    static let text = Color(hex: 0xE7E9EE)    // 本文テキスト
    static let muted = Color(hex: 0x9AA3B2)   // 補助テキスト
    static let accent = Color(hex: 0xE0245E)  // ブランドカラー（ピンク）
    static let accent2 = Color(hex: 0x3A8BFF) // サブアクセント（青）
    static let plus = Color(hex: 0x34C759)    // 含み益・上昇（緑）
    static let minus = Color(hex: 0xFF453A)   // 含み損・下落（赤）

    /// 角丸。
    static let radius: CGFloat = 12
}

extension Color {
    /// 0xRRGGBB 形式の HEX から生成。
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
