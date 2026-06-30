import SwiftUI
import Charts
import SecondaryComicsCore

/// マイコレクションの「評価額の内訳」ドーナツカード。
/// 集計はヘッダーのサマリーに合わせ、全件（フィルタ非依存）を対象にする。
struct CollectionBreakdownCard: View {
    let items: [CollectionItem]
    let totalValue: Int

    @State private var axis: BreakdownAxis = .title

    private var segments: [BreakdownSegment] {
        BreakdownSegment.make(from: items, by: axis)
    }

    var body: some View {
        if segments.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 12) {
                header
                Picker("内訳の軸", selection: $axis) {
                    ForEach(BreakdownAxis.allCases, id: \.self) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)

                donut
                legend
            }
            .padding(16)
            .background(Theme.panel, in: RoundedRectangle(cornerRadius: Theme.radius))
        }
    }

    private var header: some View {
        Text("評価額の内訳").font(.caption).foregroundStyle(Theme.muted)
    }

    private var donut: some View {
        Chart(segments) { seg in
            SectorMark(
                angle: .value("評価額", seg.value),
                innerRadius: .ratio(0.62),
                angularInset: 1.5
            )
            .cornerRadius(3)
            .foregroundStyle(seg.color)
        }
        .frame(height: 200)
        .chartBackground { _ in
            VStack(spacing: 2) {
                Text("現在評価額").font(.caption2).foregroundStyle(Theme.muted)
                Text(Format.yen(totalValue))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Theme.text)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            .padding(.horizontal, 24)
        }
    }

    private var legend: some View {
        VStack(spacing: 8) {
            ForEach(segments) { seg in
                HStack(spacing: 8) {
                    Circle().fill(seg.color).frame(width: 10, height: 10)
                    Text(seg.label)
                        .font(.subheadline)
                        .foregroundStyle(Theme.text)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Text(percentLabel(seg.value))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                        .monospacedDigit()
                    Text(Format.yen(seg.value))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.text)
                        .monospacedDigit()
                }
            }
        }
    }

    private func percentLabel(_ value: Int) -> String {
        guard totalValue > 0 else { return "0%" }
        let pct = (Double(value) / Double(totalValue) * 100).rounded()
        return "\(Int(pct))%"
    }
}

/// 内訳の集計軸。
enum BreakdownAxis: CaseIterable {
    case title, publisher, author, condition

    var label: String {
        switch self {
        case .title: return "作品"
        case .publisher: return "出版社"
        case .author: return "著者"
        case .condition: return "状態"
        }
    }

    /// 集計キー（空欄は「未設定」に丸める）。
    func key(_ item: CollectionItem) -> String {
        let raw: String
        switch self {
        case .title: raw = item.title
        case .publisher: raw = item.publisher
        case .author: raw = item.author
        case .condition: return item.condition.rawValue
        }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "未設定" : trimmed
    }
}

/// ドーナツ 1 セグメント（評価額の構成要素）。
struct BreakdownSegment: Identifiable {
    let id: String      // 凡例ラベル（軸キー or "その他"）
    let label: String
    let value: Int      // 評価額の合計
    let color: Color

    /// 上位 maxSegments 件を残し、残りは「その他」へ集約。評価額 0 の軸は除外。
    static func make(from items: [CollectionItem], by axis: BreakdownAxis) -> [BreakdownSegment] {
        let maxSegments = 6

        var totals: [String: Int] = [:]
        for item in items where item.evaluation > 0 {
            totals[axis.key(item), default: 0] += item.evaluation
        }
        guard !totals.isEmpty else { return [] }

        // 評価額の降順（同額はラベル昇順で安定化）。
        let ranked = totals
            .map { (label: $0.key, value: $0.value) }
            .sorted { $0.value != $1.value ? $0.value > $1.value : $0.label < $1.label }

        var rows: [(label: String, value: Int, isOther: Bool)] =
            ranked.prefix(maxSegments).map { (label: $0.label, value: $0.value, isOther: false) }
        let rest = ranked.dropFirst(maxSegments)
        if !rest.isEmpty {
            rows.append((label: "その他", value: rest.reduce(0) { $0 + $1.value }, isOther: true))
        }

        return rows.enumerated().map { index, row in
            BreakdownSegment(
                id: row.isOther ? "__other__" : row.label,
                label: row.label,
                value: row.value,
                color: row.isOther ? Theme.muted : color(at: index, of: rows.count)
            )
        }
    }

    /// accent2（青）の不透明度ランプ。上位ほど濃く、装飾色を増やさない。
    private static func color(at index: Int, of count: Int) -> Color {
        guard count > 1 else { return Theme.accent2 }
        let t = Double(index) / Double(count - 1)
        return Theme.accent2.opacity(1.0 - t * 0.6) // 1.0 → 0.4
    }
}
