//
//  RegisteresSpec.swift
//  SwiftNESTests
//
//  Created by Jamie Le Souef on 9/4/2024.
//

import XCTest
@testable import SwiftNES

final class RegisteresSpec: XCTestCase {
  
  var registers: Registers!
  
  override func setUpWithError() throws {
    registers = Registers()
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testBreakFlagIsSetOnInit() throws {
    XCTAssertEqual(registers.p, 1 << 5)
  }
  
  func testSetNegativeFlag() throws {
    XCTAssertEqual(registers.p, 0b0010_0000)
    registers.set(.negative)
    XCTAssertEqual(registers.p, 0b1010_0000)
    registers.unset(.negative)
    XCTAssertEqual(registers.p, 0b0010_0000)
  }
  
  func testSetCarryFlag() throws {
    XCTAssertEqual(registers.p, 0b0010_0000)
    registers.set(.carry)
    XCTAssertEqual(registers.p, 0b0010_0001)
    registers.unset(.negative)
    XCTAssertEqual(registers.p, 0b0010_0000)
  }
  
  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
