//
//  ApiBucketRepositoryImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct ApiBucketRepositoryImpl: BucketRepository {
    init(
        apiConfigProvider: ApiConfigProvider = ApiConfigStoreImpl.shared,
        folderContentLoader: FolderContentLoader = FolderContentLoaderImpl(),
        fileDownloader: FileDownloader = FileDownloaderImpl.shared
    ) {
        self.apiConfigProvider = apiConfigProvider
        self.folderContentLoader = folderContentLoader
        self.fileDownloader = fileDownloader
    }
    
    private let apiConfigProvider: ApiConfigProvider
    private let folderContentLoader: FolderContentLoader
    private let fileDownloader: FileDownloader
    
    func getContent(path: String) -> AnyAsyncSequence<[Entry]> {
        var sequence = ApiEntryPageSequence(
            path: path,
            pageSize: Copy.pageSize
        )
        return AnyAsyncSequence(sequence: &sequence)
    }
    
    func downloadFile(path: String) async throws -> Entry {
        guard let config = apiConfigProvider.config else {
            throw NSError()
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
