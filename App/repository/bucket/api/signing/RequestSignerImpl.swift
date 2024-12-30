//
//  RequestSignerImpl.swift
//  FileBrowser
//
//  Adapted by Bozhidar Mihaylov from https://github.com/2ZGroupSolutionsArticles/Article_EZ001/blob/master/AWSS3DownloadFileDemo/AWSS3DownloadFileDemo/AWSS3RequestHelper.swift
//
//  Created by Eugene Zozulya
//  Copyright © 2018 Sezorus. All rights reserved.
//
// AWS Documentation https://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html

import Foundation
import CommonCrypto

final class RequestSignerImpl {
    static let shared: RequestSigner = RequestSignerImpl()
    
    init(
        currentDateProvider: CurrentDateProvider = CurrentDateProviderImpl()
    ) {
        self.currentDateProvider = currentDateProvider
    }
    
    private let currentDateProvider: CurrentDateProvider
    
    private lazy var shortDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")!
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyyMMdd"
        
        return dateFormatter
    }()
    
    private lazy var longISO8601DateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")!
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        
        return dateFormatter
    }()
    
    private lazy var urlCommonAllowedSet: CharacterSet = .init(charactersIn: "-._~").union(.alphanumerics)
    private lazy var urlPathAllowedSet: CharacterSet = .init(charactersIn: "/").union(urlCommonAllowedSet)
    
    private enum Copy {
        static let SignatureV4Marker = "AWS4"
        static let SignatureV4Algorithm  = "AWS4-HMAC-SHA256"
        static let SignatureV4Terminator = "aws4_request"
        static let ServiceName = "s3"
    }
}

extension RequestSignerImpl: RequestSigner {
    func sign(
        request: inout URLRequest,
        with apiConfig: ApiConfig
    ) {
        let requestDate = currentDateProvider.currentDate
        
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let bodyHashHexString = calculateSHA256String(
            forBody: request.httpBody ?? Data()
        )
        request.addValue(bodyHashHexString, forHTTPHeaderField: "x-amz-content-sha256")
        
        if request.value(forHTTPHeaderField: "Host") == nil,
           let host = request.url?.host
        {
            request.setValue(host, forHTTPHeaderField: "Host")
        }
        
        let dateString = longISO8601DateFormatter.string(from: requestDate)
        request.setValue(dateString, forHTTPHeaderField: "X-Amz-Date")
        
        let authString = calculateAuthorizationHeaderForRequest(
            forRequest: &request,
            bodyHexString: bodyHashHexString,
            requestDate: requestDate,
            apiConfig: apiConfig
        )
        request.setValue(authString, forHTTPHeaderField: "Authorization")
    }
}
 
extension RequestSignerImpl {
    private func calculateAuthorizationHeaderForRequest(
        forRequest request: inout URLRequest,
        bodyHexString bodyString: String,
        requestDate: Date,
        apiConfig: ApiConfig
    ) -> String {
        let dateString = shortDateFormatter.string(from: requestDate)
        
        let region = apiConfig.bucket.region
        let accessKey = apiConfig.credential.accessKey
        
        let signedHeaders = signedHeadersString(
            forRequest: request
        )
        
        let requestScope = "\(dateString)/\(region)/\(Copy.ServiceName)/\(Copy.SignatureV4Terminator)"
        let requestCredentials = "\(accessKey)/\(requestScope)"
        
        let signature = calculateAuthorizationSignature(
            forRequest: &request,
            bodyHexString: bodyString,
            requestScope: requestScope,
            requestDate: requestDate,
            apiConfig: apiConfig
        )

        let authString = "\(Copy.SignatureV4Algorithm) Credential=\(requestCredentials), SignedHeaders=\(signedHeaders), Signature=\(signature)"
        
        return authString
    }
    
    private func calculateAuthorizationSignature(
        forRequest request: inout URLRequest,
        bodyHexString bodyString: String,
        requestScope: String,
        requestDate: Date,
        apiConfig: ApiConfig
    ) -> String {
        let canonicalRequestString = createCanonicalRequestString(
            forRequest: &request,
            bodyHexString: bodyString
        )
        
        let stringToSign = createStringToSign(
            withCanonicalRequestString: canonicalRequestString,
            requestScope: requestScope,
            requestDate: requestDate
        )
        
        let signature = createSignature(
            withStringToSign: stringToSign,
            requestDate: requestDate,
            apiConfig: apiConfig
        )
        
        return signature
    }
    
    private func createCanonicalRequestString(
        forRequest request: inout URLRequest,
        bodyHexString bodyString: String
    ) -> String {
        guard let httpMethod = request.httpMethod, let path = request.url?.path else {
            fatalError("Wrong request!")
        }

        let encodedPath = urlEncodedPath(fromPath: path)
        
        var canonicalRequest = ""
        canonicalRequest += httpMethod
        canonicalRequest += "\n"
        canonicalRequest += encodedPath
        canonicalRequest += "\n"
        
        canonicalRequest += canonicalQueryString(for: &request)
        canonicalRequest += "\n"
        
        canonicalRequest += canonicalHeadersString(forRequest: request)
        canonicalRequest += "\n"
        
        canonicalRequest += signedHeadersString(forRequest: request)
        canonicalRequest += "\n"
        
        canonicalRequest += bodyString
        
        return canonicalRequest
    }
    
