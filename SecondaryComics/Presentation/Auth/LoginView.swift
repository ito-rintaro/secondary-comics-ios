import SwiftUI

/// Cognito ログイン画面。メールアドレス + パスワードでサインインする。
struct LoginView: View {
    @Bindable var model: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @FocusState private var focus: Field?

    private enum Field { case email, password }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Theme.accent)
                    Text("Secondary Comics")
                        .font(.title2.bold())
                        .foregroundStyle(Theme.text)
                    Text("コレクションと相場をひとつに")
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted)
                }

                VStack(spacing: 12) {
                    TextField("メールアドレス", text: $email)
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focus, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focus = .password }
                        .fieldStyle()

                    SecureField("パスワード", text: $password)
                        .textContentType(.password)
                        .focused($focus, equals: .password)
                        .submitLabel(.go)
                        .onSubmit { submit() }
                        .fieldStyle()
                }

                if let message = model.errorMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(Theme.minus)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: submit) {
                    HStack {
                        if model.isSubmitting {
                            ProgressView().tint(.white)
                        }
                        Text("ログイン").bold()
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(Theme.accent)
                .disabled(!canSubmit)

                Spacer()
            }
            .padding(24)
        }
        .preferredColorScheme(.dark)
    }

    private var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty && !model.isSubmitting
    }

    private func submit() {
        guard canSubmit else { return }
        focus = nil
        Task { await model.signIn(email: email, password: password) }
    }
}

/// 入力欄の共通スタイル（パネル背景 + 角丸）。
private extension View {
    func fieldStyle() -> some View {
        padding(14)
            .background(Theme.panel, in: RoundedRectangle(cornerRadius: Theme.radius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radius)
                    .stroke(Theme.line, lineWidth: 1)
            )
            .foregroundStyle(Theme.text)
            .tint(Theme.accent)
    }
}
