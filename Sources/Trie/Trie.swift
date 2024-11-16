//
//  Trie.swift
//  Trie
//
//  Created by Rick Zaccone on 2016-12-12.
//  Copyright © 2016 Rick Zaccone. All rights reserved.
//

import Foundation

/// A trie data structure containing words.  Each node is a single
/// character of a word.
public struct Trie {
    typealias Node = TrieNode<Character>
    /// The number of words in the trie
    public var count: Int {
        return wordCount
    }
    /// Is the trie empty?
    public var isEmpty: Bool {
        return wordCount == 0
    }
    /// All words currently in the trie, unsorted
    ///
    /// All words will be lowercased.
    public var words: [String] {
        return wordsInSubtrie(rootNode: root, partialWord: "")
    }
    fileprivate var root: Node
    fileprivate var wordCount: Int
    
    /// Creates an empty trie.
    public init() {
        root = Node()
        wordCount = 0
    }
    
    /// Convert an array of strings into a trie
    public init(from array: [String]) {
        self.init()
        for string in array {
            self.insert(word: string)
        }
    }
    
    /// Use this function internally to implement copy on write.
    private mutating func copyNodesIfNecessary() {
        guard !isKnownUniquelyReferenced(&root) else {
            return // skip copy if already unique
        }
        let wordsArray = self.words
        root = TrieNode(value: nil, parentNode: nil)
        for word in wordsArray {
            self.insert(word: word)
        }
    }
}

// MARK: - Adds methods: insert, remove, contains
extension Trie {
    /// Inserts a word into the trie.  If the word is already present,
    /// there is no change.
    ///
    /// - Parameter word: the word to be inserted.
    public mutating func insert(word: String) {
        copyNodesIfNecessary()
        guard !word.isEmpty else {
            return
        }
        var currentNode = root
        for character in word.lowercased() {
            if let childNode = currentNode.children[character] {
                currentNode = childNode
            } else {
                currentNode.add(value: character)
                currentNode = currentNode.children[character]!
            }
        }
        // Word already present?
        guard !currentNode.isTerminating else {
            return
        }
        wordCount += 1
        currentNode.isTerminating = true
    }
    
    /// Determines whether a word is in the trie.
    ///
    /// - Parameters:
    ///   - word: the word to check for
    ///   - matchPrefix: whether the search word should match
    ///   if it is only a prefix of other nodes in the trie
    /// - Returns: true if the word is present, false otherwise.
    public func contains(word: String, matchPrefix: Bool = false) -> Bool {
        guard !word.isEmpty else {
            return false
        }
        var currentNode = root
        for character in word.lowercased() {
            guard let childNode = currentNode.children[character] else {
                return false
            }
            currentNode = childNode
        }
        return matchPrefix || currentNode.isTerminating
    }
    
    /// Attempts to walk to the last node of a word.  The
    /// search will fail if the word is not present. Doesn't
    /// check if the node is terminating
    ///
    /// - Parameter word: the word in question
    /// - Returns: the node where the search ended, nil if the
    /// search failed.
    private func findLastNodeOf(word: String) -> Node? {
        var currentNode = root
        for character in word.lowercased() {
            guard let childNode = currentNode.children[character] else {
                return nil
            }
            currentNode = childNode
        }
        return currentNode
    }
    
    /// Attempts to walk to the terminating node of a word.  The
    /// search will fail if the word is not present.
    ///
    /// - Parameter word: the word in question
    /// - Returns: the node where the search ended, nil if the
    /// search failed.
    private func findTerminalNodeOf(word: String) -> Node? {
        if let lastNode = findLastNodeOf(word: word) {
            return lastNode.isTerminating ? lastNode : nil
        }
        return nil
    }
    
    /// Deletes a word from the trie by starting with the last letter
    /// and moving back, deleting nodes until either a non-leaf or a
    /// terminating node is found.
    ///
    /// - Parameter terminalNode: the node representing the last node
    /// of a word
    fileprivate func deleteNodesForWordEndingWith(terminalNode: Node) {
        // ⚠️ This method is technically mutating and therefore we should copyNodesIfNecessary()
        // However, we are already using copyNodesIfNecessary() in remove(word:) so it shouldn't be necessary here.
        var lastNode = terminalNode
        var character = lastNode.value
        while lastNode.isLeaf, let parentNode = lastNode.parentNode {
            lastNode = parentNode
            lastNode.children[character!] = nil
            character = lastNode.value
            if lastNode.isTerminating {
                break
            }
        }
    }
    
    /// Removes a word from the trie.  If the word is not present or
    /// it is empty, just ignore it.  If the last node is a leaf,
    /// delete that node and higher nodes that are leaves until a
    /// terminating node or non-leaf is found.  If the last node of
    /// the word has more children, the word is part of other words.
    /// Mark the last node as non-terminating.
    ///
    /// - Parameter word: the word to be removed
    public mutating func remove(word: String) {
        copyNodesIfNecessary()
        guard !word.isEmpty else {
            return
        }
        guard let terminalNode = findTerminalNodeOf(word: word) else {
            return
        }
        if terminalNode.isLeaf {
            deleteNodesForWordEndingWith(terminalNode: terminalNode)
        } else {
            terminalNode.isTerminating = false
        }
        wordCount -= 1
    }
    
    /// Returns an array of words in a subtrie of the trie, unsorted
    ///
    /// - Parameters:
    ///   - rootNode: the root node of the subtrie
    ///   - partialWord: the letters collected by traversing to this node
    /// - Returns: the words in the subtrie, unsorted
    fileprivate func wordsInSubtrie(rootNode: Node, partialWord: String) -> [String] {
        var subtrieWords = [String]()
        var previousLetters = partialWord
        if let value = rootNode.value {
            previousLetters.append(value)
        }
        if rootNode.isTerminating {
            subtrieWords.append(previousLetters)
        }
        for childNode in rootNode.children.values {
            let childWords = wordsInSubtrie(rootNode: childNode, partialWord: previousLetters)
            subtrieWords += childWords
        }
        return subtrieWords
    }
    
    /// Returns an array of words in a subtrie of the trie that start
    /// with given prefix
    ///
    /// - Parameters:
    ///   - prefix: the letters for word prefix
    /// - Returns: the words in the subtrie that start with prefix
    public func findWords(withPrefix prefix: String) -> [String] {
        var words = [String]()
        let prefixLowerCased = prefix.lowercased()
        if let lastNode = findLastNodeOf(word: prefixLowerCased) {
            if lastNode.isTerminating {
                words.append(prefixLowerCased)
            }
            for childNode in lastNode.children.values {
                let childWords = wordsInSubtrie(rootNode: childNode, partialWord: prefixLowerCased)
                words += childWords
            }
        }
        return words
    }
}