    private func createStringToSign(
        withCanonicalRequestString canonicalRequestString: String,
        requestScope: String,
        requestDate: Date
    ) -> String {
        var stringToSign = Copy.SignatureV4Algorithm
        stringToSign += "\n"
        stringToSign += longISO8601DateFormatter.string(from: requestDate)
        stringToSign += "\n"
        stringToSign += requestScope
        stringToSign += "\n"
        
        let canonicalRequestHashString = hashString(fromString: canonicalRequestString)
        let canonicalRequestHashStringHexEncoded = hexEncodedString(fromString: canonicalRequestHashString)
        stringToSign += canonicalRequestHashStringHexEncoded
        
        return stringToSign
    }
    
    private func createSignature(
        withStringToSign stringToSign: String,
        requestDate: Date,
        apiConfig: ApiConfig
    ) -> String {
        let dateString  = shortDateFormatter.string(from: requestDate)
        let secret = apiConfig.credential.secretKey
        let region = apiConfig.bucket.region
        
        let kSecret = Copy.SignatureV4Marker + secret
        let kDate = hmacSHA256(withData: dateString.data(using: .utf8)!, keyData: kSecret.data(using: .utf8)!)
        let kRegion = hmacSHA256(withData: region.data(using: .ascii)!, keyData: kDate)
        let kService = hmacSHA256(withData: Copy.ServiceName.data(using: .utf8)!, keyData: kRegion)
        let kSign = hmacSHA256(withData: Copy.SignatureV4Terminator.data(using: .utf8)!, keyData: kService)
        
        let signatureData = hmacSHA256(withData: stringToSign.data(using: .utf8)!, keyData: kSign)
        let signatureDataString = String(data: signatureData, encoding: .ascii)!
        let signatureString = hexEncodedString(fromString: signatureDataString)
        
        return signatureString
    }
    
    private func calculateSHA256String(forBody bodyData: Data) -> String {
        let contentHash = sha256Hash(fromData: bodyData)
        let contentHashString = String(data: contentHash, encoding: .ascii)!
        let contentHashHexString = hexEncodedString(fromString: contentHashString)

        return contentHashHexString
    }
    
    private func hmacSHA256(
        withData: Data,
        keyData: Data
    ) -> Data {
        let algorithm = kCCHmacAlgSHA256
        let algorithmLength = CC_SHA256_DIGEST_LENGTH
        var retData = Data(count: Int(algorithmLength))
        
        retData.withUnsafeMutableBytes { macBytes in
            withData.withUnsafeBytes { messageBytes in
                keyData.withUnsafeBytes { keyBytes in
                    CCHmac(CCHmacAlgorithm(algorithm),
                           keyBytes.baseAddress, 
                           keyData.count,
                           messageBytes.baseAddress, 
                           withData.count,
                           macBytes.baseAddress
                    )
                }
            }
        }
        
        return retData
    }
    
    private func hash(
        fromData data: Data
    ) -> Data {
        var retHash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &retHash)
        }
        
        return Data(retHash)
    }
    
    private func hashString(fromString: String) -> String {
        guard let stringData = fromString.data(using: .utf8) else {
            return ""
        }
        
        return String(
            data: hash(fromData: stringData),
            encoding: .ascii
        ) ?? ""
    }
    
    private func sha256Hash(fromData data: Data) -> Data {
        var retHash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        let transfromData = data
        
        transfromData.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &retHash)
        }
        
        return Data(retHash)
    }
    
    private func hexEncodedString(fromString: String) -> String {
        fromString.utf16.reduce(into: "") { acc, char in
            acc += String(format: "%02x", char)
        }
    }
    
    private func urlEncodedPath(fromPath: String) -> String {
        guard let newPath = fromPath.removingPercentEncoding else {
            return fromPath
        }
        
        guard let encodedPath = newPath.addingPercentEncoding(withAllowedCharacters: urlPathAllowedSet) else {
            return fromPath
        }
        
        return encodedPath
    }
    
    private func signedHeadersString(forRequest request: URLRequest) -> String {
        guard let headers = request.allHTTPHeaderFields else {
            return ""
        }
        
        var headersString = ""
        
        let sortedHeaders = headers.keys.sorted { $0.lowercased() < $1.lowercased() }
        sortedHeaders.forEach {
            if headersString.count > 0 {
                headersString += ";"
            }
            headersString += $0.lowercased()
        }
        
        return headersString
    }
    
    private func canonicalHeadersString(forRequest request: URLRequest) -> String {
        guard let headers = request.allHTTPHeaderFields else {
            return ""
        }
        
        var headersString = ""
        
        let sortedHeaders = headers.keys.sorted { $0.lowercased() < $1.lowercased() }
        sortedHeaders.forEach {
            headersString += $0.lowercased()
            headersString += ":"
            headersString += headers[$0]!
            headersString += "\n"
    }
    
        let whitespaaceChars = CharacterSet.whitespaces
        let parts = headersString.components(separatedBy: whitespaaceChars)
        let noWhitespace = parts.filter { $0 != "" }
        headersString = noWhitespace.joined(separator: " ")
        
        return headersString
    }
    
    private func canonicalQueryString(for request: inout URLRequest) -> String {
        guard let url = request.url else {
            return ""
        }
        
        let components = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        )
        
        guard var components,
              let queryItems = components.queryItems,
              !queryItems.isEmpty else {
            return ""
        }
        
        let encodedItems = queryItems.map {
            URLQueryItem(
                name: $0.name,
                value: $0.value?
                    .addingPercentEncoding(
                        withAllowedCharacters: urlCommonAllowedSet
                    )
            )
        }
        components.queryItems = encodedItems

        request.url = URL(
            string: components.url!
                .absoluteString
                .replacingOccurrences(of: "%25", with: "%")
        )
        
        components.queryItems = encodedItems
            .sorted { $0.name < $1.name }
        
        let result = components.url?.query?
            .replacingOccurrences(of: "%25", with: "%")
        ?? ""
                
        return result
    }
}
