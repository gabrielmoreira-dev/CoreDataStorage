import Foundation
import Testing
@testable import CoreDataStorage

@Suite
final class SecureDataSourceTests {
    private let keychainSpy: KeychainSpy
    private let sut: SecureDataSource
    private let data = Data("test".utf8)
    private let service = "test.service"
    private let account = "test.account"

    init() {
        keychainSpy = KeychainSpy()
        sut = SecureDataSource(
            addItem: keychainSpy.addItem,
            retrieveItem: keychainSpy.retrieveItem,
            updateItem: keychainSpy.updateItem,
            deleteItem: keychainSpy.deleteItem,
            debugEnabled: true
        )
    }

    @Test("Should set data successfully")
    func testSetDataSuccessfully() throws {
        try sut.set(data, service: service, account: account)

        #expect(keychainSpy.messages.count == 1)
        if case .add(let attributes) = keychainSpy.messages[0],
           let attributes = attributes as? [String: AnyObject] {
            #expect(attributes[kSecClass as String] as? NSString == kSecClassGenericPassword as NSString)
            #expect(attributes[kSecAttrService as String] as? String == service)
            #expect(attributes[kSecAttrAccount as String] as? String == account)
            #expect(attributes[kSecValueData as String] as? Data == data)
        } else {
            Issue.record("Expected set message with query")
        }
    }

    @Test("Should throw duplicatedEntry when item already exists")
    func testSetThrowsDuplicatedEntry() throws {
        keychainSpy.stubbedStatus = errSecDuplicateItem

        #expect(throws: SecureDataSourceError.duplicatedEntry) {
            try sut.set(data, service: service, account: account)
        }
    }

    @Test("Should throw unknown error on set failure")
    func testSetThrowsUnknownError() throws {
        let unknownStatus: OSStatus = -1234
        keychainSpy.stubbedStatus = unknownStatus

        #expect(throws: SecureDataSourceError.unknown(unknownStatus)) {
            try sut.set(data, service: service, account: account)
        }
    }

    @Test("Should get data successfully")
    func testGetDataSuccessfully() {
        keychainSpy.stubbedRetrieveValue = data

        let result = sut.get(service: service, account: account)

        #expect(result == data)
        #expect(keychainSpy.messages.count == 1)
        if case .retrieve(let query) = keychainSpy.messages[0],
           let query = query as? [String: AnyObject] {
            #expect(query[kSecClass as String] as? NSString == kSecClassGenericPassword as NSString)
            #expect(query[kSecAttrService as String] as? String == service)
            #expect(query[kSecAttrAccount as String] as? String == account)
        } else {
            Issue.record("Expected get message with query")
        }
    }

    @Test("Should return nil when item not found")
    func testGetReturnsNilWhenNotFound() {
        keychainSpy.stubbedRetrieveValue = nil

        let result = sut.get(service: service, account: account)

        #expect(result == nil)
    }

    @Test("Should update data successfully")
    func testUpdateDataSuccessfully() throws {
        keychainSpy.stubbedStatus = errSecSuccess

        try sut.update(data, service: service, account: account)

        #expect(keychainSpy.messages.count == 1)
        if case let .update(query, attributes) = keychainSpy.messages[0],
           let query = query as? [String: AnyObject],
           let attributes = attributes as? [String: AnyObject] {
            #expect(query[kSecClass as String] as? NSString == kSecClassGenericPassword as NSString)
            #expect(query[kSecAttrService as String] as? String == service)
            #expect(query[kSecAttrAccount as String] as? String == account)
            #expect(attributes[kSecValueData as String] as? Data == data)
        } else {
            Issue.record("Expected get message with query")
        }
    }

    @Test("Should throw itemNotFound when updating non-existent item")
    func testUpdateThrowsItemNotFoundError() throws {
        keychainSpy.stubbedStatus = errSecItemNotFound

        #expect(throws: SecureDataSourceError.itemNotFound) {
            try sut.update(data, service: service, account: account)
        }
    }

    @Test("Should throw unknown error on delete failure")
    func testUpdateThrowsUnknownError() throws {
        let unknownStatus: OSStatus = -1234
        keychainSpy.stubbedStatus = unknownStatus

        #expect(throws: SecureDataSourceError.unknown(unknownStatus)) {
            try sut.update(data, service: service, account: account)
        }
    }

    @Test("Should delete data successfully")
    func testDeleteDataSuccessfully() throws {
        try sut.delete(service: service, account: account)

        #expect(keychainSpy.messages.count == 1)
        if case .delete(let query) = keychainSpy.messages[0],
           let query = query as? [String: AnyObject] {
            #expect(query[kSecClass as String] as? NSString == kSecClassGenericPassword as NSString)
            #expect(query[kSecAttrService as String] as? String == service)
            #expect(query[kSecAttrAccount as String] as? String == account)
        } else {
            Issue.record("Expected delete message with query")
        }
    }

    @Test("Should throw itemNotFound when deleting non-existent item")
    func testDeleteThrowsItemNotFound() throws {
        keychainSpy.stubbedStatus = errSecItemNotFound

        #expect(throws: SecureDataSourceError.itemNotFound) {
            try sut.delete(service: service, account: account)
        }
    }

    @Test("Should throw unknown error on delete failure")
    func testDeleteThrowsUnknownError() throws {
        let unknownStatus: OSStatus = -1234
        keychainSpy.stubbedStatus = unknownStatus

        #expect(throws: SecureDataSourceError.unknown(unknownStatus)) {
            try sut.delete(service: service, account: account)
        }
    }

    @Test("Should handle multiple operations in order")
    func testMultipleOperationsInOrder() throws {
        keychainSpy.stubbedRetrieveValue = data

        try sut.set(data, service: service, account: account)
        _ = sut.get(service: service, account: account)
        try sut.delete(service: service, account: account)

        #expect(keychainSpy.messages.count == 3)
        guard case .add = keychainSpy.messages[0],
              case .retrieve = keychainSpy.messages[1],
              case .delete = keychainSpy.messages[2] else {
            Issue.record("Expected add, retrieve and delete messages")
            return
        }
    }
}
