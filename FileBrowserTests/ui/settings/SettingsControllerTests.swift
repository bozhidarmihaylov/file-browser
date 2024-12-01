//
//  SettingsControllerTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation

//protocol FileBrowserController {
//    func cellCount() -> Int
//    func cellVm(at indexPath: IndexPath) -> EntryCellVm
//    func cellAccessoryVm(at indexpath: IndexPath) -> AccessoryVm
//    
//    func onInit()
//    func onDeinit()
//    func onViewLoaded()
//    func onViewAppeared()
//    
//    func onRightButtonItemTap()
//    
//    func onCellTap(at indexPath: IndexPath)
//    func onCellAccessoryTap(at indexPath: IndexPath)
//    
//    func shouldHighlightRow(at indexPath: IndexPath) -> Bool
//    
//    func willDisplayCell(at indexPath: IndexPath)
//}
//init(
//    navigator: SettingsNavigator,
//    configStore: ApiConfigStore = ApiConfigStoreImpl.shared,
//    regionLoader: BucketRegionLoader = BucketRegionLoaderImpl.shared,
//    hudPresenter: HudPresenter = HudPresenterImpl()
//) {

import XCTest
@testable import FileBrowser

final class SettingsControllerTests: TestCase {
    
    
    
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
