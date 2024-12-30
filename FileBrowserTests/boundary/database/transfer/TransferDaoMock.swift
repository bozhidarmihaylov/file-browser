//
//  TransferDaoMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class TransferDaoMock: TransferDao {
    var allTransfers: [Transfer] = []
    
    private func _findTransfer(
        taskId: Int
    ) -> (offset: Int, element: Transfer)? {
        allTransfers.enumerated().first { $0.element.taskIdentifier == taskId }
    }
    
    private func _findTransfer(
        path: String,
        bucketName: String
    ) -> (offset: Int, element: Transfer)? {
        allTransfers.enumerated().first {
            $0.element.relativeFilePath == path
                && $0.element.bucketName == bucketName
        }
    }
    
    private(set) var getAllCallsCount: Int = 0
    
    var getAllResult: [Transfer]! = nil
    var getAllError: Error? = nil
    func getAll() async throws -> [Transfer] {
        getAllCallsCount += 1
        
        if let error = getAllError {
            throw error
        }
        
        return getAllResult ?? allTransfers
    }
    
    private(set) var getByTaskIdCalls: [Int] = []
    
    var getByTaskIdResult: Transfer? = nil
    var getByTaskIdError: Error? = nil
    func get(taskId: Int) async throws -> Transfer? {
        getByTaskIdCalls.append(taskId)
        
        if let error = getByTaskIdError {
            throw error
        }
        
        return getByTaskIdResult ?? _findTransfer(taskId: taskId)?.element
    }
    
    private(set) var getByPathAndBucketNameCalls: [(
        path: String,
        bucketName: String
    )] = []
    
    var getByPathAndBucketNameResult: Transfer? = nil
    var getByPathAndBucketNameError: Error? = nil
    func get(path: String, bucketName: String) async throws -> Transfer? {
        getByPathAndBucketNameCalls.append((
            path: path,
            bucketName: bucketName
        ))
        
        if let error = getByPathAndBucketNameError {
            throw error
        }
        
        return getByPathAndBucketNameResult 
            ?? _findTransfer(
                path: path,
                bucketName: bucketName
            )?.element
    }
    
    private(set) var insertOrUpdateTransferCalls: [Transfer] = []
    
    var insertOrUpdateTransferError: Error? = nil
    func insertOrUpdate(transfer: Transfer) async throws -> Transfer {
        insertOrUpdateTransferCalls.append(transfer)
        
        if let error = insertOrUpdateTransferError {
            throw error
        }
        
        let index = _findTransfer(taskId: transfer.taskIdentifier)?.offset
        if let index {
            allTransfers[index] = transfer
        } else {
            allTransfers.append(transfer)
        }
        
        return transfer
    }
    
    private(set) var deleteByTaskIdCalls: [Int] = []
    
    var deleteByTaskIdResult: Transfer? = nil
    var deleteByTaskIdError: Error? = nil
    func delete(taskId: Int) async throws -> Transfer? {
        deleteByTaskIdCalls.append(taskId)
        
        if let error = deleteByTaskIdError {
            throw error
        }
        
        if let result = deleteByTaskIdResult {
            return result
        }
        
        let found = _findTransfer(taskId: taskId)
        if let index = found?.offset {
            allTransfers.remove(at: index)
        }
        
        return found?.element
    }
    
    private(set) var deleteByPathAndBucketNameCalls: [(
        path: String,
        bucketName: String
    )] = []
    
    var deleteByPathAndBucketNameResult: Transfer? = nil
    var deleteByPathAndBucketNameError: Error? = nil
    func delete(path: String, bucketName: String) async throws -> Transfer? {
        deleteByPathAndBucketNameCalls.append((
            path: path,
            bucketName: bucketName
        ))
        
        if let error = deleteByPathAndBucketNameError {
            throw error
        }
        
        if let result = deleteByPathAndBucketNameResult {
            return result
        }
        
        let found = _findTransfer(path: path, bucketName: bucketName)
        if let index = found?.offset {
            allTransfers.remove(at: index)
        }
        
        return found?.element
    }
    
    private(set) var deleteTransfersWithTaskIdsNotInTaskIdsCalls: [[Int]] = []
    
    var deleteTransferswithTaskIdsNotInTaskIdsResult: [Transfer]! = nil
    var deleteTransferswithTaskIdsNotInTaskIdsError: Error? = nil
    func deleteTransfersWithTaskIdsNotIn(taskIds: [Int]) async throws -> [Transfer] {
        deleteTransfersWithTaskIdsNotInTaskIdsCalls.append(taskIds)
        
        if let error = deleteTransferswithTaskIdsNotInTaskIdsError {
            throw error
        }
        
        if let result = deleteTransferswithTaskIdsNotInTaskIdsResult {
            return result
        }
        
        let found = taskIds.compactMap { taskId in
            _findTransfer(
                taskId: taskId
            )
        }
        
        found.forEach { pair in
            allTransfers.remove(at: pair.offset)
        }
        
        return found.map { $0.element }
    }
}
