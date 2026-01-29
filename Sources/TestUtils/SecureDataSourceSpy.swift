@testable import CoreDataStorage
import Foundation

public final class SecureDataSourceSpy: SecureDataSourceType {
    public enum Message: Equatable {
        case set(data: Data, service: String, account: String)
        case get(service: String, account: String)
        case update(data: Data, service: String, account: String)
        case delete(service: String, account: String)
    }

    public private(set) var messages: [Message] = []
    public var stubbedValue: Data?
    public var stubbedError: SecureDataSourceError?

    public init() {}

    public func set(_ data: Data, service: String, account: String) throws {
        messages.append(.set(data: data, service: service, account: account))
        if let error = stubbedError {
            throw error
        }
    }

    public func get(service: String, account: String) -> Data? {
        messages.append(.get(service: service, account: account))
        return stubbedValue
    }

    public func update(_ data: Data, service: String, account: String) throws {
        messages.append(.update(data: data, service: service, account: account))
        if let error = stubbedError {
            throw error
        }
    }

    public func delete(service: String, account: String) throws {
        messages.append(.delete(service: service, account: account))
        if let error = stubbedError {
            throw error
        }
    }
}
