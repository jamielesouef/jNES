//
//  RegisteresSpec.swift
//  SwiftNESTests
//
//  Created by Jamie Le Souef on 9/4/2024.
//

import XCTest
@testable import jNES

extension Registers.StatusFlag {
  static let all: [Registers.StatusFlag] = [.carry, .zero, .interrupt, .b, .overflow, .negative]
}

final class RegisteresSpec: XCTestCase {
  
  var registers: Registers!
  let statusInitValue: UInt8 = 0x20
  
  override func setUpWithError() throws {
    registers = Registers()
  }

  func testSettingCarry() throws {
    registers.reset()
    XCTAssertFalse(registers.isSet(.carry))
    registers.set(.carry)
    XCTAssertTrue(registers.isSet(.carry))
    registers.clear(.carry)
    XCTAssertFalse(registers.isSet(.carry))
  }
  
  func testSettingInterupt() throws {
    registers.reset()
    XCTAssertTrue(registers.isSet(.interrupt))
    registers.set(.interrupt)
    XCTAssertTrue(registers.isSet(.interrupt))
    registers.clear(.interrupt)
    XCTAssertFalse(registers.isSet(.interrupt))
  }
  
  func testSettingDecimal() throws {
    registers.reset()
    XCTAssertFalse(registers.isSet(.decimal))
    registers.set(.decimal)
    XCTAssertTrue(registers.isSet(.decimal))
    registers.clear(.decimal)
    XCTAssertFalse(registers.isSet(.decimal))
  }
  
  func testSettingBreak() throws {
    registers.reset()
    XCTAssertFalse(registers.isSet(.b))
    registers.set(.b)
    XCTAssertTrue(registers.isSet(.b))
    registers.clear(.b)
    XCTAssertFalse(registers.isSet(.b))
  }
  
  func testSettingOverflow() throws {
    registers.reset()
    XCTAssertFalse(registers.isSet(.overflow))
    registers.set(.overflow)
    XCTAssertTrue(registers.isSet(.overflow))
    registers.clear(.overflow)
    XCTAssertFalse(registers.isSet(.overflow))
  }
  
  func testSettingNegative() throws {
    registers.reset()
    XCTAssertFalse(registers.isSet(.negative))
    registers.set(.negative)
    XCTAssertTrue(registers.isSet(.negative))
    registers.clear(.negative)
    XCTAssertFalse(registers.isSet(.negative))
  }
  
  func testSetMultipleFlags() throws {
    let expected: UInt8 = 0b1111_1101
    XCTAssertEqual(registers.p, expected)
    registers.set(.carry)
    registers.set(.zero)
    registers.set(.negative)
    //0110_0011
    XCTAssertEqual(registers.p, 0xFF)
    
    registers.clear(.carry)
    XCTAssertEqual(registers.p, 0b1111_1110)
    registers.clear(.zero)
    XCTAssertEqual(registers.p, 0b1111_1100)
    registers.clear(.negative)
    XCTAssertEqual(registers.p, 0b0111_1100)
  }
  
  func testFlagsIsSet() {
    Registers.StatusFlag.all.forEach { flag in
      registers.set(flag)
      XCTAssertTrue(registers.isSet(flag))
    }
  }
}
