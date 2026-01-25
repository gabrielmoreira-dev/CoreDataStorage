@testable import CoreDataStorage
import Foundation

public final class KVSDataSourceSpy<Value: Equatable>: KVSDataSourceType {
    public enum Message: Equatable {
        case set(value: Value, key: String)
        case get(key: String)
        case update(value: Value, key: String)
        case delete(key: String)
    }

    public private(set) var messages: [Message] = []
    public var stubbedGetValue: Value?

    public init() {}

    public func set(_ value: Any?, using key: String) {
        if let value = value as? Value {
            messages.append(.set(value: value, key: key))
        }
    }

    public func get<T>(using key: String) -> T? {
        messages.append(.get(key: key))
        return stubbedGetValue as? T
    }

    public func update(_ value: Any?, using key: String) {
        if let value = value as? Value {
            messages.append(.update(value: value, key: key))
        }
    }

    public func delete(using key: String) {
        messages.append(.delete(key: key))
    }
}
