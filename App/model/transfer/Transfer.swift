//
//  Transfer.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct Transfer: Equatable {
    let relativeFilePath: String
    let bucketName: String
    let taskIdentifier: Int
}

extension Transfer {
    func copy(
        relativeFilePath: String? = nil,
        bucketName: String? = nil,
        taskIdentifier: Int? = nil
    ) -> Transfer {
        Transfer(
            relativeFilePath: relativeFilePath ?? self.relativeFilePath,
            bucketName: bucketName ?? self.bucketName,
            taskIdentifier: taskIdentifier ?? self.taskIdentifier)
    }
}
