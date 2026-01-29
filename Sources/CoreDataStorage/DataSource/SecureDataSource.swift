import Foundation

public protocol SecureDataSourceType {
    func set(_ data: Data, service: String, account: String) throws
    func get(service: String, account: String) -> Data?
    func update(_ data: Data, service: String, account: String) throws
    func delete(service: String, account: String) throws
}

public enum SecureDataSourceError: Error, Equatable {
    case duplicatedEntry
    case itemNotFound
    case unknown(OSStatus)
}

public final class SecureDataSource: SecureDataSourceType {
    public typealias AddItem = (
        _ attributes: CFDictionary,
        _ result: UnsafeMutablePointer<CFTypeRef?>?
    ) -> OSStatus
    public typealias RetrieveItem = (
        _ query: CFDictionary,
        _ result: UnsafeMutablePointer<CFTypeRef?>?
    ) -> OSStatus
    public typealias UpdateItem = (
        _ query: CFDictionary,
        _ attributesToUpdate: CFDictionary
    ) -> OSStatus
    public typealias DeleteItem = (_ query: CFDictionary) -> OSStatus

    private let addItem: AddItem
    private let retrieveItem: RetrieveItem
    private let updateItem: UpdateItem
    private let deleteItem: DeleteItem
    private let isDebugEnabled: Bool

    public init(
        addItem: @escaping AddItem = SecItemAdd,
        retrieveItem: @escaping RetrieveItem = SecItemCopyMatching,
        updateItem: @escaping UpdateItem = SecItemUpdate,
        deleteItem: @escaping DeleteItem = SecItemDelete,
        debugEnabled: Bool = false
    ) {
        self.addItem = addItem
        self.retrieveItem = retrieveItem
        self.updateItem = updateItem
        self.deleteItem = deleteItem
        self.isDebugEnabled = debugEnabled
    }

    public func set(_ data: Data, service: String, account: String) throws {
        let attributes: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecValueData as String: data as AnyObject
        ]
        let status = addItem(attributes as CFDictionary, nil)

        guard status != errSecDuplicateItem else {
            if isDebugEnabled {
                debugPrint("[SecureDataSource] Set failed: duplicated entry for account \(account)")
            }
            throw SecureDataSourceError.duplicatedEntry
        }
        guard status == errSecSuccess else {
            if isDebugEnabled {
                debugPrint("[SecureDataSource] Set failed: unknown error \(status)")
            }
            throw SecureDataSourceError.unknown(status)
        }
        if isDebugEnabled {
            debugPrint("[SecureDataSource] Set: data for service \(service), account \(account)")
        }
    }

    public func get(service: String, account: String) -> Data? {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        _ = retrieveItem(query as CFDictionary, &result)

        let data = result as? Data
        if isDebugEnabled {
            debugPrint("[SecureDataSource] Get: data for service \(service), account \(account)")
        }
        return data
    }

    public func update(_ data: Data, service: String, account: String) throws {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject
        ]
        let attributesToUpdate: [String: AnyObject] = [
            kSecValueData as String: data as AnyObject
        ]
        let status = updateItem(query as CFDictionary, attributesToUpdate as CFDictionary)

        guard status != errSecItemNotFound else {
            if isDebugEnabled {
                debugPrint("[SecureDataSource] Update failed: item not found for account \(account)")
            }
            throw SecureDataSourceError.itemNotFound
        }
        guard status == errSecSuccess else {
            if isDebugEnabled {
                debugPrint("[SecureDataSource] Update failed: unknown error \(status) ")
            }
            throw SecureDataSourceError.unknown(status)
        }
        if isDebugEnabled {
            debugPrint("[SecureDataSource] Update: data for service \(service), account \(account)")
        }
    }

    public func delete(service: String, account: String) throws {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject
        ]
        let status = deleteItem(query as CFDictionary)

        guard status != errSecItemNotFound else {
            if isDebugEnabled {
                debugPrint("[SecureDataSource] Delete failed: item not found for account \(account)")
            }
            throw SecureDataSourceError.itemNotFound
        }
        guard status == errSecSuccess else {
            if isDebugEnabled {
                debugPrint("[SecureDataSource] Delete failed: unknown error \(status)")
            }
            throw SecureDataSourceError.unknown(status)
        }
        if isDebugEnabled {
            debugPrint("[SecureDataSource] Delete: service \(service), account \(account)")
        }
    }
}
