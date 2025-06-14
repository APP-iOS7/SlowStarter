//
//  RepeatLeanService.swift
//  SlowStarter
//
//  Created by jdios on 6/14/25.
//

import Foundation
import UIKit

class RepeatLearnService {
    
    static let shared = RepeatLearnService()
    private let supabaseManager = SupabaseDataManager.shared
    
    /// Supabase에서 사용자의 VOD와 과제 정보를 가져와 RepeatLearnData 배열을 생성합니다.
    func fetchAndGenerateRepeatLearnData() async throws -> [RepeatLearnData] {
        // 1. 현재 사용자 정보 가져오기
        guard let currentUser = supabaseManager.getCurrentAuthenticatedUser() else {
            throw LoginManagerError.userNotFound
        }
        let userId = currentUser.userId
        
        // 2. 모든 VOD와 사용자의 모든 과제를 병렬로 가져오기
        async let allVODs = supabaseManager.fetchData(as: VOD.self, select: "*")
        async let userAssignments = supabaseManager.fetchData(
            as: UserAssignment.self,
            select: "*",
            conditionColumn: "user_id",
            conditionValue: userId
        )
        
        let (vods, assignments) = try await (allVODs, userAssignments)
        
        // 3. 과제들을 VOD ID를 키로 하는 딕셔너리로 그룹화하여 조회 성능 향상
        let assignmentsByVodId = Dictionary(grouping: assignments, by: { $0.vodId })
        
        // 4. 각 VOD를 RepeatLearnData로 변환
        // withTaskGroup을 사용하여 여러 VOD를 병렬로 처리합니다.
        let repeatLearnDataList: [RepeatLearnData] = await withTaskGroup(of: RepeatLearnData?.self) { group in
            var results: [RepeatLearnData] = []
            
            for vod in vods {
                group.addTask {
                    // 해당 VOD에 대한 과제 목록 찾기 (없으면 빈 배열)
                    let relatedAssignments = assignmentsByVodId[vod.vodId] ?? []
                    
                    // 제공된 static 메서드를 사용하여 RepeatLearnData 생성
                    return try? await RepeatLearnData.generate(from: vod, userAssignments: relatedAssignments)
                }
            }
            
            // 모든 작업의 결과를 수집
            for await data in group {
                if let validData = data {
                    results.append(validData)
                }
            }
            
            return results
        }
        
        // 최종적으로 생성된 목록을 반환
        return repeatLearnDataList
    }
}

// 사용 예시 (예: ViewModel 내부)
/*
 Task {
 do {
 let myRepeatLearnData = try await RepeatLearnService.shared.fetchAndGenerateRepeatLearnData()
 // self.repeatLearnItems = myRepeatLearnData
 } catch {
 print("학습 데이터 로딩 실패: \(error)")
 }
 }
 */
extension RepeatLearnService {
    
    /// `Assignment` 객체를 Supabase Storage에 업로드하고 `UserAssignment` 모델로 변환합니다.
    private func convertToUserAssignment(from assignment: Assignment, userId: String, vodId: String) async throws -> UserAssignment {
        
        // 1. UIImage를 Data로 변환 (png 형식)
        guard let imageData = assignment.image.pngData() else {
            throw NSError(domain: "ImageConversionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지를 Data로 변환하는데 실패했습니다."])
        }
        
        // 2. Supabase Storage에 업로드할 고유한 파일 경로 생성
        let fileExtension = "png"
        let fileName = "\(UUID().uuidString).\(fileExtension)"
        let filePath = "public/assignments/\(userId)/\(vodId)/\(fileName)"
        let bucketName = "assignments" // 예시 버킷 이름
        
        // 3. 이미지 업로드
        try await supabaseManager.uploadProfileImage(
            bucket: bucketName,
            filepath: filePath,
            file: imageData,
            upsert: false // 새 파일이므로 false
        )
        
        // 4. 업로드된 이미지의 공개 URL 생성
        guard let publicURL = supabaseManager.createPublicImageURL(bucket: bucketName, filePath: filePath) else {
            throw NSError(domain: "URLCreationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "공개 이미지 URL 생성에 실패했습니다."])
        }
        
        // 5. UserAssignment 모델 생성
        let userAssignment = UserAssignment(
            userId: userId,
            lectureId: "", // VOD에 lectureId가 있다면 채워줘야 함
            vodId: vodId,
            imageURL: publicURL.absoluteString,
            description: assignment.memo,
            submittedAt: assignment.date
        )
        
        return userAssignment
    }
}
extension RepeatLearnService {
    
