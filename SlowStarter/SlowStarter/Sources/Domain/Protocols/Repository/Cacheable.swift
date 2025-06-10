
protocol Cacheable {
    associatedtype Key: Hashable
    associatedtype Value
    
    func set(_ value: Value, for key: Key) async
    func get(for key: Key) async -> Value?
    func remove(for key: Key) async
    func clear() async
}
