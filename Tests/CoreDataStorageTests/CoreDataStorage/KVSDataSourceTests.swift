import Testing
@testable import CoreDataStorage

@Suite
final class KVSDataSourceTests {
    private let providerSpy: UserDefaultsSpy
    private let sut: KVSDataSource

    init() {
        providerSpy = UserDefaultsSpy()
        sut = KVSDataSource(provider: providerSpy, debugEnabled: true)
    }

    @Test("Should set string value")
    func testSetString() {
        let key = "key"
        let value = "value"

        sut.set(value, using: key)

        #expect(providerSpy.storage[key] as? String == value)
    }

    @Test("Should set integer value")
    func testSetInteger() {
        let key = "key"
        let value = 42

        sut.set(value, using: key)

        #expect(providerSpy.storage[key] as? Int == value)
    }

    @Test("Should set boolean value")
    func testSetBoolean() {
        let key = "key"
        let value = true

        sut.set(value, using: key)

        #expect(providerSpy.storage[key] as? Bool == value)
    }

    @Test("Should set dictionary value")
    func testSetDictionary() {
        let key = "key"
        let value = ["name": "John", "age": "30"]

        sut.set(value, using: key)

        #expect(providerSpy.storage[key] as? [String: String] == value)
    }

    @Test("Should get multiple keys independently")
    func testMultipleKeysIndependently() {
        let key1 = "key1"
        let key2 = "key2"
        let value1 = "value1"
        let value2 = "value2"
        sut.set(value1, using: key1)
        sut.set(value2, using: key2)

        let retrieved1: String? = sut.get(using: key1)
        let retrieved2: String? = sut.get(using: key2)

        #expect(retrieved1 == value1)
        #expect(retrieved2 == value2)
    }

    @Test("Should return nil when getting non-existent key")
    func testGetNonExistentKey() {
        let retrieved: String? = sut.get(using: "nonExistentKey")

        #expect(retrieved == nil)
    }

    @Test("Should update existing value")
    func testUpdateValue() {
        let key = "key"
        let initialValue = "initial"
        let updatedValue = "updated"

        sut.set(initialValue, using: key)
        sut.update(updatedValue, using: key)

        #expect(providerSpy.storage[key] as? String == updatedValue)
    }

    @Test("Should delete value")
    func testDeleteValue() {
        let key = "key"
        let value = "value"

        sut.set(value, using: key)
        sut.delete(using: key)

        #expect(providerSpy.storage[key] as? String == nil)
    }

    @Test("Should overwrite value when setting same key twice")
    func testOverwriteValue() {
        let key = "overwriteKey"
        let firstValue = "first"
        let secondValue = "second"

        sut.set(firstValue, using: key)
        sut.set(secondValue, using: key)

        #expect(providerSpy.storage[key] as? String == secondValue)
    }
}
