//
//  CurrentDateProviderImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct CurrentDateProviderImpl: CurrentDateProvider {
    var currentDate: Date { Date() }
}
