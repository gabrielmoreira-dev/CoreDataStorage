import Foundation

public protocol KVSDataSourceType {
    func set(_ value: Any?, using key: String)
    func get<T>(using key: String) -> T?
    func update(_ value: Any?, using key: String)
    func delete(using key: String)
}

public final class KVSDataSource: KVSDataSourceType {
    private let provider: UserDefaults
    private let isDebugEnabled: Bool

    public init(provider: UserDefaults = .standard, debugEnabled: Bool = false) {
        self.provider = provider
        self.isDebugEnabled = debugEnabled
    }

    public func set(_ value: Any?, using key: String) {
        provider.set(value, forKey: key)
        if isDebugEnabled {
            debugPrint("[KVSDataSource] Set: \(String(describing: value)) for key: \(key)")
        }
    }

    public func get<T>(using key: String) -> T? {
        let value = provider.object(forKey: key) as? T
        if isDebugEnabled {
            debugPrint("[KVSDataSource] Get: \(String(describing: value)) for key: \(key)")
        }
        return value
    }

    public func update(_ value: Any?, using key: String) {
        provider.set(value, forKey: key)
        if isDebugEnabled {
            debugPrint("[KVSDataSource] Update: \(String(describing: value)) for key: \(key)")
        }
    }

    public func delete(using key: String) {
        provider.removeObject(forKey: key)
        if isDebugEnabled {
            debugPrint("[KVSDataSource] Delete: key \(key)")
        }
    }
}
