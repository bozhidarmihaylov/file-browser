//
//  FileBrowserCellVmFactoryImplTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class FileBrowserCellVmFactoryImplTests: XCTestCase {
    
    func testCreateVm_folder_folderIcon() {
        let sut = createSut()
        
        let vm = sut.createVm(entry: Copy.folder)
        
        XCTAssertEqual(vm.iconName, Copy.folderIconName)
    }
    
    func testCreateVm_called_textIsEntryName() {
        for entry in Copy.allCasesEntries {
            let sut = createSut()
            
            let vm = sut.createVm(entry: entry)
            
            XCTAssertEqual(vm.text, entry.name)
        }
    }
    
    func testCreateVm_folder_chevronImageAccessory() {
        let sut = createSut()
        
        let vm = sut.createVm(entry: Copy.folder)
        
        XCTAssertEqual(vm.accessoryVm, Copy.chevronImageAccessoryVm)
    }
    
    func testCreateVm_notLoadedFile_arrowDownCircleDottedImageButtonAccessory() {
        let sut = createSut()
        
        let vm = sut.createVm(entry: Copy.notLoadedFile)
        
        XCTAssertEqual(vm.accessoryVm, Copy.arrowDownCircleDottedImageButtonAccessoryVm)
    }
    
    func testCreateVm_loadedingFile_spinnerAccessory() {
        let sut = createSut()
        
        let vm = sut.createVm(entry: Copy.loadingFile)
        
        XCTAssertEqual(vm.accessoryVm, Copy.spinnerAccessoryVm)
    }
    
    func testCreateVm_loadedFile_arrowClockwiseCircleImageButtonAccessory() {
        let sut = createSut()
        
        let vm = sut.createVm(entry: Copy.loadedFile)
        
        XCTAssertEqual(vm.accessoryVm, Copy.arrowClockwiseCircleImageButtonAccessoryVm)
    }
    
    func testCreateVm_called_vmsCreated() {
        let sut = createSut()
        
        let vms = sut.createVm(entries: Copy.allCasesEntries)
        
        XCTAssertEqual(vms, Copy.allCellVms)
    }

    // MARK: Helper methods
    
    private func createSut() -> FileBrowserCellVmFactoryImpl {
        FileBrowserCellVmFactoryImpl()
    }
    
    private enum Copy {
        static let folder = Entry.folderMock

        static let notLoadedFile = Entry.fileMock
        static let loadingFile = notLoadedFile.copy(
            loadingState: .loading
        )
        static let loadedFile = notLoadedFile.copy(
            loadingState: .loaded
        )
        
        static let allCasesEntries = [
            folder,
            notLoadedFile,
            loadingFile,
            loadedFile
        ]
        
        static let fileIconName = "doc"
        static let folderIconName = "folder"
        
        static let chevronImageAccessoryVm = AccessoryVm.image(systemName: "chevron.forward")
        static let arrowDownCircleDottedImageButtonAccessoryVm = AccessoryVm.imageButton(systemName: "arrow.down.circle.dotted")
        static let spinnerAccessoryVm = AccessoryVm.spinner
        static let arrowClockwiseCircleImageButtonAccessoryVm = AccessoryVm.imageButton(systemName: "arrow.clockwise.circle")
        
        static let allCellVms = [
            EntryCellVm(
                iconName: "folder",
                text: "name2",
                accessoryVm: .image(systemName: "chevron.forward"),
                isSelectable: true
            ), EntryCellVm(
                iconName: "doc",
                text: "name1.ext1",
                accessoryVm: .imageButton(
                    systemName: "arrow.down.circle.dotted"
                ),
                isSelectable: false
            ), EntryCellVm(
                iconName: "doc",
                text: "name1.ext1",
                accessoryVm: .spinner,
                isSelectable: false
            ), EntryCellVm(
                iconName: "doc",
                text: "name1.ext1",
                accessoryVm: .imageButton(
                    systemName: "arrow.clockwise.circle"
                ),
                isSelectable: true
            )
        ]
    }
}
