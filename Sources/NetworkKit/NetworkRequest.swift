//
//  NetworkRequest.swift
//  NetworkKit
//
//  Created by Squid Yu on 2022/4/26.
//

import Foundation

public typealias JSONObject = Any
public typealias IgnoredJSONResult = Void

public enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
}

public protocol NetworkRequest {
    associatedtype Response
    var responseHandler: (Data) throws -> Response { get }

    var endpoint: String { get }
    
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
    var encoding: ParameterEncoding { get }
}

public extension NetworkRequest {
    var method: HTTPMethod {
        return .get
    }
    
    var headers: [String: String]? {
        return nil
    }
    
    var parameters: [String: Any]? {
        return nil
    }
    
    var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
}

public extension NetworkRequest {
    func asURLRequest(hostname: String) throws -> URLRequest {
        guard var urlComponets = URLComponents(string: hostname) else { throw NetworkRequestError.invalidURL }
        urlComponets.path = urlComponets.path + endpoint
        
        guard let url = urlComponets.url else { throw NetworkRequestError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        guard let parameters = parameters else { return request }
        return try encoding.encode(request, parameters: parameters)
    }
}

// MARK: - Response Handler

public extension NetworkRequest where Response == JSONObject {
    var responseHandler: (Data) throws -> Response { return jsonObjectResponseHandler }
}

private func jsonObjectResponseHandler(_ data: Data) throws -> JSONObject {
    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
    return jsonObject
}

public extension NetworkRequest where Response == IgnoredJSONResult {
    var responseHandler: (Data) throws -> Response { return ignoredJSONResultResponseHandler }
}

private func ignoredJSONResultResponseHandler(_ data: Data) throws -> IgnoredJSONResult {
    let _ = try JSONSerialization.jsonObject(with: data, options: [])
    return ()
}

public extension NetworkRequest where Response: Decodable {
    var responseHandler: (Data) throws -> Response { return jsonDecodableResponseHandler }
}

private func jsonDecodableResponseHandler<Response: Decodable>(_ data: Data) throws -> Response {
    let decoder = JSONDecoder()
    let reponse = try decoder.decode(Response.self, from: data)
    return reponse
}
