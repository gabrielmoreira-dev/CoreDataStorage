import Foundation
import Testing
@testable import CoreDataStorage
@testable import CoreDataStorageTestUtils

@Suite
final class SecureDataSourceSpyTests {
    private let sut: SecureDataSourceSpy
    private let service = "service"
    private let account = "account"
    private let data = Data("test".utf8)

    init() {
        sut = SecureDataSourceSpy()
    }

    @Test("Should record set message")
    func testRecordSetMessage() throws {
        try sut.set(data, service: service, account: account)

        #expect(sut.messages == [.set(data: data, service: service, account: account)])
    }

    @Test("Should record get message")
    func testRecordGetMessage() {
        _ = sut.get(service: service, account: account)

        #expect(sut.messages == [.get(service: service, account: account)])
    }

    @Test("Should record update message")
    func testRecordUpdateMessage() throws {
        try sut.update(data, service: service, account: account)

        #expect(sut.messages == [.update(data: data, service: service, account: account)])
    }

    @Test("Should record delete message")
    func testRecordDeleteMessage() throws {
        try sut.delete(service: service, account: account)

        #expect(sut.messages == [.delete(service: service, account: account)])
    }

    @Test("Should record multiple messages in order")
    func testRecordMultipleMessages() throws {
        let data1 = Data("data1".utf8)
        let data2 = Data("data2".utf8)

        try sut.set(data1, service: service, account: account)
        _ = sut.get(service: service, account: account)
        try sut.update(data2, service: service, account: account)
        try sut.delete(service: service, account: account)

        #expect(sut.messages == [
            .set(data: data1, service: service, account: account),
            .get(service: service, account: account),
            .update(data: data2, service: service, account: account),
            .delete(service: service, account: account)
        ])
    }

    @Test("Should return stubbed value on get")
    func testReturnStubbedValue() {
        sut.stubbedValue = data

        let result = sut.get(service: service, account: account)

        #expect(result == data)
    }

    @Test("Should return nil when no stubbed value")
    func testReturnNilWhenNoStubbedValue() {
        let result = sut.get(service: service, account: account)

        #expect(result == nil)
    }

    @Test("Should throw stubbed error on set")
    func testThrowStubbedErrorOnSet() throws {
        sut.stubbedError = .duplicatedEntry

        #expect(throws: SecureDataSourceError.duplicatedEntry) {
            try sut.set(data, service: service, account: account)
        }
    }

    @Test("Should throw stubbed error on update")
    func testThrowStubbedErrorOnUpdate() throws {
        sut.stubbedError = .itemNotFound

        #expect(throws: SecureDataSourceError.itemNotFound) {
            try sut.update(data, service: service, account: account)
        }
    }

    @Test("Should throw stubbed error on delete")
    func testThrowStubbedErrorOnDelete() throws {
        sut.stubbedError = .itemNotFound

        #expect(throws: SecureDataSourceError.itemNotFound) {
            try sut.delete(service: service, account: account)
        }
    }
}
