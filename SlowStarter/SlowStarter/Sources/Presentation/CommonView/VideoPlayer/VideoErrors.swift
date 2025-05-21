//
//  VideoErrors.swift
//  SlowStarter
//
//  Created by jdios on 5/20/25.
//

import Foundation
// 파일 상단 또는 별도의 파일에 추가
enum ThumbnailError: Error, LocalizedError {
    case assetLoadingFailed(Error?)
    case assetNotPlayable
    case imageGenerationFailed(Error)
    case maxRetriesReached
    case unknownError

    var errorDescription: String? {
        switch self {
        case .assetLoadingFailed(let underlyingError):
            return "Failed to load asset properties. \(underlyingError?.localizedDescription ?? "")"
        case .assetNotPlayable:
            return "The video asset is not playable."
        case .imageGenerationFailed(let underlyingError):
            return "Failed to generate thumbnail image. \(underlyingError.localizedDescription)"
        case .maxRetriesReached:
            return "Maximum retries reached for thumbnail generation."
        case .unknownError:
            return "An unknown error occurred during thumbnail generation."
        }
    }
}
