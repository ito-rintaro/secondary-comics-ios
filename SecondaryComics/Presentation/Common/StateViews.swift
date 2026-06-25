import SwiftUI

/// 空状態ガイド。
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 44)).foregroundStyle(Theme.muted)
            Text(title).font(.headline).foregroundStyle(Theme.text)
            Text(message).font(.subheadline).foregroundStyle(Theme.muted)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}

/// エラー状態 + 再試行。
struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle").font(.system(size: 40)).foregroundStyle(Theme.minus)
            Text("読み込みに失敗しました").font(.headline).foregroundStyle(Theme.text)
            Text(message).font(.caption).foregroundStyle(Theme.muted).multilineTextAlignment(.center)
            Button("再試行", action: retry)
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
        }
        .padding(32)
    }
}
