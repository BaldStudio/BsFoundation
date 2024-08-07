//
//  MachOTests.swift
//  BsFoundationTests
//
//  Created by crzorz on 2022/10/17.
//  Copyright © 2022 BaldStudio. All rights reserved.
//

@testable import BsFoundation

class MachOTests: XCTestCase {
    func testFetch() {
        let data: [MachOData] = loadMachOData(segment: .test, section: .test)
        XCTAssertTrue(data.count == 1)
        XCTAssertTrue(data.first!.name == "test")
    }
}

// c的结构体转成swift
struct MachOData: MachODataConvertible {
    typealias RawType = MachOTestData

    let name: String

    static func convert(_ t: RawType) -> Self {
        Self(name: String(cString: t.name))
    }
}

extension MachOSegment {
    public static let test = MachOSegment(name: MACH_O_TEST_SEG)
}

extension MachOSection {
    public static let test = MachOSection(name: MACH_O_TEST_SECT)
}
