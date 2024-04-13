//
//  ANDSpec.swift
//  SwiftNESTests
//
//  Created by Jamie Le Souef on 12/4/2024.
//

import XCTest
@testable import SwiftNES

final class ASLSpec: XCTestCase {
  
  var cpu: CPU!
  
  func run(opcode: UInt8, value: UInt8) throws {
    self.cpu = CPU.mock()
    let program: [UInt8] = [0xA1, 0b0000_1010, opcode, value, 0x00]
    cpu.load(program: program)
    try cpu.run()
  }
  
  func testASL_zeroPage() throws {
    try run(opcode: 0x06, value: 0xFF)
     
    // 0b11000000
    XCTAssertEqual(cpu.memory.registers.A, 0b0101_0010)
    XCTAssertTrue(cpu.memory.registers.isSet(.carry))
    XCTAssertFalse(cpu.memory.registers.isSet(.negative))
  }
  
  func testASL_accumulator() throws {
    self.cpu = CPU.mock()
    let program: [UInt8] = [0xA9, 0b1000_0001, 0x0A, 0x00]
    cpu.load(program: program)
    try cpu.run()
    XCTAssertEqual(cpu.memory.registers.A, 0b0000_0010)
    XCTAssertTrue(cpu.memory.registers.isSet(.carry))
    XCTAssertFalse(cpu.memory.registers.isSet(.negative))
    
  }
  
  func testASL_accumulator_alt() throws {
    self.cpu = CPU.mock()
    let program: [UInt8] = [0xA9, 0b0100_1001, 0x0A, 0x00]
    cpu.load(program: program)
    try cpu.run()
    XCTAssertEqual(cpu.memory.registers.A, 0b1001_0010)
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
    XCTAssertTrue(cpu.memory.registers.isSet(.negative))
    
  }
  
  func testASL_absolute() throws {
    // 0b0101_0000
    try run(opcode: 0x0E, value: 0xA1)
    XCTAssertEqual(cpu.memory.registers.A, 0b0101_0010)
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
    
  }
  
  func testASL_zeroPageX() throws {
    try run(opcode: 0x16, value: 0x03)
    XCTAssertEqual(cpu.memory.registers.A, 0x14)
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
    
  }
  
  func testASL_absoluteX() throws {
    try run(opcode: 0x1E, value: 0xCC)
    XCTAssertEqual(cpu.memory.registers.A, 0x14)
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
    
  }
  
}
