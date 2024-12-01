//
//  LoadingStateSyncerMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import FileBrowser

final class LoadingStateSyncerMock: LoadingStateSyncer {
    func syncedLoadingStates(for entries: [Entry]) async throws -> [Entry] {
        []
    }
}
