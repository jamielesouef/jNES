//
//  6502Spec.swift
//  SwiftNESTests
//
//  Created by Jamie Le Souef on 9/4/2024.
//

import XCTest
@testable import SwiftNES

final class CPUSpec: XCTestCase {
  
  var cpu: CPU!
  
  override func setUpWithError() throws {
    self.cpu = CPU.mock()
  }
  
  override func tearDownWithError() throws {
    self.cpu = nil
  }
  
  func testReadMem16() {
    let expected: UInt16 = 0xC102
    let location: UInt16 = 0x0602
    cpu.memory.writeMem16(at: location, value: expected)
    let result = cpu.memory.readMem16(at: location)
    XCTAssertEqual(result, expected)
  }
  
  func testWriting16BitAddressTomMemoy() {
    
    let address : UInt16 = 0x8000
    let value: UInt16 = 0xA9AA
    cpu.memory.writeMem16(at: address, value: value)
    
    let lo = cpu.memory.readMem(at: address)
    let hi = cpu.memory.readMem(at: address + 1)
    let readBackValue = cpu.memory.readMem16(at: address)
    
    XCTAssertEqual(lo, 0xAA)
    XCTAssertEqual(hi, 0xA9)
    XCTAssertEqual(readBackValue, 0xA9AA)

  }
  
  func testWriting16BitAddressTomStack() {
    let value: UInt16 = 0xA9AA
    cpu.memory.stackPush16(value)
    let result = cpu.memory.stackPop16()
    
    XCTAssertEqual(result, value)
  }
  
  func testWriteToMemoeryWith8BitAddress() {
    
    cpu.memory.writeMem(at: 0x8000, value: 0xA9)
    cpu.memory.writeMem(at: 0x8001, value: 0x05)
    cpu.memory.writeMem(at: 0x8002, value: 0x00)
    
    XCTAssertEqual(cpu.memory.readMem(at: 0x8000), 0xA9)
    XCTAssertEqual(cpu.memory.readMem(at: 0x8001), 0x05)
    XCTAssertEqual(cpu.memory.readMem(at: 0x8002), 0x00)
  }
  
  func testWriteToMemoeryWith16BitAddress() {
    
    cpu.memory.writeMem16(at: 0x8000, value: 0xA9AA)
    cpu.memory.writeMem16(at: 0x8002, value: 0x0501)
    cpu.memory.writeMem16(at: 0x8004, value: 0x0024)
    
    XCTAssertEqual(cpu.memory.readMem16(at: 0x8000), 0xA9AA)
    XCTAssertEqual(cpu.memory.readMem16(at: 0x8002), 0x0501)
    XCTAssertEqual(cpu.memory.readMem16(at: 0x8004), 0x0024)
  }
  
  func testSettingNegativeFlag() {
    cpu.reset()
    cpu.setNegativeFlag(0b1000_0000)
    XCTAssertTrue(cpu.registers.isSet(.negative))
    cpu.registers.clear(.negative)
    XCTAssertFalse(cpu.registers.isSet(.negative))
    
    cpu.reset()
    cpu.setNegativeFlag(0b0100_0000)
    XCTAssertFalse(cpu.registers.isSet(.negative))
  }
  
  func testSettingZeroFlag() {
    cpu.reset()
    cpu.setZeroFlag(0b0000_0000)
    XCTAssertTrue(cpu.registers.isSet(.zero))
    cpu.registers.clear(.zero)
    XCTAssertFalse(cpu.registers.isSet(.zero))
    
    cpu.reset()
    cpu.setZeroFlag(0b0000_0001)
    XCTAssertFalse(cpu.registers.isSet(.zero))
  }
}
