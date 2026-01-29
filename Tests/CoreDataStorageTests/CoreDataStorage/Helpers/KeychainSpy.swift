import Foundation

final class KeychainSpy {
    enum Message: Equatable {
        case add(attributes: CFDictionary)
        case retrieve(query: CFDictionary)
        case update(query: CFDictionary, attributes: CFDictionary)
        case delete(query: CFDictionary)
    }

    private(set) var messages: [Message] = []
    var stubbedStatus: OSStatus = errSecSuccess
    var stubbedRetrieveValue: Data?

    func addItem(_ attributes: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        messages.append(.add(attributes: attributes))
        return stubbedStatus
    }

    func retrieveItem(_ query: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        messages.append(.retrieve(query: query))
        if let value = stubbedRetrieveValue, stubbedStatus == errSecSuccess {
            result?.pointee = value as CFData
        }
        return stubbedStatus
    }

    func updateItem(_ query: CFDictionary, _ attributesToUpdate: CFDictionary) -> OSStatus {
        messages.append(.update(query: query, attributes: attributesToUpdate))
        return stubbedStatus
    }

    func deleteItem(_ query: CFDictionary) -> OSStatus {
        messages.append(.delete(query: query))
        return stubbedStatus
    }
}
