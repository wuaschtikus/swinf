//
//  InfluxDBApi.swift
//  swinf
//
//  Created by Martin Grüner on 01.09.19.
//

import Foundation
import swift_net

public enum InfluxAPI {
    case createDatabase(url: URL, name: String)
    case write(url: URL, dbName: String, measure: String)
    case query(url: URL, dbName: String, q: String)
}

extension InfluxAPI: TargetType {
    
    public var baseURL: URL {
        switch self {
        case .createDatabase(let url, _): return url
        case .write(let url, _, _): return url
        case .query(let url, _, _): return url
            
        }
    }

    public var path: String {
        switch self {
        case .createDatabase: return "/query"
        case .write: return "/write"
        case .query: return "/query?pretty=true"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .write, .createDatabase: return .post
        case .query: return .get
        }
    }

    public var task: Task {
        switch self {
        case .createDatabase(_ , let name):
            return .requestParameters(parameters: ["q": "CREATE DATABASE \(name)"], encoding: URLEncoding.queryString)
        case .write(_, let dbName, let measure):
            return .requestCompositeData(bodyData: measure.data(using: .utf8)!, urlParameters: ["db": dbName])
        case .query(_ , let dbName, let query):
            return .requestParameters(parameters: ["db": dbName, "q": query], encoding: URLEncoding.queryString)
        
        }
    }
    
    public var headers: [String: String]? {
        return [:]
    }
    
    public var sampleData: Data {
        switch self {
        case .write, .createDatabase, .query:
            return "{}".data(using: String.Encoding.utf8)!
        }
    }
}
