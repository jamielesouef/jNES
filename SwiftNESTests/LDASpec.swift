//
//  LDASpec.swift
//  SwiftNESTests
//
//  Created by Jamie Le Souef on 9/4/2024.
//

import XCTest
@testable import SwiftNES

final class LDASpec: XCTestCase {

  var cpu: CPU!
  
  override func setUpWithError() throws {
    self.cpu = CPU()
  }
  // MARK: LDA
  func testLDA() throws {
    let program: [UInt8] = [0xA9, 0x0C, 0x00]
    cpu.load(program: program)
    try cpu.run()
    XCTAssertEqual(cpu.memory.registers.A, 0x0C)
    XCTAssertFalse(cpu.memory.registers.isSet(.zero))
    XCTAssertFalse(cpu.memory.registers.isSet(.negative))
  }
  
  func testLDASetsZeroBit() throws {
    let program: [UInt8] = [0xA9, 0x00, 0x00]
    cpu.load(program: program)
    try cpu.run()
    XCTAssertEqual(cpu.memory.registers.X, 0x00)
    XCTAssertTrue(cpu.memory.registers.isSet(.zero))
    XCTAssertFalse(cpu.memory.registers.isSet(.negative))
  }
  
  func testLDASetsNegativeBit() throws {
    let program: [UInt8] = [0xA9, 0x81, 0x00]
    cpu.load(program: program)
    try cpu.run()
    XCTAssertEqual(cpu.memory.registers.A, 0x81)
    XCTAssertFalse(cpu.memory.registers.isSet(.zero))
    XCTAssertTrue(cpu.memory.registers.isSet(.negative))
  }
}
