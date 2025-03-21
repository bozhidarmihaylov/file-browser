//
//  TestCase+Extensions.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest

extension XCTestCase {    
    func assertThrowsAsyncError<T>(
        _ expression: @autoclosure () async throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        _ errorHandler: (_ error: Error) -> Void = { _ in }
    ) async {
        do {
            _ = try await expression()
            // expected error to be thrown, but it was not
            let customMessage = message()
            if customMessage.isEmpty {
                XCTFail("Asynchronous call did not throw an error.", file: file, line: line)
            } else {
                XCTFail(customMessage, file: file, line: line)
            }
        } catch {
            errorHandler(error)
        }
    }
    
    var bundle: Bundle { TestHelpers.bundle }
}
