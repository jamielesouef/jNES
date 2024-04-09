//
//  LDA.swift
//  SwiftNESTests
//
//  Created by Jamie Le Souef on 9/4/2024.
//

import XCTest
@testable import SwiftNES

final class INXSpec: XCTestCase {
  
  var cpu: CPU!
  
  override func setUpWithError() throws {
    self.cpu = CPU()
  }
  
  func testINXWithNoValue() throws {
    let program: [UInt8] = [0xE8, 0x00]
    cpu.load(program: program)
    try cpu.run()
    XCTAssertEqual(cpu.registers.A, 0x00)
    XCTAssertEqual(cpu.registers.X, 0x01)
    XCTAssertFalse(cpu.registers.isSet(.zero))
    XCTAssertFalse(cpu.registers.isSet(.negative))
  }
  
  func testINXWithExistingValue() throws {
    let program: [UInt8] = [0xA9, 0x0C, 0xAA, 0xE8, 0x00]
    cpu.load(program: program)
    try cpu.run()
    XCTAssertEqual(cpu.registers.A, 0x0C)
    XCTAssertEqual(cpu.registers.X, 0x0D)
    XCTAssertFalse(cpu.registers.isSet(.zero))
    XCTAssertFalse(cpu.registers.isSet(.negative))
  }
  
  func testINXSetsZeroBit() throws {
    let program: [UInt8] = [0xA9, 0x00, 0xAA, 0xE8, 0x00]
    cpu.load(program: program)
    try cpu.run()
    XCTAssertEqual(cpu.registers.X, 0x01)
    XCTAssertFalse(cpu.registers.isSet(.zero))
    XCTAssertFalse(cpu.registers.isSet(.negative))
  }
  
  func testINXSetsNegativeBit() throws {
    let program: [UInt8] = [0xA9, 0x81, 0xAA, 0xE8, 0x00]
    cpu.load(program: program)
    try cpu.run()
    XCTAssertEqual(cpu.registers.A, 0x81)
    XCTAssertEqual(cpu.registers.X, 0x82)
    XCTAssertFalse(cpu.registers.isSet(.zero))
    XCTAssertTrue(cpu.registers.isSet(.negative))
  }
  
}
