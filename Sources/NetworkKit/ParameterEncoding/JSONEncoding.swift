//
//  JSONEncoding.swift
//  NetworkKit
//
//  Created by Squid Yu on 2022/4/26.
//

import Foundation

public struct JSONEncoding: ParameterEncoding {
    public static var `default`: JSONEncoding { JSONEncoding() }
    
    public func encode(_ urlRequest: URLRequest, parameters: [String: Any]) throws -> URLRequest {
        var request = urlRequest
        let body = try JSONSerialization.data(withJSONObject: parameters, options: [])
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
