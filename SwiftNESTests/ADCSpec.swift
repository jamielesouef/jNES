//
//  ADCSpec.swift
//  SwiftNESTests
//
//  Created by Jamie Le Souef on 11/4/2024.
//

import XCTest
@testable import SwiftNES

final class ADCSpec: XCTestCase {
  
  var cpu: CPU!
  
  override func setUpWithError() throws {
    self.cpu = CPU.mock()
  }
  
  func testADC_indirectX() throws {
    let program: [UInt8] = [0xA9, 0x00, 0x61, 0x0F, 0x00]
    cpu.load(program: program)
    try cpu.run()
    XCTAssertEqual(cpu.memory.registers.A, 0x6F)
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
  }
  
  func testADC_zeroPage() throws {
    let program: [UInt8] = [0xA9, 0x0A, 0x65, 0x1A, 0x00]
    cpu.load(program: program)
    try cpu.run()
    XCTAssertEqual(cpu.memory.registers.A, 0x57)
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
  }
  
  func testADC_immediate() throws {
    let program: [UInt8] = [0xA9, 0x0A, 0x69, 0x0A, 0x00]
    cpu.load(program: program)
    try cpu.run()
    XCTAssertEqual(cpu.memory.registers.A, 0x14)
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
  }
  
  func testADC_absolute() throws {
    let program: [UInt8] = [0xA9, 0x0A, 0x6D, 0x23, 0x00]
    cpu.load(program: program)
    try cpu.run()
    XCTAssertEqual(cpu.memory.registers.A, 0x48)
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
  }
  
  func testADC_indirectY() throws {
    let program: [UInt8] = [0xA9, 0x0A, 0x71, 0x0A, 0x00]
    cpu.load(program: program)
    try cpu.run()
    XCTAssertEqual(cpu.memory.registers.A, 0x33)
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
  }
  
  func testADC_zeroPageX() throws {
    let program: [UInt8] = [0xA9, 0x0A, 0x75, 0x0A, 0x00]
    cpu.load(program: program)
    try cpu.run()
    XCTAssertEqual(cpu.memory.registers.A, 0x72)
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
  }
  
  func testADC_absoluteY() throws {
    let program: [UInt8] = [0xA9, 0x0A, 0x79, 0x12, 0x00]
    cpu.load(program: program)
    try cpu.run()
    XCTAssertEqual(cpu.memory.registers.A, 0xB3)
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
  }
  
  func testADC_absoluteX() throws {
    let program: [UInt8] = [0xA9, 0x0A, 0x7D, 0xFA, 0x00]
    cpu.load(program: program)
    try cpu.run()
    XCTAssertEqual(cpu.memory.registers.A, 0x9B)
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
  }
  
  func testADC_Carry() throws {
    let program: [UInt8] = [0xA9, 0x0A, 0x69, 0xFF, 0x00]
    cpu.load(program: program)
    try cpu.run()
    XCTAssertEqual(cpu.memory.registers.A, 0x09)
    XCTAssertTrue(cpu.memory.registers.isSet(.carry))
  }
}
