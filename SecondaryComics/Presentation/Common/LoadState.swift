import Foundation

/// 非同期ロードの状態。ローディング / エラー表示に使う。
enum LoadState<Value>: Sendable where Value: Sendable {
    case idle
    case loading
    case loaded(Value)
    case failed(String)
}
