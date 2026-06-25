import SwiftUI

/// S3 キー / 絶対 URL を解決して表示する画像ビュー（空ならプレースホルダ）。
struct RemoteImage: View {
    let imageUrl: String
    let imageBaseURL: String
    var cornerRadius: CGFloat = Theme.radius

    private var url: URL? {
        ImageURLResolver.resolve(imageUrl, imageBaseURL: imageBaseURL)
    }

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        placeholder
                    default:
                        Theme.panel2.overlay(ProgressView().tint(Theme.muted))
                    }
                }
            } else {
                placeholder
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var placeholder: some View {
        Theme.panel2.overlay(
            Image(systemName: "book.closed").foregroundStyle(Theme.muted)
        )
    }
}
