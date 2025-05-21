//
//  SupabaseEnum.swift
//  SlowStarter
//
//  Created by 고요한 on 5/19/25.
//

import Foundation



//MARK: - LoginManager
enum UserUpdateField {
    case email(String)
    case phoneNumber(String)
    case password(String)
}

enum LoginManagerError: Error {
    case userNotFound
    case invalidCredentials
    case emailNotConfirmed
    case userAlreadyExists
    case invalidPhoneNumber
    case rateLimitExceeded
    case missingEmailOrPhone
    case invalidRefreshToken
    case invalidClaim
    case unknownError(message: String)
}

//MARK: - DatabaseManager
enum DatabaseError: Error {
    case invalidURL
    case decodingFailed
    case encodingFailed
    case unauthorized
    case notFound
    case unknown
    case unsupportedType(String)
}

//MARK: - StorageManager
enum StorageManagerError: Error {
    case invalidMimeType
    case creationBucketFailed(String)
    case getBucketFailed(String)
    case deleteBucketFailed(String)
    case emptyBucketFailed(String)
    case convertFileTypeFailed(String)
    case uploadFileFailed(String)
    case downloadFileFailed(String)
    case deleteFileFailed(String)
    case createFileURLFailed(String)
}

enum StorageType: String {
    case png
    case jpg
    case jpeg
    case mp4
    case mov
    
    var mimeType: String {
        switch self {
        case .png: return "image/png"
        case .jpg, .jpeg: return "image/jpeg"
        case .mp4: return "video/mp4"
        case .mov: return "video/quicktime"
        }
    }
}
