//
//  FileBrowserPresenterImplTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class FileBrowserPresenterImplTests: XCTestCase {
    func testDidAppendEntries_called_cellVmsAdded() {
        let (sut, _, _) = createSut()
        
        sut.didAppendEntries(Copy.entries)
        
        XCTAssertEqual(sut.cellVms, Copy.cellVms)
    }
    
    func testDidSyncLoadingStates_called_cellVmsUpdated() {
        let (sut, _, _) = createSut(
            hasUpdatedContent: true
        )
        
        sut.didAppendEntries(Copy.entries)
        sut.didSyncLoadingStates()
        
        XCTAssertEqual(sut.cellVms, Copy.updatedCellVms)
    }
    
    func testDidUpdateLoadingStateAtIndex_called_cellVmAtIndexUpdated() {
        let (sut, folderContentMock, _) = createSut()
        
        sut.didAppendEntries(Copy.entries)
        let prevCellVms = sut.cellVms
        
        folderContentMock.entryAtIndexClosure = { Copy.updatedEntries[$0] }
        sut.didUpdateLoadingState(at: 2)
        
        XCTAssertEqual(prevCellVms, Copy.cellVms)
        XCTAssertEqual(sut.cellVms, Copy.updatedCellVms)
    }
    
    func testCellCount_synced_entriesCountReturned() {
        let (sut, _, _) = createSut()
        sut.didAppendEntries(Copy.entries)
        
        let result = sut.cellCount()
        
        XCTAssertEqual(result, Copy.entries.count)
    }
    
    func testCellCount_notSynced_zeroReturned() {
        let (sut, _, _) = createSut()
        
        let result = sut.cellCount()
        
        XCTAssertEqual(result, 0)
    }
    
    func testCellVmAtIndexPath_synced_cellVmAtIndexReturned() {
        let (sut, _, _) = createSut()
        sut.didAppendEntries(Copy.entries)
        
        let indexPath = IndexPath(row: 1, section: 0)
        let result = sut.cellVm(at: indexPath)
        
        XCTAssertEqual(result, Copy.cellVms[1])
    }
    
    // MARK: Helper methods
    
    private func createSut(
        hasUpdatedContent: Bool = false
    ) -> (
        FileBrowserPresenterImpl,
        FolderContentMock,
        FileBrowserCellVmFactoryMock
    ) {
        let folderContentMock = FolderContentMock()
        folderContentMock.numberOfEntriesResult = Copy.entries.count
        folderContentMock.entryAtIndexClosure = {
            (hasUpdatedContent ? Copy.updatedEntries : Copy.entries)[$0]
        }
        
        let fileBrowserCellVmFactoryMock = FileBrowserCellVmFactoryMock()
        
        let sut = FileBrowserPresenterImpl(
            folderContent: folderContentMock,
            cellVmFactory: FileBrowserCellVmFactoryImpl()
        )
        
        return (
            sut,
            folderContentMock,
            fileBrowserCellVmFactoryMock
        )
    }
    
    private enum Copy {
        static let entries = [Entry].mock
        
        static let updatedEntries = entries.enumerated()
            .map { offset, element in
                offset == entries.count - 1
                    ? element.copy(
                        loadingState: .loaded
                    )
                    : element
            }
        
        static let cellVms = [
            EntryCellVm(
                iconName: "doc",
                text: "name1.ext1",
                accessoryVm: .imageButton(
                    systemName: "arrow.down.circle.dotted"
                ),
                isSelectable: false
            ), EntryCellVm(
                iconName: "folder",
                text: "name2",
                accessoryVm: .image(
                    systemName: "chevron.forward"
                ),
                isSelectable: true
            ), EntryCellVm(
                iconName: "doc",
                text: "name3.ext2",
                accessoryVm: .imageButton(
                    systemName: "arrow.down.circle.dotted"
                ),
                isSelectable: false
            )
        ]
        
        static let updatedCellVms = cellVms.enumerated()
            .map { offset, element in
                offset == cellVms.count - 1
                    ? element.copy(
                        accessoryVm: .imageButton(systemName: "arrow.clockwise.circle"),
                        isSelectable: true
                    ) : element
            }
    }
}
