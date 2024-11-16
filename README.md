# SwiftTrie

SwiftTrie is a "Swifty" implementation of the [Trie](https://en.wikipedia.org/wiki/Trie) data structure. This code was originally implemented as a class by the [swift-algorithm-club](https://github.com/kodecocodes/swift-algorithm-club). Now it is reimplemented as a value-type struct. It also uses copy-on-write semantics so that it can behave like any other standard Swift Collection. 

## Usage
```swift
var wordList = Trie(from: ["hello", "world", "swift", "trie", "help"])
wordList.contains("hello") // true
wordList.contains("skibidi") // false
wordList.insert("skibidi")
wordList.contains("skibidi") // true
wordList.remove("skibidi")
wordList.contains("skibidi") // false

wordList.findWords(withPrefix: "he") // ["hello", "help"]
```