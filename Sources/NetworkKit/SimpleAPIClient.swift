//
//  SimpleAPIClient.swift
//  NetworkKit
//
//  Created by Squid Yu on 2022/4/26.
//

import Foundation
import Combine

public struct SimpleAPIClient: APIClientSpec {
    public let hostname: String
    
    private(set) var urlSession = URLSession.shared
    
    public init(hostname: String) {
        self.hostname = hostname
    }
    
    public func send<T>(_ r: T) -> AnyPublisher<T.Response, Error> where T : NetworkRequest {
        do {
            let request = try r.asURLRequest(hostname: hostname)
            return urlSession
                .dataTaskPublisher(for: request)
                .tryMap { data, response in
                    if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                        throw handleError(with: response.statusCode)
                    }
                    return try r.responseHandler(data)
                }
                .mapError { handle(error: $0) }
                .eraseToAnyPublisher()
        } catch {
            return Fail(outputType: T.Response.self, failure: error)
                .eraseToAnyPublisher()
        }
    }
}

extension SimpleAPIClient {
    func handleError(with statusCode: Int) -> NetworkRequestError {
        switch statusCode {
        case 400: return .statusCodeVaildationFailed(reason: .badRequest)
        case 401: return .statusCodeVaildationFailed(reason: .unauthorized)
        case 403: return .statusCodeVaildationFailed(reason: .forbidden)
        case 404: return .statusCodeVaildationFailed(reason: .notFound)
        case 500: return .statusCodeVaildationFailed(reason: .serverError)
        default: return .statusCodeVaildationFailed(reason: .unacceptableStatusCode(code: statusCode))
        }
    }
    
    func handle(error: Error) -> NetworkRequestError {
        switch error {
        case let error as NetworkRequestError:
            return error
        case let error as NSError where error.code == NSPropertyListReadCorruptError:
            return .responseSerializationFailed(reason: .jsonSerializationFailed(error: error))
        case is Swift.DecodingError:
            return .responseSerializationFailed(reason: .decodingFailed(error: error))
        default: return .unknownFailed(error: error)
        }
    }
}
