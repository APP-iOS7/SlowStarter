import Foundation

protocol DataManagerProtocol {
    // 단순 데이터
    func insertData<T>(_ data: T) -> Bool
    func fetchData<T>(_ type: T.Type) -> [T]?
    func deleteData<T>(_ data: T) -> Bool
    func updateData<T>(_ data: T) -> Bool
    
    // file 데이터
    func insertFile(file: Data) -> Bool
    func fetchFile(filePath: String) -> Data?
    func createSignedURL(filePath: String) -> URL?
}
