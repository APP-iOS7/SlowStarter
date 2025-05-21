import Foundation

protocol StorageManagerProtocol {
    func createBucket(name: String, types: [StorageType], isPublic: Bool, fileSize: String) async throws
    func deleteBucket(name: String) async throws
    func emptyBucket(name: String) async throws
    
    func uploadFile(bucket: String, filepath: String, file: Data, cacheControl: String) async throws
    func downloadFile(bucket: String, filePath: String) async throws -> Data
    func deleteFile(bucket: String, filePaths: [String]) async throws
    func createSignedUrl(bucket: String, filePath: String, expiresIn: Int) async throws -> URL
    func createSignedUrls(bucket: String, filePaths: [String], expiresIn: Int) async throws -> [URL]
    func createPublicUrl(bucket: String, filePath: String) throws -> URL
}
