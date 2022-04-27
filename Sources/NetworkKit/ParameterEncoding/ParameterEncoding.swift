//
//  ParameterEncoding.swift
//  NetworkKit
//
//  Created by Squid Yu on 2022/4/26.
//

import Foundation

public protocol ParameterEncoding {
    func encode(_ urlRequest: URLRequest, parameters: [String: Any]) throws -> URLRequest
}
