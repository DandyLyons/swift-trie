//
//  Trie+Codable.swift
//  SwiftDSA
//
//  Created by Daniel Lyons on 2024-10-21.
//


extension Trie: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let array = try container.decode([String].self)
        
        self.init(from: array)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.words)
    }
}