    /// `RepeatLearnData`의 변경사항을 Supabase에 반영합니다.
    /// - Parameters:
    ///   - data: 수정된 RepeatLearnData 객체
    ///   - vodId: 업데이트할 VOD의 고유 ID
    func updateDataFromRepeatLearnData(_ data: RepeatLearnData, forVODId vodId: String) async throws {
        
        guard let currentUser = supabaseManager.getCurrentAuthenticatedUser() else {
            throw LoginManagerError.userNotFound
        }
        let userId = currentUser.userId
        
        // --- 1. VOD 정보 업데이트 ---
        let vodUpdateDetails: [String: Any] = [
            "title": data.lectureTitle,
            "description": data.lectureDescription
        ]
        
        try await supabaseManager.updateUserProfile(userId: vodId, details: vodUpdateDetails)
        
        // --- 2. 과제 정보 업데이트 (Delete-and-Recreate 전략) ---
        
        // 2-1. 기존 과제 모두 삭제
        // DataBaseManager에 `deleteData`를 여러 조건으로 실행하는 기능이 필요할 수 있습니다.
        // 여기서는 `user_id`와 `vod_id`가 일치하는 모든 과제를 삭제한다고 가정합니다.
        // Supabase RLS(Row Level Security)가 user_id를 기반으로 설정되어 있다면, vod_id만으로도 삭제가 가능할 수 있습니다.
        // 여기서는 Supabase Edge Function을 호출하거나, 클라이언트에서 필터링하여 삭제합니다.
        // 편의상, 먼저 기존 과제를 가져와서 삭제할 파일 경로 목록을 만듭니다.
        
        let oldAssignments: [UserAssignment] = try await supabaseManager.fetchData(
            as: UserAssignment.self,
            select: "*",
            conditionColumn: "vod_id", // vodId로 필터링 (user_id는 RLS로 처리되거나 추가 필터 필요)
            conditionValue: vodId
        )
        
        // 기존 이미지 파일 경로 추출 및 DB 레코드 삭제
        if !oldAssignments.isEmpty {
            // Storage에서 이미지 삭제
            // let imagePathsToDelete = oldAssignments.compactMap { URL(string: $0.imageURL ?? "")?.path }
            // await supabaseManager.deleteProfileImage(bucket: "assignments", filePaths: imagePathsToDelete)
            
            // DB에서 레코드 삭제 (주의: vod_id와 user_id 모두 일치하는 것만 삭제해야 함)
            try await supabaseManager.deleteData(as: UserAssignment.self, conditionColumn: "vod_id", conditionValue: vodId)
        }
        
        
        // 2-2. 새로운 과제 목록을 `UserAssignment`로 변환하여 DB에 삽입
        if !data.assignments.isEmpty {
            var newAssignmentsToInsert: [UserAssignment] = []
            for assignment in data.assignments {
                if let newAssignment = try? await convertToUserAssignment(from: assignment, userId: userId, vodId: vodId) {
                    newAssignmentsToInsert.append(newAssignment)
                }
            }
            
            // 변환된 과제 목록을 DB에 한 번에 삽입
            if !newAssignmentsToInsert.isEmpty {
                try await supabaseManager.insertListData(as: UserAssignment.self, data: newAssignmentsToInsert)
            }
        }
    }
    func syncAssignments(for vodId: String, with newAssignments: [Assignment]) async throws {
        let supabaseManager = SupabaseDataManager.shared
        guard let userId = supabaseManager.getCurrentAuthenticatedUser()?.userId else {
            throw LoginManagerError.userNotFound
        }
        
        // 1. 서버에서 해당 VOD의 원본 과제 목록을 가져옵니다.
        let originalUserAssignments: [UserAssignment] = try await supabaseManager.fetchData(
            as: UserAssignment.self,
            select: "*",
            conditionColumn: "vod_id",
            conditionValue: vodId
        ).filter { $0.userId == userId } // RLS가 없다면 수동으로 필터링
        
        // --- 데이터 비교 (Diffing) ---
        let originalMap = Dictionary(uniqueKeysWithValues: originalUserAssignments.map { ($0.id, $0) })
        let newMap = Dictionary(uniqueKeysWithValues: newAssignments.map { ($0.id, $0) })
        
        let originalIds = Set(originalMap.keys)
        let newIds = Set(newMap.keys)
        
        // 2. 삭제된 과제 처리
        let deletedIds = originalIds.subtracting(newIds)
        if !deletedIds.isEmpty {
            // ... (파일 삭제 및 DB 레코드 삭제 로직) ...
            print("삭제할 과제 ID: \(deletedIds)")
        }
        
        // 3. 추가된 과제 처리
        let addedIds = newIds.subtracting(originalIds)
        if !addedIds.isEmpty {
            let assignmentsToAdd = addedIds.compactMap { newMap[$0] }
            // ... (이미지 업로드 및 DB 레코드 추가 로직) ...
            print("추가할 과제: \(assignmentsToAdd.map { $0.memo })")
        }
        
        // 4. 수정된 과제 처리
        let commonIds = newIds.intersection(originalIds)
        if !commonIds.isEmpty {
            // ... (description 필드 등 변경점 감지 및 DB 레코드 업데이트 로직) ...
            print("수정 확인할 과제 ID: \(commonIds)")
        }
    }
    
