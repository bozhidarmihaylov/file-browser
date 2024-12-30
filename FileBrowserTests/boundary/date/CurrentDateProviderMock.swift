//
//  CurrentDateProviderMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class CurrentDateProviderMock: CurrentDateProvider {
    var currentDateResult: Date! = nil
    var currentDate: Date { 
        currentDateResult
    }
}
