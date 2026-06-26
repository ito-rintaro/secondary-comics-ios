import SwiftUI

/// アプリのエントリポイント。ダーク基調固定。
/// 起動時に Amplify を初期化し、認証状態でログイン画面 / 本体を出し分ける。
@main
struct SecondaryComicsApp: App {
    @State private var container = AppContainer()
    @State private var auth: AuthViewModel

    init() {
        // 実 API モードのときだけ Amplify(Cognito) を初期化する。
        let container = AppContainer()
        if container.config.useAPI {
            AmplifyConfigurator.configure(with: container.config)
        }
        _container = State(initialValue: container)
        _auth = State(initialValue: AuthViewModel(service: container.authService))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch auth.phase {
                case .restoring:
                    LaunchView()
                case .signedOut:
                    LoginView(model: auth)
                case .signedIn:
                    RootView(container: container, authModel: auth)
                }
            }
            .task { await auth.restore() }
        }
    }
}

/// 起動直後（セッション復元中）のスプラッシュ。
private struct LaunchView: View {
    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            ProgressView().tint(Theme.muted)
        }
        .preferredColorScheme(.dark)
    }
}
