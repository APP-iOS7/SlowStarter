import Foundation
import Supabase

public final class StorageManager {
    private var client: SupabaseClient
    private var storage: SupabaseStorageClient
    
    init(client: SupabaseClient) {
        self.client = client
        self.storage = client.storage
    }
    
    // MARK: - Bucket 관리
    
    /// 새로운 버킷을 생성합니다.
    /// - Parameters:
    ///   - name: 버킷 이름
    ///   - types: 허용할 파일 타입
    ///   - isPublic: 버킷 공개 여부 (기본값: false)
    ///   - fileSize: 최대 파일 크기 (기본값: "10248576")
    func createBucket(name: String, types: [StorageType], isPublic: Bool = false, fileSize: String = "10248576") async throws {
        let mimeTypes = types.map { $0.mimeType }
        
        do {
            try await storage.createBucket(name, options: BucketOptions(
                public: isPublic,
                fileSizeLimit: fileSize,
                allowedMimeTypes: mimeTypes
            ))
        } catch {
            throw StorageManagerError.creationBucketFailed(error.localizedDescription)
        }
    }
    
    /// 특정 이름의 버킷 정보를 가져옵니다.
    /// - Parameter name: 버킷 이름
    /// - Returns: Bucket 객체
    func getBucket(name: String) async throws -> Bucket {
        do {
            let bucket = try await storage.getBucket(name)
            return bucket
        } catch {
            throw StorageManagerError.getBucketFailed(error.localizedDescription)
        }
    }
    
    /// 특정 이름의 버킷을 삭제합니다.
    /// - Parameter name: 버킷 이름
    func deleteBucket(name: String) async throws {
        do {
            try await storage.deleteBucket(name)
        } catch {
            throw StorageManagerError.deleteBucketFailed(error.localizedDescription)
        }
    }
    
    /// 특정 이름의 버킷을 비웁니다.
    /// - Parameter name: 버킷 이름
    func emptyBucket(name: String) async throws {
        do {
            try await storage.emptyBucket(name)
        } catch {
            throw StorageManagerError.emptyBucketFailed(error.localizedDescription)
        }
    }
    
    // MARK: - 파일 작업
    
    /// 파일을 업로드합니다.
    /// - Parameters:
    ///   - bucket: 버킷 이름
    ///   - filepath: 파일 경로
    ///   - file: 업로드할 데이터
    ///   - cacheControl: 캐시 제어 헤더 (기본값: "3600")
    func uploadFile(bucket: String, filepath: String, file: Data, cacheControl: String = "3600") async throws {
        let fileExtension = URL(fileURLWithPath: filepath).pathExtension.lowercased()
        
        guard let storageType = StorageType(rawValue: fileExtension) else {
            throw StorageManagerError.convertFileTypeFailed("지원하지 않는 파일 확장자입니다.")
        }
        
        let contentType = storageType.mimeType
        
        do {
            try await storage
                .from(bucket)
                .upload(filepath, data: file, options: FileOptions(
                    cacheControl: cacheControl,
                    contentType: contentType,
                    upsert: false
                ))
        } catch {
            throw StorageManagerError.uploadFileFailed(error.localizedDescription)
        }
    }
    
    /// 파일을 다운로드합니다.
    /// - Parameters:
    ///   - bucket: 버킷 이름
    ///   - filePath: 파일 경로
    /// - Returns: 다운로드된 데이터
    func downloadFile(bucket: String, filePath: String) async throws -> Data {
        do {
            let data = try await storage
                .from(bucket)
                .download(path: filePath)
            return data
        } catch {
            throw StorageManagerError.downloadFileFailed(error.localizedDescription)
        }
    }
    
