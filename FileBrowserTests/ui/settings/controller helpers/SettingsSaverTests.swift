//
//  SettingsSaverTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class SettingsSaverTests: XCTestCase {
    func testSave_cannotSave_noRegionLoadOrConfigStoredOrOutputCalled() async throws {
        let (sut, configStoreMock, regionLoaderMock, taskLauncherMock, _, input, output) = createSut(
            canSave: false
        )
        
        sut.save()
        try await taskLauncherMock.awaitTasks()
        _ = [input, output]

        XCTAssertEqual(regionLoaderMock.loadRegionWithBucketNameCalls.count, 0)
        XCTAssertEqual(configStoreMock.configSetCalls.count, 0)
        XCTAssertEqual(output.saveDidStartCallCount, 0)
        XCTAssertEqual(output.saveDidFinishWithResultCalls.count, 0)
    }
    
    func testSave_twoConcurrentSaves_oneActualPerformed() async throws {
        let (sut, configStoreMock, regionLoaderMock, taskLauncherMock, _, input, output) = createSut()
        
        sut.save()
        sut.save()
        try await taskLauncherMock.awaitTasks()
        _ = [input, output]

        XCTAssertEqual(regionLoaderMock.loadRegionWithBucketNameCalls.count, 1)
        XCTAssertEqual(configStoreMock.configSetCalls.count, 1)
        XCTAssertEqual(output.saveDidStartCallCount, 1)
        XCTAssertEqual(output.saveDidFinishWithResultCalls.count, 1)
    }
    
    func testSave_canSave_regionLoaded() async throws {
        let (sut, _, regionLoaderMock, taskLauncherMock, _, input, output) = createSut()
        
        sut.save()
        try await taskLauncherMock.awaitTasks()
        _ = [input, output]

        XCTAssertEqual(regionLoaderMock.loadRegionWithBucketNameCalls.count, 1)
        XCTAssertEqual(regionLoaderMock.loadRegionWithBucketNameCalls.last, Copy.config.bucket.name)
    }
    
    func testSave_canSaveAndRegionLoaded_configStored() async throws {
        let (sut, configStoreMock, _, taskLauncherMock, _, input, output) = createSut()
        
        sut.save()
        try await taskLauncherMock.awaitTasks()
        _ = [input, output]

        XCTAssertEqual(configStoreMock.configSetCalls.count, 1)
        XCTAssertEqual(configStoreMock.configSetCalls.last, Copy.config)
    }

    func testSave_canSaveAndRegionLoaded_outputSaveDidFinishCalledWithSuccess() async throws {
        let (sut, _, _, taskLauncherMock, _, input, output) = createSut()
        
        sut.save()
        try await taskLauncherMock.awaitTasks()
        _ = [input, output]

        XCTAssertEqual(output.saveDidStartCallCount, 1)
        XCTAssertEqual(output.saveDidFinishWithResultCalls.count, 1)
        
        if case .failure(let error) = output.saveDidFinishWithResultCalls.last {
            XCTFail("Expected success, got error \(error)")
        }
    }
    
    func testSave_fetchRegionError_configNotStored() async throws {
        let (sut, configStoreMock, _, taskLauncherMock, _, input, output) = createSut(
            hasFetchRegionError: true
        )
        
        sut.save()
        try await taskLauncherMock.awaitTasks()
        _ = [input, output]
        
        XCTAssertEqual(configStoreMock.configSetCalls.count, 0)
    }
    
    func testSave_fetchRegionError_outputSaveDidFinishCalledWithError() async throws {
        let (sut, _, _, taskLauncherMock, _, input, output) = createSut(
            hasFetchRegionError: true
        )
        
        sut.save()
        try await taskLauncherMock.awaitTasks()
        _ = [input, output]
        
        XCTAssertEqual(output.saveDidFinishWithResultCalls.count, 1)
        if case .failure(let error) = output.saveDidFinishWithResultCalls.last {
            XCTAssertEqual(error as NSError, Copy.fetchRegionError)
        } else {
            XCTFail("Expected error, got success")
        }
    }
    
    // MARK: Helper methods
    
    private func createSut(
        canSave: Bool = true,
        hasFetchRegionError: Bool = false
    ) -> (
        SettingsSaverImpl,
        ApiConfigStoreMock,
        BucketRegionLoaderMock,
        TaskLauncherMock,
        MainActorRunnerMock,
        SettingsSaverInputMock,
        SettingsSaverOutputMock
    ) {
        let configStoreMock = ApiConfigStoreMock()
        let regionLoaderMock = BucketRegionLoaderMock()
        if hasFetchRegionError {
            regionLoaderMock.loadRegionWithBucketNameError = Copy.fetchRegionError
        } else {
            regionLoaderMock.loadRegionWithBucketNameResult = Copy.config.bucket.region
        }
        
        let taskLauncherMock = TaskLauncherMock()
        let mainActorRunnerMock = MainActorRunnerMock()
        
        let input = SettingsSaverInputMock()
        input.canSaveResult = canSave
        input.accessKeyResult = Copy.config.credential.accessKey
        input.secretKeyResult = Copy.config.credential.secretKey
        input.bucketNameResult = Copy.config.bucket.name
        
        let output = SettingsSaverOutputMock()
        
        let sut = SettingsSaverImpl(
            configStore: configStoreMock,
            regionLoader: regionLoaderMock,
            taskLauncher: taskLauncherMock,
            mainActorRunner: mainActorRunnerMock
        )
        
        sut.input = input
        sut.output = output
        
        return (
            sut,
            configStoreMock,
            regionLoaderMock,
            taskLauncherMock,
            mainActorRunnerMock,
            input,
            output
        )
    }
    
    private enum Copy {
        static let config = ApiConfig.mock
        
        static let fetchRegionError = NSError(domain: "fetchRegionError", code: 1)
    }
}
