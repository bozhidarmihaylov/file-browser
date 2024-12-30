//
//  ApiConfigStoreImplTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class ApiConfigStoreImplTests: XCTestCase {
    // MARK: config::get
    
    func testConfigGet_credentialInKeychainAndBucketInPrefs_returned() {
        let (sut, keychainMock, prefsMock) = createSut()
        
        keychainMock[codable: Copy.credentialKey] = Copy.testCredential
        prefsMock[codable: Copy.bucketKey] = Copy.testBucket
        
        let config = sut.config
        
        XCTAssertEqual(config, Copy.testConfig)
    }
    
    func testConfigGet_credentialInKeychainAndNoBucketInPrefs_nilReturned() {
        let (sut, keychainMock, _) = createSut()
        
        keychainMock[codable: Copy.credentialKey] = Copy.testCredential
        
        let config = sut.config
        
        XCTAssertNil(config)
    }
    
    func testConfigGet_noCredentialInKeychainAndBucketInPrefs_nilReturned() {
        let (sut, _, prefsMock) = createSut()
        
        prefsMock[codable: Copy.bucketKey] = Copy.testBucket
        
        let config = sut.config
        
        XCTAssertNil(config)
    }
    
    func testConfigGet_noCredentialInKeychainAndNoBucketInPrefs_nilReturned() {
        let (sut, _, _) = createSut()
        
        let config = sut.config
        
        XCTAssertNil(config)
    }
    
    // MARK: config::set
    
    func testConfigSet_configNotNil_credentialInKeychain() {
        var (sut, keychainMock, _) = createSut()
                
        sut.config = Copy.testConfig
        
        XCTAssertEqual(keychainMock.subscriptGetCalls.count, 0)
        XCTAssertEqual(keychainMock.subscriptSetCalls.count, 1)
        XCTAssertEqual(keychainMock.subscriptSetCalls.last?.key, Copy.credentialKey)
        XCTAssertEqual(keychainMock.subscriptSetCalls.last?.value as? ApiCredential, Copy.testCredential)
    }
    
    func testConfigSet_configNotNil_bucketInPrefs() {
        var (sut, _, prefsMock) = createSut()
                
        sut.config = Copy.testConfig
        
        XCTAssertEqual(prefsMock.subscriptGetCalls.count, 0)
        XCTAssertEqual(prefsMock.subscriptSetCalls.count, 1)
        XCTAssertEqual(prefsMock.subscriptSetCalls.last?.key, Copy.bucketKey)
        XCTAssertEqual(prefsMock.subscriptSetCalls.last?.value as? Bucket, Copy.testBucket)

    }
    
    func testConfigSet_configNil_credentialRemovedFromKeychain() {
        var (sut, keychainMock, _) = createSut()
                
        sut.config = nil

        XCTAssertEqual(keychainMock.subscriptGetCalls.count, 0)
        XCTAssertEqual(keychainMock.subscriptSetCalls.count, 0)
        XCTAssertEqual(keychainMock.removeCalls.last, Copy.credentialKey)
    }
    
    func testConfigSet_configNil_bucketRemovedFromPrefs() {
        var (sut, _, prefsMock) = createSut()
                
        sut.config = nil

        XCTAssertEqual(prefsMock.subscriptGetCalls.count, 0)
        XCTAssertEqual(prefsMock.subscriptSetCalls.count, 0)
        XCTAssertEqual(prefsMock.removeCalls.last, Copy.bucketKey)
    }
    
    // MARK: Helper methods
    
    private func createSut() -> (
        sut: ApiConfigStoreImpl,
        keychainMock: CodableSubscriptMock,
        preferencesMock: CodableSubscriptMock
    ) {
        let keychainMock = CodableSubscriptMock()
        let preferencesMock = CodableSubscriptMock()
        
        let sut = ApiConfigStoreImpl(
            keychain: keychainMock,
            preferences: preferencesMock
        )
        
        return (
            sut: sut,
            keychainMock: keychainMock,
            preferencesMock: preferencesMock
        )
    }
    
    private enum Copy {
        static let bucketKey = "aws-bucket"
        static let credentialKey = "aws-credential"
        
        static let testCredential = ApiCredential(
            accessKey: "access-key",
            secretKey: "secret-key"
        )
        static let testBucket = Bucket(
            name: "test-bucket",
            region: "test-aws-region"
        )
        static let testConfig = ApiConfig(
            credential: testCredential,
            bucket: testBucket
        )
    }
}
