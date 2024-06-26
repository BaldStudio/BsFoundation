//
//  NullResetableTests.swift
//  BsFoundationTests
//
//  Created by crzorz on 2022/10/19.
//  Copyright © 2022 BaldStudio. All rights reserved.
//

@testable import BsFoundation

class NullResetableTests: XCTestCase {

    static func defaultText() -> String {
        "0"
    }
        
    @NullResetable(default: "0")
    var testDefaultValue: String!

    @NullResetable(body: defaultText)
    var testBodyValue: String!

    func testDefault() {
        XCTAssertTrue(testDefaultValue == "0")
        
        testDefaultValue = "1"
        XCTAssertTrue(testDefaultValue == "1")
        
        testDefaultValue = nil
        XCTAssertTrue(testDefaultValue == "0")
    }
    
    func testBody() {
        XCTAssertTrue(testBodyValue == "0")
        
        testBodyValue = "1"
        XCTAssertTrue(testBodyValue == "1")
        
        testBodyValue = nil
        XCTAssertTrue(testBodyValue == "0")
    }
}
