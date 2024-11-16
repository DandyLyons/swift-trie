import Foundation
@testable import SwiftTrie
import Testing

@Suite struct TrieTests {
    
    @Test func _init() {
        let trie = Trie()
        #expect(trie.count == 0)
    }
    
    @Test func _initFromArray() {
        let array = ["One", "Two", "Three"]
        let trie = Trie(from: array)
        #expect(trie.count == array.count)
        for string in array {
            #expect(trie.contains(word: string) == true)
        }
    }
    
    @Test func insert() {
        var trie = Trie()
        trie.insert(word: "cute")
        trie.insert(word: "cutie")
        trie.insert(word: "fred")
        #expect(trie.contains(word: "cute") == true)
        #expect(trie.contains(word: "cut") == false)
        trie.insert(word: "cut")
        #expect(trie.contains(word: "cut") == true)
        #expect(trie.count == 4)
    }
    
    /// Tests the remove method
    @Test func remove() {
        var trie = Trie()
        trie.insert(word: "cute")
        trie.insert(word: "cut")
        #expect(trie.count == 2)
        trie.remove(word: "cute")
        #expect(trie.contains(word: "cut") == true)
        #expect(trie.contains(word: "cute") == false)
        #expect(trie.count == 1)
    }
    
    /// Tests the words property
    @Test func words() {
        var trie = Trie()
        var words = trie.words
        #expect(words.count == 0)
        trie.insert(word: "foobar")
        words = trie.words
        #expect(words[0] == "foobar")
        #expect(words.count == 1)
    }
    
    /// Tests whether word prefixes are properly found and returned.
    @Test func findWordsWithPrefix() {
        var trie = Trie()
        trie.insert(word: "test")
        trie.insert(word: "another")
        trie.insert(word: "exam")
        let wordsAll = trie.findWords(withPrefix: "")
        #expect(wordsAll.sorted() == ["another", "exam", "test"])
        let words = trie.findWords(withPrefix: "ex")
        #expect(words == ["exam"])
        trie.insert(word: "examination")
        let words2 = trie.findWords(withPrefix: "exam")
        #expect(words2 == ["exam", "examination"])
        let noWords = trie.findWords(withPrefix: "tee")
        #expect(noWords == [])
        let unicodeWord = "😬😎"
        trie.insert(word: unicodeWord)
        let wordsUnicode = trie.findWords(withPrefix: "😬")
        #expect(wordsUnicode == [unicodeWord])
        trie.insert(word: "Team")
        let wordsUpperCase = trie.findWords(withPrefix: "Te")
        #expect(wordsUpperCase.sorted() == ["team", "test"])
    }
    
    /// Tests whether word prefixes are properly detected on a boolean contains() check.
    @Test func testContainsWordMatchPrefix() {
        var trie = Trie()
        trie.insert(word: "test")
        trie.insert(word: "another")
        trie.insert(word: "exam")
        let wordsAll = trie.contains(word: "", matchPrefix: true)
        withKnownIssue {
            #expect(wordsAll == true)
        }
        let words = trie.contains(word: "ex", matchPrefix: true)
        #expect(words == true)
        trie.insert(word: "examination")
        let words2 = trie.contains(word: "exam", matchPrefix: true)
        #expect(words2 == true)
        let noWords = trie.contains(word: "tee", matchPrefix: true)
        #expect(noWords == false)
        let unicodeWord = "😬😎"
        trie.insert(word: unicodeWord)
        let wordsUnicode = trie.contains(word: "😬", matchPrefix: true)
        #expect(wordsUnicode == true)
        trie.insert(word: "Team")
        let wordsUpperCase = trie.contains(word: "Te", matchPrefix: true)
        #expect(wordsUpperCase == true)
    }
    
    // MARK: Codable
    @Test("Encodable behavior should be equivalent to [String]")
    func codableConformance() throws {
        let array = ["One", "Two", "Three"]
            .map { $0.lowercased() } // Trie will always lowercase strings upon insertion
        let trieBefore = Trie(from: array)
        let encoder = JSONEncoder()
        
        let arrayData = try encoder.encode(array)
        guard let arrayJSONString = String(data: arrayData, encoding: .utf8) else {
            Issue.record(); return
        }
        
        let trieData = try encoder.encode(trieBefore)
        guard let trieJSONString = String(data: trieData, encoding: .utf8) else {
            Issue.record(); return
        }
        
        let decoder = JSONDecoder()
        let trieAfter = try decoder.decode(Trie.self, from: trieData)
        #expect(trieBefore == trieAfter)
    }
    
    @Test func equatableConformance() {
        let array = ["One", "Two", "Three"]
            .map { $0.lowercased() } // Trie will always lowercase strings upon insertion
        var trie1 = Trie(from: array)
        var trie2 = Trie(from: array)
        #expect(trie1 == trie2)
        trie1.insert(word: "Four")
        #expect(trie1 != trie2)
        trie2.insert(word: "four")
        #expect(trie1 == trie2)
    }
    
    @Test func copyOnWrite() {
        let array = ["One", "Two", "Three"]
            .map { $0.lowercased() } // Trie will always lowercase strings upon insertion
        var trie1 = Trie(from: array)
        var trie2 = trie1
        trie1.insert(word: "Four")
        #expect(trie2.count != 4)
        #expect(trie2.contains(word: "four") != true)
        
        var trie3 = trie1
        trie1.remove(word: "four")
        #expect(trie3.contains(word: "four") == true)
    }
}
