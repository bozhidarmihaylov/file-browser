//
//  BackgroundSessionEventsCompletionProvider.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation

public protocol BackgroundSessionEventsCompletionProvider {
    var backgroundSessionEventsCompletion: (() -> Void)? { get }
}
