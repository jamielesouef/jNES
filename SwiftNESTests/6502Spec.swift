//
//  6502Spec.swift
//  SwiftNESTests
//
//  Created by Jamie Le Souef on 9/4/2024.
//

import XCTest
@testable import SwiftNES

final class _502Spec: XCTestCase {
  
  var cpu: CPU!
  
  override func setUpWithError() throws {
    self.cpu = CPU()
  }
  // MARK: LDA
  func testLDA() throws {
    let program: [UInt8] = [0xA9, 0x0C, 0x00]
    cpu.interpret(program: program)
    XCTAssertEqual(cpu.registers.A, 0x0C)
    XCTAssertFalse(cpu.registers.isSet(.zero))
    XCTAssertFalse(cpu.registers.isSet(.negative))
  }
  
  func testLDASetsZeroBit() throws {
    let program: [UInt8] = [0xA9, 0x00, 0x00]
    cpu.interpret(program: program)
    XCTAssertEqual(cpu.registers.X, 0x00)
    XCTAssertTrue(cpu.registers.isSet(.zero))
    XCTAssertFalse(cpu.registers.isSet(.negative))
  }
  
  func testLDASetsNegativeBit() throws {
    let program: [UInt8] = [0xA9, 0x81, 0x00]
    cpu.interpret(program: program)
    XCTAssertEqual(cpu.registers.A, 0x81)
    XCTAssertFalse(cpu.registers.isSet(.zero))
    XCTAssertTrue(cpu.registers.isSet(.negative))
  }
  
  // MARK: TAX
  func testTAX() throws {
    let program: [UInt8] = [0xA9, 0x0C, 0xAA, 0x00]
    cpu.interpret(program: program)
    XCTAssertEqual(cpu.registers.A, 0x0C)
    XCTAssertEqual(cpu.registers.X, 0x0C)
    XCTAssertFalse(cpu.registers.isSet(.zero))
    XCTAssertFalse(cpu.registers.isSet(.negative))
  }
  
  func testTAXSetsZeroBit() throws {
    let program: [UInt8] = [0xA9, 0x00, 0xAA, 0x00]
    cpu.interpret(program: program)
    XCTAssertEqual(cpu.registers.X, 0x00)
    XCTAssertTrue(cpu.registers.isSet(.zero))
    XCTAssertFalse(cpu.registers.isSet(.negative))
  }
  
  func testTAXSetsNegativeBit() throws {
    let program: [UInt8] = [0xA9, 0x81, 0xAA, 0x00]
    cpu.interpret(program: program)
    XCTAssertEqual(cpu.registers.A, 0x81)
    XCTAssertEqual(cpu.registers.X, 0x81)
    XCTAssertFalse(cpu.registers.isSet(.zero))
    XCTAssertTrue(cpu.registers.isSet(.negative))
  }
  
}
