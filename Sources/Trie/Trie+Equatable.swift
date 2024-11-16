//
//  Trie+Equatable.swift
//  SwiftDSA
//
//  Created by Daniel Lyons on 2024-10-21.
//

extension Trie: Equatable {
    public static func == (lhs: Trie, rhs: Trie) -> Bool {
        guard lhs.count == rhs.count else { return false }
        let lhsSet = Set(lhs.words)
        let rhsSet = Set(rhs.words)
        return lhsSet == rhsSet
    }
}
