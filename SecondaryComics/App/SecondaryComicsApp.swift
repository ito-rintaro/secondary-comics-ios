import SwiftUI

/// アプリのエントリポイント。ダーク基調固定。
@main
struct SecondaryComicsApp: App {
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
    }
}
