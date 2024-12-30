//
//  ApiBucketRepositoryImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct ApiBucketRepositoryImpl: BucketRepository {
    init<S: AsyncSequence>(
        apiConfigProvider: ApiConfigProvider = ApiConfigStoreImpl.shared,
        folderContentLoader: FolderContentLoader = FolderContentLoaderImpl(),
        fileDownloader: FileDownloader = FileDownloaderImpl.shared,
        apiEntryPageSequenceFactory: @escaping (String, Int, ApiConfigProvider, FolderContentLoader) -> S = ApiEntryPageSequence.init,
        anyAsyncSequenceFactory: @escaping (inout S) -> AnyAsyncSequence<[Entry]> = AnyAsyncSequence<[Entry]>.init
    ) where S.Element == [Entry] {
        self.apiConfigProvider = apiConfigProvider
        self.folderContentLoader = folderContentLoader
        self.fileDownloader = fileDownloader
        self.sequenceFactory = { path, pageSize in
            var sequence = apiEntryPageSequenceFactory(path, pageSize, apiConfigProvider, folderContentLoader)
            return anyAsyncSequenceFactory(&sequence)
        }
    }
    
    private let apiConfigProvider: ApiConfigProvider
    private let folderContentLoader: FolderContentLoader
    private let fileDownloader: FileDownloader
    private let sequenceFactory: (String, Int) -> AnyAsyncSequence<[Entry]>
    
    func getContent(path: String) -> AnyAsyncSequence<[Entry]> {
        sequenceFactory(path, Copy.pageSize)
    }
    
    func downloadFile(path: String) async throws -> Entry {
        guard let config = apiConfigProvider.config else {
            throw BucketRepositoryError.noConfig
        }
        
        return try await fileDownloader.downloadFile(
            path: path,
            config: config
        )
    }
    
    private enum Copy {
        static let pageSize = 20
    }
}
