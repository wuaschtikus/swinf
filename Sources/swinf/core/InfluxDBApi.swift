//
//  InfluxDBApi.swift
//  swinf
//
//  Created by Martin Grüner on 01.09.19.
//

import Foundation
import swift_net

public enum InfluxAPI {
    case createDatabase(url: URL, name: String, user: String?, pw: String?)
    case write(url: URL, dbName: String, measure: String, user: String?, pw: String?)
    case query(url: URL, dbName: String, q: String, user: String?, pw: String?)
}

extension InfluxAPI: TargetType {
    
    public var baseURL: URL {
        switch self {
        case .createDatabase(let url, _, _, _): return url
        case .write(let url, _, _, _, _): return url
        case .query(let url, _, _, _, _): return url
            
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
        case .createDatabase(_ , let name, _, _):
            return .requestParameters(parameters: ["q": "CREATE DATABASE \(name)"], encoding: URLEncoding.queryString)
        case .write(_, let dbName, let measure, _, _):
            return .requestCompositeData(bodyData: measure.data(using: .utf8)!, urlParameters: ["db": dbName])
        case .query(_ , let dbName, let query, _, _):
            return .requestParameters(parameters: ["db": dbName, "q": query], encoding: URLEncoding.queryString)
        
        }
    }
    
    public var headers: [String: String]? {
        switch self {
        case .createDatabase(_, _, let user, let pw), .query(_, _, _, let user,let pw), .write(_, _, _, let user, let pw):
            guard let user = user, let pw = pw else { return [:] }
            let authHeader = HTTPHeader.authorization(username: user, password: pw)
            return [authHeader.name: authHeader.value]
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .write, .createDatabase, .query:
            return "{}".data(using: String.Encoding.utf8)!
        }
    }
}
