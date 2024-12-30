//
//  TestApiResponses.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

enum TestApiResponses {
    static let testListObjectsV2ResponseSinglePageData = resourceData(
        with: "TestListObjectsV2SinglePageResponse",
        ext: "xml"
    )
    
    static let testListObjectsV2ResponseSinglePageString =
        String(
            data: testListObjectsV2ResponseSinglePageData,
            encoding: .utf8
        )!
    
    static let testContinuationToken = "1FCRVspE+wMuYOoqvStty51UgiNi/raUyGTYt1zxpq+4JCPBZXD+/BptrAcf565VX4e4GJrhyTxY="
    
    static let testListObjectsV2ResponseFirstPageData =
        testListObjectsV2ResponseSinglePageString
            .replacing(
                "<Prefix />",
                with: "<Prefix /><NextContinuationToken>1FCRVspE+wMuYOoqvStty51UgiNi/raUyGTYt1zxpq+4JCPBZXD+/BptrAcf565VX4e4GJrhyTxY=</NextContinuationToken>"
            )
            .replacing(
                "<IsTruncated>false</IsTruncated>",
                with: "<IsTruncated>true</IsTruncated>"
            )
            .data(using: .utf8)!
    
    static let testListObjectsV2ResponseMiddlePageData =
        testListObjectsV2ResponseSinglePageString
            .replacing(
                "<Prefix />",
                with: "<Prefix /><ContinuationToken>1FCRVspE+wMuYOoqvStty51UgiNi/raUyGTYt1zxpq+4JCPBZXD+/BptrAcf565VX4e4GJrhyTxY=</ContinuationToken><NextContinuationToken>15iB7hIQEBtrcWVq1ET3nf1+l6Z66F8r/EbpcJOQOtCnKRIOyyHihdnWGX/wbWhRhNZaQIbCfG/SwMc8jdg3fnQ==</NextContinuationToken>"
            )
            .replacing(
                "<IsTruncated>false</IsTruncated>",
                with: "<IsTruncated>true</IsTruncated>"
            )
            .data(using: .utf8)!
    
    static let testListObjectsV2ResponseLastPageData =
        testListObjectsV2ResponseSinglePageString
            .replacing(
                "<Prefix />",
                with: "<Prefix /><ContinuationToken>11nHZUqVKvG/V/aF/lDsCnjS7uLQy8L3uBpB4ntUTgmH2rLVpMRAP0T9MGdC/aB00DIXW3D60jVmo=</ContinuationToken>"
            )
            .data(using: .utf8)!
    
    static let testListObjectsV2SinglePageResult = ListBucketResult(
        name: "test-bucket-name",
        prefix: "",
        continuationToken: nil,
        nextContinuationToken: nil,
        keyCount: 8,
        maxKeys: 20,
        delimiter: "/",
        isTruncated: false,
        contents: [
            ListBucketResult.Contents(
                key: "book.mixu.net-Distributed systems.pdf",
                lastModified: toDate("2022-07-22T11:37:33.000Z"),
                etag: "\"f68aa48f9e79102ccf4fd2796543e400\"",
                size: 1336812,
                storageClass: "STANDARD"
            ),
            ListBucketResult.Contents(
                key: "firewall-blocked-2021-05-10.csv",
                lastModified: toDate("2021-08-11T08:29:30.000Z"),
                etag: "\"d09480784a57d748a52591ca0f50603a-4\"",
                size: 64721115,
                storageClass: "STANDARD"
            ),
            ListBucketResult.Contents(
                key: "firewall-blocked-2021-05-15.csv",
                lastModified: toDate("2021-08-11T08:29:30.000Z"),
                etag: "\"a716c277d0a56ca28c1587ca773bf6fb-4\"",
                size: 64968975,
                storageClass: "STANDARD"
            ),
            ListBucketResult.Contents(
                key: "firewall-blocked-2021-05-20.csv",
                lastModified: toDate("2021-08-11T11:46:32.000Z"),
                etag: "\"d44e56b4bdd2b5081fc8d5d8b04bc1f2-4\"",
                size: 65131037,
                storageClass: "STANDARD"
            )
        ],
        commonPrefixes: [
            ListBucketResult.Prefix(
                prefix: "EmptyFolder/"
            ),
            ListBucketResult.Prefix(
                prefix: "Images/"
            ),
            ListBucketResult.Prefix(
                prefix: "Videos/"
            ),
            ListBucketResult.Prefix(
                prefix: "jdk-master/"
            )
        ]
    )
    
