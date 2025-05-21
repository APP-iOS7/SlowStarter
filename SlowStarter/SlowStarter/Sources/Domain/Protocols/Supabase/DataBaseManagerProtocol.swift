//
//  DataBaseManager.swift
//  SlowStarter
//
//  Created by 고요한 on 5/19/25.
//

import Foundation
import Supabase

protocol DataBaseManagerProtocol {
    init(client: SupabaseClient)
    
    // MARK: - Read
    func fetchData<T: Decodable>(as type: T.Type) async throws -> [T]
    func fetchData<T: Decodable>(as type: T.Type, select: String) async throws -> [T]
    func fetchData<T: Decodable>(as type: T.Type, select: String, isOnlyCount: Bool) async throws -> Int
    func fetchData<T1: Decodable, T2: Decodable>(as type: T1.Type, select: String, conditionColumn: String, conditionValue: T2) async throws -> [T1]
    
    // MARK: - Create
    func insertData<T: Encodable>(as type: T.Type, data: T) async throws
    func insertListData<T: Encodable>(as type: T.Type, data: [T]) async throws
    
    // MARK: - Update
    func updateData<T1: Encodable, T2: Encodable>(as type: T1.Type, toUpdateData: [String: Any], conditionColumn: String, conditionValue: T2) async throws
    
    // MARK: - Delete
    func deleteData<T1, T2: Encodable>(as type: T1.Type, conditionColumn: String, conditionValue: T2) async throws
}
