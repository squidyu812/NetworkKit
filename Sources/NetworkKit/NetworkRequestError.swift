//
//  NetworkRequestError.swift
//  NetworkKit
//
//  Created by Squid Yu on 2022/4/26.
//

import Foundation

public enum NetworkRequestError: Error {
    public enum StatusCodeVaildationFailureReason {
        case badRequest
        case unauthorized
        case forbidden
        case notFound
        case serverError
        case unacceptableStatusCode(code: Int)
    }
    
    public enum ResponseSerializationFailureReason {
        case jsonSerializationFailed(error: Error)
        case decodingFailed(error: Error)
    }
    
    case invalidURL
    case statusCodeVaildationFailed(reason: StatusCodeVaildationFailureReason)
    case responseSerializationFailed(reason: ResponseSerializationFailureReason)
    case unknownFailed(error: Error)
}
