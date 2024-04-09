//
//  RegisteresSpec.swift
//  SwiftNESTests
//
//  Created by Jamie Le Souef on 9/4/2024.
//

import XCTest
@testable import SwiftNES

extension Registers.StatusFlag {
  static let all: [Registers.StatusFlag] = [.carry, .zero, .interrupt, .brk, .overflow, .negative]
}

final class RegisteresSpec: XCTestCase {
  
  var registers: Registers!
  let statusInitValue: UInt8 = 0x20
  
  override func setUpWithError() throws {
    registers = Registers()
  }
  
  func testBreakFlagIsSetOnInit() throws {
    XCTAssertEqual(registers.p, 1 << 5)
  }
  
  func testFlags() throws {
    Registers.StatusFlag.all.forEach { flag in
      XCTAssertEqual(registers.p, statusInitValue)
      registers.set(flag)
      XCTAssertTrue(registers.p & flag.mask != 0)
      registers.unset(flag)
      XCTAssertEqual(registers.p, statusInitValue)
    }
  }
  
  func testSetMultipleFlags() throws {
    let expected: UInt8 = 0xA3
    XCTAssertEqual(registers.p, statusInitValue)
    registers.set(.carry)
    registers.set(.zero)
    registers.set(.negative)
    //0110_0011
    XCTAssertEqual(registers.p, expected)
    
    registers.unset(.carry)
    XCTAssertEqual(registers.p, 0xA2)
    registers.unset(.zero)
    XCTAssertEqual(registers.p, 0xA0)
    registers.unset(.negative)
    XCTAssertEqual(registers.p, statusInitValue)
  }
  
  func testFlagsIsSet() {
    Registers.StatusFlag.all.forEach { flag in
      registers.set(flag)
      XCTAssertTrue(registers.isSet(flag))
    }
  }
}
