//
//  FileTransferPlacerMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class FileTransferPlacerMock: FileTransferPlacer {
    private(set) var placeTransferCalls: [(
        transfer: Transfer,
        temporaryUrl: URL
    )] = []
    
    var placeTransferError: Error? = nil
    func placeTransfer(
        _ transfer: Transfer,
        from temporaryUrl: URL
    ) throws {
        placeTransferCalls.append((
            transfer: transfer,
            temporaryUrl: temporaryUrl
        ))
        
        if let error = placeTransferError {
            throw error
        }
    }
}
