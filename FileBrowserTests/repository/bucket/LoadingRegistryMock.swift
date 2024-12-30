//
//  LoadingRegistryMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class LoadingRegistryMock: LoadingRegistry {
    
    private(set) var registerTransferCalls: [Transfer] = []
    
    var registerTransferError: Error? = nil
    func registerTransfer(_ transfer: Transfer) async throws {
        registerTransferCalls.append(transfer)
        
        if let error = registerTransferError {
            throw error
        }
    }
    
    private(set) var unregisterTransferCalls: [Transfer] = []
    
    var unregisterTransferError: Error? = nil
    func unregisterTransfer(_ transfer: Transfer) async throws {
        unregisterTransferCalls.append(transfer)
        
        if let error = unregisterTransferError {
            throw error
        }
    }
    
    private(set) var unregisterTransferByTaskIdCalls: [Int] = []
    
    var unregisterTransferByTaskIdError: Error? = nil
    func unregisterTransfer(taskId: Int) async throws {
        unregisterTransferByTaskIdCalls.append(taskId)
        
        if let error = unregisterTransferByTaskIdError {
            throw error
        }
    }
    
    private(set) var downloadingStateForPathInBucketNameCalls: [(
        relativeFilePath: String,
        bucketName: String
    )] = []
    
    var downloadingStateForPathInBucketNameResult: LoadingState! = nil
    var downloadingStateForPathInBucketNameError: Error? = nil
    func downloadingState(
        for relativeFilePath: String,
        in bucketName: String
    ) async throws -> LoadingState {
        downloadingStateForPathInBucketNameCalls.append((
            relativeFilePath: relativeFilePath,
            bucketName: bucketName
        ))
        
        if let error = downloadingStateForPathInBucketNameError {
            throw error
        }
        
        return downloadingStateForPathInBucketNameResult
    }
    
    private(set) var downloadingStatesForPathsInBucketNameCalls: [(
        relativeFilePaths: [String],
        bucketName: String
    )] = []
    
    var downloadingStatesForPathsInBucketNameResult: [LoadingState]! = nil
    var downloadingStatesForPathsInBucketNameError: Error? = nil
    func downloadingStates(
        for relativeFilePaths: [String],
        in bucketName: String
    ) async throws -> [LoadingState] {
        downloadingStatesForPathsInBucketNameCalls.append((
            relativeFilePaths:relativeFilePaths,
            bucketName: bucketName
        ))
        
        if let error = downloadingStatesForPathsInBucketNameError {
            throw error
        }
        
        return downloadingStatesForPathsInBucketNameResult
    }
}
