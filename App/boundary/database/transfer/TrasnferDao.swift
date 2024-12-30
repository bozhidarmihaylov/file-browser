//
//  TrasnferDao.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol TransferDao {
    func getAll() async throws -> [Transfer]
    
    func get(taskId: Int) async throws -> Transfer?
    func get(
        path: String,
        bucketName: String
    ) async throws -> Transfer?
    
    @discardableResult
    func insertOrUpdate(transfer: Transfer) async throws -> Transfer
    
    func delete(taskId: Int) async throws -> Transfer?
    func delete(
        path: String,
        bucketName: String
    ) async throws -> Transfer?
    
    func deleteTransfersWithTaskIdsNotIn(
        taskIds: [Int]
    ) async throws -> [Transfer]
}
