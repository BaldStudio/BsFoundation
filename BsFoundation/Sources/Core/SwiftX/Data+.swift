//
//  Data+.swift
//  BsFoundation
//
//  Created by Runze Chang on 2024/5/16.
//  Copyright © 2024 BaldStudio. All rights reserved.
//

public typealias Byte = UInt8
public typealias Bytes = [Byte]

public extension Data {
    var bytes: Bytes {
        Bytes(self)
    }
    
    mutating func append<E: Numeric>(_ value: E) {
        Swift.withUnsafeBytes(of: value) { append(contentsOf: $0) }
    }
        
    var asHexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
    
    var asString: String {
        String(data: self, encoding: .utf8) ?? .empty
    }
}
