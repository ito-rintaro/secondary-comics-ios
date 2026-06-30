import SwiftUI
import SecondaryComicsCore

/// コレクション新規登録モーダル。
/// カタログを検索・単一選択し、所有情報（コンディション必須）を入力して `POST /collection` する。
/// 登録ボタンはカタログ未選択の間 非活性。成功で親が一覧を再取得して閉じる。
struct AddCollectionView: View {
    @State private var model: AddCollectionModel
    let imageBaseURL: String
    let onClose: () -> Void

    // 購入日: 既定は未指定（空文字）。トグル ON のときだけ日付を送る。
    @State private var hasPurchaseDate = false
    @State private var purchaseDate = Date()

    init(model: AddCollectionModel, imageBaseURL: String, onClose: @escaping () -> Void) {
        _model = State(initialValue: model)
        self.imageBaseURL = imageBaseURL
        self.onClose = onClose
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        catalogSection
                        ownedInfoSection
                        if let error = model.submitError {
                            errorBanner(error)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("コレクションに追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル", action: onClose).tint(Theme.muted)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if model.isSubmitting {
                        ProgressView().tint(Theme.accent)
                    } else {
                        Button("登録") { Task { await model.submit() } }
                            .tint(Theme.accent)
                            .disabled(!model.canSubmit)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .task { if case .idle = model.catalogState { await model.loadCatalogs() } }
    }

    // MARK: - カタログ選択

    private var catalogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("カタログを選択")
            searchField
            catalogContent
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.panel, in: RoundedRectangle(cornerRadius: Theme.radius))
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(Theme.muted)
            TextField("作品名・著者・出版社・巻数・発行年", text: $model.catalogSearch)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(Theme.text)
        }
        .padding(10)
        .background(Theme.panel2, in: RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private var catalogContent: some View {
        switch model.catalogState {
        case .idle, .loading:
            ProgressView().tint(Theme.muted).frame(maxWidth: .infinity).padding(.vertical, 24)
        case .failed(let message):
            VStack(spacing: 10) {
                Text(message).font(.caption).foregroundStyle(Theme.muted).multilineTextAlignment(.center)
                Button("再読み込み") { Task { await model.loadCatalogs() } }
                    .buttonStyle(.bordered).tint(Theme.accent)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 16)
        case .loaded:
            if model.visibleCatalogs.isEmpty {
                Text("該当するカタログがありません。")
                    .font(.subheadline).foregroundStyle(Theme.muted)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
            } else {
                VStack(spacing: 8) {
                    ForEach(model.visibleCatalogs) { catalog in
                        CatalogRow(
                            catalog: catalog,
                            imageBaseURL: imageBaseURL,
                            isSelected: model.selectedCatalogId == catalog.id
                        ) {
                            model.selectedCatalogId = catalog.id
                        }
                    }
                }
            }
        }
    }

    // MARK: - 所有情報

    private var ownedInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("所有情報")

            field("コンディション") {
                Picker("コンディション", selection: $model.condition) {
                    ForEach(Condition.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
            }

            field("所有数") {
                Stepper(value: $model.qty, in: 1...999) {
                    Text("\(model.qty) 点").foregroundStyle(Theme.text)
                }
                .tint(Theme.accent)
            }

            field("取得価格（1 点・円）") {
                TextField("0", value: $model.cost, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(inputStyle)
            }

            field("購入日") {
                VStack(spacing: 8) {
                    Toggle("購入日を指定", isOn: $hasPurchaseDate)
                        .tint(Theme.accent)
                        .foregroundStyle(Theme.text)
                    if hasPurchaseDate {
                        DatePicker("購入日", selection: $purchaseDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            field("購入店") {
                TextField("例: まんだらけ", text: $model.store).textFieldStyle(inputStyle)
            }
            field("保管場所") {
                TextField("例: 本棚A", text: $model.location).textFieldStyle(inputStyle)
            }
            field("メモ") {
                TextField("自由記述", text: $model.memo, axis: .vertical)
                    .lineLimit(2...5)
                    .textFieldStyle(inputStyle)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.panel, in: RoundedRectangle(cornerRadius: Theme.radius))
        .onChange(of: hasPurchaseDate) { _, _ in syncPurchaseDate() }
        .onChange(of: purchaseDate) { _, _ in syncPurchaseDate() }
    }

    /// トグル / 日付の変化を `model.purchaseDate`（YYYY-MM-DD or 空）へ反映。
    private func syncPurchaseDate() {
        model.purchaseDate = hasPurchaseDate ? Self.ymd.string(from: purchaseDate) : ""
    }

    private static let ymd: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private func errorBanner(_ message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(Theme.minus)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Theme.minus.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - 小物

    private func sectionTitle(_ text: String) -> some View {
        Text(text).font(.headline).foregroundStyle(Theme.text)
    }

    private func field<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.caption).foregroundStyle(Theme.muted)
            content()
        }
    }

    private var inputStyle: some TextFieldStyle { PanelTextFieldStyle() }
}

/// パネル内テキスト入力の共通スタイル。
private struct PanelTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundStyle(Theme.text)
            .padding(10)
            .background(Theme.panel2, in: RoundedRectangle(cornerRadius: 10))
    }
}

/// カタログ候補 1 行（サムネイル + タイトル + メタ情報）。選択中はハイライト。
private struct CatalogRow: View {
    let catalog: Catalog
    let imageBaseURL: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                RemoteImage(imageUrl: catalog.imageUrl, imageBaseURL: imageBaseURL)
                    .frame(width: 44, height: 62)
                VStack(alignment: .leading, spacing: 4) {
                    Text(catalog.title).font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.text).lineLimit(1)
                    if !catalog.metaLine.isEmpty {
                        Text(catalog.metaLine).font(.caption).foregroundStyle(Theme.muted).lineLimit(1)
                    }
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.accent)
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Theme.accent.opacity(0.14) : Theme.panel2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Theme.accent : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
