import Testing
@testable import CoreDataStorage
@testable import CoreDataStorageTestUtils

@Suite
final class KVSDataSourceSpyTests {
    private let sut: KVSDataSourceSpy<String>

    init() {
        sut = KVSDataSourceSpy<String>()
    }

    @Test("Should record set message")
    func testRecordSetMessage() {
        let key = "key"
        let value = "value"

        sut.set(value, using: key)

        #expect(sut.messages == [.set(value: value, key: key)])
    }

    @Test("Should record get message")
    func testRecordGetMessage() {
        let key = "key"

        let _: String? = sut.get(using: key)

        #expect(sut.messages == [.get(key: key)])
    }

    @Test("Should record update message")
    func testRecordUpdateMessage() {
        let key = "key"
        let value = "value"

        sut.update(value, using: key)

        #expect(sut.messages == [.update(value: value, key: key)])
    }

    @Test("Should record delete message")
    func testRecordDeleteMessage() {
        let key = "key"

        sut.delete(using: key)

        #expect(sut.messages == [.delete(key: key)])
    }

    @Test("Should record multiple messages in order")
    func testRecordMultipleMessages() {
        let key = "key"
        let value1 = "value1"
        let value2 = "value2"

        sut.set(value1, using: key)
        let _: String? = sut.get(using: key)
        sut.update(value2, using: key)
        sut.delete(using: key)

        #expect(sut.messages == [
            .set(value: value1, key: key),
            .get(key: key),
            .update(value: value2, key: key),
            .delete(key: key)
        ])
    }

    @Test("Should return stubbed value on get")
    func testReturnStubbedValue() {
        let key = "key"
        let stubbedValue = "stubbedValue"

        sut.stubbedGetValue = stubbedValue

        let result: String? = sut.get(using: key)

        #expect(result == stubbedValue)
    }

    @Test("Should return nil when no stubbed value")
    func testReturnNilWhenNoStubbedValue() {
        let key = "key"

        let result: String? = sut.get(using: key)

        #expect(result == nil)
    }
}