    /// 버킷 내의 모든 파일을 나열합니다.
    /// - Parameters:
    ///   - bucket: 버킷 이름
    ///   - folderPath: 폴더 경로
    ///   - sortBy: 정렬 기준
    ///   - limit: 최대 파일 수 (기본값: 100)
    ///   - offset: 오프셋 (기본값: 0)
    ///   - order: 정렬 순서 ("asc" 또는 "desc", 기본값: "asc")
    /// - Returns: 파일 목록
    func listAllFiles(bucket: String, folderPath: String, sortBy: String, limit: Int = 100, offset: Int = 0, order: String = "asc") async throws -> [FileObject] {
        do {
            let fileList = try await storage
                .from(bucket)
                .list(path: folderPath, options: SearchOptions(
                    limit: limit,
                    offset: offset,
                    sortBy: SortBy(column: sortBy, order: order)
                ))
            return fileList
        } catch {
            throw StorageManagerError.downloadFileFailed(error.localizedDescription)
        }
    }
    
    /// 버킷 내에서 파일을 검색합니다.
    /// - Parameters:
    ///   - bucket: 버킷 이름
    ///   - folderPath: 폴더 경로
    ///   - search: 검색어
    ///   - sortBy: 정렬 기준
    ///   - limit: 최대 파일 수 (기본값: 100)
    ///   - offset: 오프셋 (기본값: 0)
    ///   - order: 정렬 순서 ("asc" 또는 "desc", 기본값: "asc")
    /// - Returns: 검색된 파일 목록
    func searchFiles(bucket: String, folderPath: String, search: String, sortBy: String, limit: Int = 100, offset: Int = 0, order: String = "asc") async throws -> [FileObject] {
        do {
            let fileList = try await storage
                .from(bucket)
                .list(path: folderPath, options: SearchOptions(
                    limit: limit,
                    offset: offset,
                    sortBy: SortBy(column: sortBy, order: order),
                    search: search
                ))
            return fileList
        } catch {
            throw StorageManagerError.downloadFileFailed(error.localizedDescription)
        }
    }
    
    /// 파일을 삭제합니다.
    /// - Parameters:
    ///   - bucket: 버킷 이름
    ///   - filePaths: 삭제할 파일 경로 목록
    func deleteFile(bucket: String, filePaths: [String]) async throws {
        do {
            try await storage
                .from(bucket)
                .remove(paths: filePaths)
        } catch {
            throw StorageManagerError.deleteFileFailed(error.localizedDescription)
        }
    }
    
    /// 서명된 URL을 생성합니다.
    /// - Parameters:
    ///   - bucket: 버킷 이름
    ///   - filePath: 파일 경로
    ///   - expiresIn: URL 만료 시간 (초 단위, 기본값: 60)
    /// - Returns: 생성된 URL
    func createSignedUrl(bucket: String, filePath: String, expiresIn: Int = 60) async throws -> URL {
        do {
            let url = try await storage
                .from(bucket)
                .createSignedURL(path: filePath, expiresIn: expiresIn)
            return url
        } catch {
            throw StorageManagerError.createFileURLFailed(error.localizedDescription)
        }
    }
    
    /// 여러 파일에 대한 서명된 URL을 생성합니다.
    /// - Parameters:
    ///   - bucket: 버킷 이름
    ///   - filePaths: 파일 경로 목록
    ///   - expiresIn: URL 만료 시간 (초 단위, 기본값: 60)
    /// - Returns: 생성된 URL 목록
    func createSignedUrls(bucket: String, filePaths: [String], expiresIn: Int = 60) async throws -> [URL] {
        do {
            let urls = try await storage
                .from(bucket)
                .createSignedURLs(paths: filePaths, expiresIn: expiresIn)
            return urls
        } catch {
            throw StorageManagerError.createFileURLFailed(error.localizedDescription)
        }
    }
    
    /// 공개 URL을 생성합니다.
    /// - Parameters:
    ///   - bucket: 버킷 이름
    ///   - filePath: 파일 경로
    /// - Returns: 생성된 공개 URL
    func createPublicUrl(bucket: String, filePath: String) throws -> URL {
        do {
            let url = try storage
                .from(bucket)
                .getPublicURL(path: filePath)
            return url
        } catch {
            throw StorageManagerError.createFileURLFailed(error.localizedDescription)
        }
    }
}
