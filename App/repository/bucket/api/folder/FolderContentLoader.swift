//
//  FolderContentLoader.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation
import XMLCoder

struct FolderContentPage {
    let entries: [Entry]
    let nextContinuationToken: String?
}

protocol FolderContentLoader {
    func getContent(
        path: String,
        continuationToken: String?,
        pageSize: Int,
        config: ApiConfig
    ) async throws -> FolderContentPage
}

final class FolderContentLoaderImpl: FolderContentLoader {
    init(
        httpClient: HttpClient = HttpClientImpl.shared,
        requestFactory: FolderContentRequestFactory = FolderContentRequestFactoryImpl(),
        xmlDecoder: XmlDecoder = XmlDecoderImpl.shared,
        loadingStateSyncer: LoadingStateSyncer = LoadingStateSyncerImpl()
    ) {
        self.httpClient = httpClient
        self.requestFactory = requestFactory
        self.xmlDecoder = xmlDecoder
        self.loadingStateSyncer = loadingStateSyncer
    }
    
    private let httpClient: HttpClient
    private let requestFactory: FolderContentRequestFactory
    private let xmlDecoder: XmlDecoder
    private let loadingStateSyncer: LoadingStateSyncer
    
    func getContent(
        path: String,
        continuationToken: String?,
        pageSize: Int,
        config: ApiConfig
    ) async throws -> FolderContentPage {
        let request = requestFactory.createListRequest(
            folderPath: path,
            continuationToken: continuationToken,
            pageSize: pageSize,
            with: config
        )

        let (xmlData, _) = try await httpClient.data(for: request)
        
        let listBucketResult = try xmlDecoder.fromXmlData(xmlData, type: ListBucketResult.self)
        
        let bucketName = config.bucket.name
        
        let entries: [Entry] = [
            listBucketResult.commonPrefixes
                .map { $0.prefix }
                .filter { $0 != path }
                .map {
                    Entry(
                        name: URL(fileURLWithPath: $0).lastPathComponent,
                        path: $0,
                        bucketName: bucketName,
                        isFolder: true,
                        loadingState: .notLoaded
                    )
                },
            try await loadingStateSyncer.syncedLoadingStates(
                for: listBucketResult.contents
                    .filter { $0.key != path }
                    .map {
                        Entry(
                            name: URL(fileURLWithPath: $0.key).lastPathComponent,
                            path: $0.key,
                            bucketName: bucketName,
                            isFolder: false,
                            loadingState: .notLoaded
                        )
                    }
            )
        ]
            .compactMap { $0 }
            .flatMap { $0 }
            .sorted { $0.name < $1.name }
        
        let result = FolderContentPage(
            entries: entries,
            nextContinuationToken: listBucketResult.nextContinuationToken
        )
        
        return result
    }
}
