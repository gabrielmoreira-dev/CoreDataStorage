public protocol KVSDataSourceType {
    func set(_ value: Any?, using key: String)
    func get<T>(using key: String) -> T?
    func update(_ value: Any?, using key: String)
    func delete(using key: String)
}
