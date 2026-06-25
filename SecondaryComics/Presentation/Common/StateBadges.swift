import SwiftUI
import SecondaryComicsCore

/// 状態バッジ: 初版（hot）・帯・特装/サイン。
struct StateBadges: View {
    let flags: ConditionFlags
    var condition: Condition? = nil

    var body: some View {
        HStack(spacing: 4) {
            if let condition {
                badge(condition.rawValue, color: Theme.accent2)
            }
            if flags.firstEd { badge("初版", color: Theme.accent, icon: "flame.fill") }
            if flags.obi { badge("帯", color: Theme.muted) }
            if flags.special { badge("特装", color: Theme.accent2) }
        }
    }

    private func badge(_ text: String, color: Color, icon: String? = nil) -> some View {
        HStack(spacing: 2) {
            if let icon { Image(systemName: icon).font(.system(size: 9)) }
            Text(text).font(.system(size: 11, weight: .semibold))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .foregroundStyle(color)
        .background(color.opacity(0.15), in: Capsule())
    }
}
