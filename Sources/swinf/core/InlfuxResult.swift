//
//  InlfuxResult.swift
//  swinf
//
//  Created by Martin Grüner on 01.09.19.
//

import Foundation

// MARK: - InlfuxResult
public struct InfluxResult: Codable {
    let results: [Result]
}

// MARK: - Result
public struct Result: Codable {
    let statementID: Int
    let series: [Series]
    
    enum CodingKeys: String, CodingKey {
        case statementID = "statement_id"
        case series
    }
}

// MARK: - Series
public struct Series: Codable {
    let name: String
    let columns: [String]
    let values: [[Value]]
}

public enum Value: Codable {
    case double(Double)
    case string(String)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(Value.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Value"))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .double(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}
