//
//  SettingsControllerTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation

import XCTest
@testable import App

final class SettingsControllerTests: XCTestCase {
    
    
    
    // MARK: Helper methods

    private func createSut() -> (
        SettingsController,
        SettingsNavigatorMock,
        ApiConfigStoreMock,
        BucketRegionLoaderMock,
        HudPresenterMock
    ) {
        let navigatorMock = SettingsNavigatorMock()
        let configStoreMock = ApiConfigStoreMock()
        let regionLoaderMock = BucketRegionLoaderMock()
        let hudPresenterMock = HudPresenterMock()
        
        let sut = SettingsControllerImpl(
            navigator: navigatorMock,
            configStore: configStoreMock,
            regionLoader: regionLoaderMock,
            hudPresenter: hudPresenterMock
        )
        
        return (
            sut,
            navigatorMock,
            configStoreMock,
            regionLoaderMock,
            hudPresenterMock
        )
    }
}
