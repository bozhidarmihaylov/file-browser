//
//  LoadingStateSyncerMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class LoadingStateSyncerMock: LoadingStateSyncer {
    func syncedLoadingStates(for entries: [Entry]) async throws -> [Entry] {
        []
    }
}
