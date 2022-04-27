//
//  APIClientSpec.swift
//  NetworkKit
//
//  Created by Squid Yu on 2022/4/26.
//

import Foundation
import Combine

public protocol APIClientSpec {
    var hostname: String { get }
    
    func send<T>(_ r: T) -> AnyPublisher<T.Response, Error> where T : NetworkRequest
}