    /// 사용자의 학습 진도를 서버에 업데이트합니다.
    /// - Parameter progressData: 업데이트할 학습 데이터 배열
    func updateUserProgress(with progressData: [RepeatLearnData]) async throws {
        // 이 함수는 'user_course_history' 같은 테이블에 각 VOD의 'weeklyProgress'를 업데이트합니다.
        // Supabase의 upsert 기능을 사용하면 효율적입니다.
        
        print("--- 학습 진도 업데이트 시도 ---")
        for data in progressData {
            if data.weeklyProgress > 0 {
                print("강의 '\(data.lectureTitle)' (VOD ID: \(data.vodId)) -> 진행도: \(data.weeklyProgress)")
                // let history = UserCourseHistory(userId: ..., vodId: data.vodId, progress: data.weeklyProgress)
                // try await supabaseManager.upsertData(history) // upsert 로직 필요
            }
        }
    }
}
// RepeatLearnService.swift 파일에 추가

extension RepeatLearnService {
    
    
    // ✅ (필수) Assignment -> UserAssignment 변환 (이미지 업로드 포함)
    private func convertToUserAssignment(from assignment: Assignment, userId: String, lectureId: String, vodId: String) async throws -> UserAssignment {
        
        guard let imageData = assignment.image.pngData() else {
            throw NSError(domain: "ImageConversionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "UIImage를 Data로 변환 실패"])
        }
        
        // 고유한 파일 경로 생성
        let fileName = "\(UUID().uuidString).png"
        let filePath = "public/assignments/\(userId)/\(vodId)/\(fileName)"
        let bucketName = "assignments" // Supabase에 생성된 버킷 이름
        
        // 이미지 업로드 (SupabaseDataManager 사용)
        try await supabaseManager.uploadProfileImage(
            bucket: bucketName,
            filepath: filePath,
            file: imageData,
            upsert: false
        )
        
        // 업로드된 이미지의 공개 URL 생성
        guard let publicURL = supabaseManager.createPublicImageURL(bucket: bucketName, filePath: filePath) else {
            throw NSError(domain: "URLCreationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "공개 URL 생성 실패"])
        }
        
        // UserAssignment 모델 생성하여 반환
        return UserAssignment(
            userId: userId,
            lectureId: lectureId,
            vodId: vodId,
            imageURL: publicURL.absoluteString,
            description: assignment.memo,
            submittedAt: assignment.date
        )
    }
}
// 사용 예시 (예: 저장 버튼을 눌렀을 때)
/*
 let modifiedData: RepeatLearnData = self.currentRepeatLearnData
 let vodId = self.originalVOD.vodId // 원본 VOD ID를 어딘가에 저장해두어야 함
 
 Task {
 do {
 try await RepeatLearnService.shared.updateDataFromRepeatLearnData(modifiedData, forVODId: vodId)
 print("업데이트 성공!")
 } catch {
 print("업데이트 실패: \(error)")
 }
 }
 */
