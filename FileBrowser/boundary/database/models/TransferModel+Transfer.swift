//
//  TransferModel+extensions.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation
import CoreData

extension TransferModel {
    func toTransfer() -> Transfer {
        Transfer(
            relativeFilePath: path ?? "",
            bucketName: bucketName ?? "",
            taskIdentifier: Int(taskIdentifier)
        )
    }

    func map(transfer: Transfer) {
        if path != transfer.relativeFilePath {
            path = transfer.relativeFilePath
        }
        if bucketName != transfer.bucketName {
            bucketName = transfer.bucketName
        }
        if taskIdentifier != Int64(transfer.taskIdentifier) {
            taskIdentifier = Int64(transfer.taskIdentifier)
        }
    }
}
