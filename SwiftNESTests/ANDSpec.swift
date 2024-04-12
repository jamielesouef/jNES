//
//  ANDSpec.swift
//  SwiftNESTests
//
//  Created by Jamie Le Souef on 12/4/2024.
//

import XCTest
@testable import SwiftNES

final class ANDSpec: XCTestCase {
  
  var cpu: CPU!
  
  func run(prefill: UInt8, opcode: UInt8, value: UInt8) throws {
    self.cpu = CPU.mock_with_warm_registers(prefill: prefill)
    let program: [UInt8] = [0xA1, 0b0000_1010, opcode, value, 0x00]
    cpu.load(program: program)
    try cpu.run()
  }
  
  func testAND_indirectX() throws {
    try run(prefill: 0b0000_1011, opcode: 0x21, value: 0b0000_0011)
    XCTAssertEqual(cpu.memory.registers.A, 0b0000_1011)
  }
  
  func testAND_zeroPage() throws {
    try run(prefill: 0b00100_1011, opcode: 0x25, value: 0b0001_0010)
    XCTAssertEqual(cpu.memory.registers.A, 0b0000_1001)
  }
  
  func testAND_immediate() throws {
    try run(prefill: 0b0000_1101, opcode: 0x29, value: 0b0001_0010)
    XCTAssertEqual(cpu.memory.registers.A, 0x00)
  }
  
  func testAND_absolute() throws {
    /*
     0b0010_1010
     0b1001_1010
     -----------
     0b0000_1010
     */
    try run(prefill: 0b0010_1010, opcode: 0x2D, value: 0b1001_1010)
    XCTAssertEqual(cpu.memory.registers.A, 0b0000_1000)
  }
  
  func testAND_indirectY() throws {
    try run(prefill: 0b1100_1111, opcode: 0x31, value: 0b0001_0010)
    XCTAssertEqual(cpu.memory.registers.A,0b1100_0010)
  }
  
  func testAND_zeroPageX() throws {
    try run(prefill: 0b0000_1000, opcode: 0x35, value: 0b0001_0110)
    XCTAssertEqual(cpu.memory.registers.A, 0x00)
  }
  
  func testAND_absoluteY() throws {
    
    /*
     0001_1011
     */
    
    try run(prefill: 0b0011_1001, opcode: 0x39, value: 0b0001_1110)
    XCTAssertEqual(cpu.memory.registers.A, 0b0001_1001)
  }
  
  func testAND_absoluteX() throws {
    try run(prefill: 0b0101_1010, opcode: 0x3D, value: 0b1111_1010)
    XCTAssertEqual(cpu.memory.registers.A, 0b0101_1010)
  }
  
  func testAND() throws {
    
  }
  
  //    func testINXWithNoValue() throws {
  //      let program: [UInt8] = [0xE8, 0x00]
  //      cpu.load(program: program)
  //      try cpu.run()
  //      XCTAssertEqual(cpu.memory.registers.A, 0x00)
  //      XCTAssertEqual(cpu.memory.registers.X, 0x01)
  //      XCTAssertFalse(cpu.memory.registers.isSet(.zero))
  //      XCTAssertFalse(cpu.memory.registers.isSet(.negative))
  //    }
  //
  //    func testINXWithExistingValue() throws {
  //      let program: [UInt8] = [0xA9, 0x0C, 0xAA, 0xE8, 0x00]
  //      cpu.load(program: program)
  //      try cpu.run()
  //      XCTAssertEqual(cpu.memory.registers.A, 0x0C)
  //      XCTAssertEqual(cpu.memory.registers.X, 0x0D)
  //      XCTAssertFalse(cpu.memory.registers.isSet(.zero))
  //      XCTAssertFalse(cpu.memory.registers.isSet(.negative))
  //    }
  //
  //    func testINXSetsZeroBit() throws {
  //      let program: [UInt8] = [0xA9, 0x00, 0xAA, 0xE8, 0x00]
  //      cpu.load(program: program)
  //      try cpu.run()
  //      XCTAssertEqual(cpu.memory.registers.X, 0x01)
  //      XCTAssertFalse(cpu.memory.registers.isSet(.zero))
  //      XCTAssertFalse(cpu.memory.registers.isSet(.negative))
  //    }
  //
  //    func testINXSetsNegativeBit() throws {
  //      let program: [UInt8] = [0xA9, 0x81, 0xAA, 0xE8, 0x00]
  //      cpu.load(program: program)
  //      try cpu.run()
  //      XCTAssertEqual(cpu.memory.registers.A, 0x81)
  //      XCTAssertEqual(cpu.memory.registers.X, 0x82)
  //      XCTAssertFalse(cpu.memory.registers.isSet(.zero))
  //      XCTAssertTrue(cpu.memory.registers.isSet(.negative))
  //    }
  //
}
