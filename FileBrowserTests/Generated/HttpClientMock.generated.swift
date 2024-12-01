// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class HttpClientMock: HttpClient {

    //MARK: - data

    var dataForThrowableError: Error?
    var dataForCallsCount = 0
    var dataForCalled: Bool {
        return dataForCallsCount > 0
    }
    var dataForReceivedRequest: URLRequest?
    var dataForReceivedInvocations: [URLRequest] = []
    var dataForReturnValue: (Data, URLResponse)!
    var dataForClosure: ((URLRequest) throws -> (Data, URLResponse))?

    func data(for request: URLRequest) throws -> (Data, URLResponse) {
        if let error = dataForThrowableError {
            throw error
        }
        dataForCallsCount += 1
        dataForReceivedRequest = request
        dataForReceivedInvocations.append(request)
        return try dataForClosure.map({ try $0(request) }) ?? dataForReturnValue
    }

}
