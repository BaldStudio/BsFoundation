//
//  String+.swift
//  BsFoundation
//
//  Created by Runze Chang on 2024/5/16.
//  Copyright © 2024 BaldStudio. All rights reserved.
//

import CommonCrypto

public extension String {
    static let empty: String = ""

    var isNotEmpty: Bool {
        !isEmpty
    }
    
    var isBlank: Bool {
        trimmed().isEmpty
    }
    
    func trimmed(_ set: CharacterSet = .whitespacesAndNewlines) -> String {
        trimmingCharacters(in: set)
    }
    
    mutating func trim(_ set: CharacterSet = .whitespacesAndNewlines) {
        self = trimmed(set)
    }
}

// MARK: - URL Coding

private let customEncodingCharacters = "-_.!~*;@$,#"
private let allowedCharacterSet: CharacterSet = {
    var charSet = CharacterSet()
    charSet.formUnion(CharacterSet(charactersIn: customEncodingCharacters))
    charSet.formUnion(.letters)
    charSet.formUnion(.alphanumerics)
    return charSet
}()

public extension String {

    /// 生成URL编码字符串
    /// - Parameters:
    ///   - retain: 保留字符
    ///   - unretain: 去除字符
    /// - Returns: 编码异常时，返回原URL字符串
    func urlEncoded(retain: String? = nil, unretain: String? = nil) -> String {
        var charSet = allowedCharacterSet
        if let characters = retain, characters.isNotEmpty, !characters.isBlank {
            charSet.formUnion(CharacterSet(charactersIn: characters))
        }
        if let characters = unretain, characters.isNotEmpty, !characters.isBlank {
            charSet.remove(charactersIn: characters)
        }
        return addingPercentEncoding(withAllowedCharacters: charSet) ?? self
    }

    mutating func urlEncode(retain: String? = nil, unretain: String? = nil) {
        self = urlEncoded(retain: retain, unretain: unretain)
    }
    
    func urlDecoded() -> String {
        removingPercentEncoding ?? self
    }
    
    mutating func urlDecode() {
        self = urlDecoded()
    }
}

// MARK: - Crypto

public extension String {
    var asMD5: String {
        guard let data = data(using: .utf8) else { return self }
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let hash = data.withUnsafeBytes { bytes -> Bytes in
            var hash = Bytes(repeating: 0, count: length)
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return (0..<length).map { String(format: "%02x", hash[$0]) }.joined()
    }
}

// MARK: - Slice

public extension String {
    /** Note: Look me
     目前为了方便使用，返回值都统一为String
     这会牺牲一定的性能，因为存在copy的情况
     如果有较多的高性能需要的场景，可以考虑使用原始类型处理，如Substring等
     */
    
    subscript (i: Int) -> String {
        self[index(startIndex, offsetBy: i)].asString
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: min(bounds.lowerBound, count - 1))
        let end = index(startIndex, offsetBy: min(bounds.upperBound, count - 1))
        if end < start { return "" }
        return self[start..<end].asString
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: min(bounds.lowerBound, count - 1))
        let end = index(startIndex, offsetBy: min(bounds.upperBound, count - 1))
        if end < start { return "" }
        return self[start...end].asString
    }
    
    subscript (bounds: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: min(bounds.lowerBound, count - 1))
        let end = index(endIndex, offsetBy: -1)
        if end < start { return "" }
        return self[start...end].asString
    }
    
    subscript (bounds: PartialRangeThrough<Int>) -> String {
        let end = index(startIndex, offsetBy: min(bounds.upperBound, count - 1))
        if end < startIndex { return "" }
        return self[startIndex...end].asString
    }
    
    subscript (bounds: PartialRangeUpTo<Int>) -> String {
        let end = index(startIndex, offsetBy: min(bounds.upperBound, count - 1))
        if end < startIndex { return "" }
        return self[startIndex..<end].asString
    }
}

// MARK: - Convert

public extension Character {
    var asString: String {
        String(self)
    }
}

public extension Substring {
    var asString: String {
        String(self)
    }
}

public extension CFString {
    var asString: String {
        String(self)
    }
}

public extension String {
    var asInt: Int {
        Int(self) ?? .zero
    }

    var asDouble: Double {
        Double(self) ?? .zero
    }

    var asBool: Bool {
        switch lowercased() {
        case "true", "t", "yes", "y":
            return true
        case "false", "f", "no", "n", "":
            return false
        default:
            if let int = Int(self) {
                return int.asBool
            }
        }
        return false
    }
    
    var asURL: URL? {
        URL(string: self)
    }
    
    var asDictionary: [String: Any] {
        let empty: [String: Any] = [:]
        guard let data = data(using: .utf8) else { return empty }
        guard let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return empty
        }
        return result
    }
    
    var asArray: [Any] {
        let empty: [Any] = []
        guard let data = data(using: .utf8) else { return empty }
        guard let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Any] else {
            return empty
        }
        return result
    }
        
    var asData: Data {
        data(using: .utf8) ?? Data()
    }
}

// MARK: -  Others

public extension String {
    static func * (text: String, count: Int) -> String {
        String(repeating: text, count: count)
    }
}