    static let firstPageNextContinuationToken = "1FCRVspE+wMuYOoqvStty51UgiNi/raUyGTYt1zxpq+4JCPBZXD+/BptrAcf565VX4e4GJrhyTxY="
    static let testListObjectsV2FirstPageResult =
        ListBucketResult(
            name: testListObjectsV2SinglePageResult.name,
            prefix: testListObjectsV2SinglePageResult.prefix,
            continuationToken: nil,
            nextContinuationToken: firstPageNextContinuationToken,
            keyCount: testListObjectsV2SinglePageResult.keyCount,
            maxKeys: testListObjectsV2SinglePageResult.maxKeys,
            delimiter: testListObjectsV2SinglePageResult.delimiter,
            isTruncated: true,
            contents: testListObjectsV2SinglePageResult.contents,
            commonPrefixes: testListObjectsV2SinglePageResult.commonPrefixes
        )
    
    static let testListObjectsV2MiddlePageResult =
        ListBucketResult(
            name: testListObjectsV2SinglePageResult.name,
            prefix: testListObjectsV2SinglePageResult.prefix,
            continuationToken: "1FCRVspE+wMuYOoqvStty51UgiNi/raUyGTYt1zxpq+4JCPBZXD+/BptrAcf565VX4e4GJrhyTxY=",
            nextContinuationToken: "15iB7hIQEBtrcWVq1ET3nf1+l6Z66F8r/EbpcJOQOtCnKRIOyyHihdnWGX/wbWhRhNZaQIbCfG/SwMc8jdg3fnQ==",
            keyCount: testListObjectsV2SinglePageResult.keyCount,
            maxKeys: testListObjectsV2SinglePageResult.maxKeys,
            delimiter: testListObjectsV2SinglePageResult.delimiter,
            isTruncated: true,
            contents: testListObjectsV2SinglePageResult.contents,
            commonPrefixes: testListObjectsV2SinglePageResult.commonPrefixes
        )

    static let testListObjectsV2LastPageResult =
        ListBucketResult(
            name: testListObjectsV2SinglePageResult.name,
            prefix: testListObjectsV2SinglePageResult.prefix,
            continuationToken: "11nHZUqVKvG/V/aF/lDsCnjS7uLQy8L3uBpB4ntUTgmH2rLVpMRAP0T9MGdC/aB00DIXW3D60jVmo=",
            nextContinuationToken: nil,
            keyCount: testListObjectsV2SinglePageResult.keyCount,
            maxKeys: testListObjectsV2SinglePageResult.maxKeys,
            delimiter: testListObjectsV2SinglePageResult.delimiter,
            isTruncated: false,
            contents: testListObjectsV2SinglePageResult.contents,
            commonPrefixes: testListObjectsV2SinglePageResult.commonPrefixes
        )
    
    static func toDate(_ string: String) -> Date {
        fileDateFormatter.date(from: string)!
    }
    
    static let fileDateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
    
    struct CannotFindResourceFile: Error {}
    
    private static func resourceData(
        with name: String,
        ext: String
    ) -> Data {
        let bundle = TestHelpers.bundle
        
        let url = bundle.url(
            forResource: name,
            withExtension: ext
        )!
        
        return try! Data(contentsOf: url)
    }
}
