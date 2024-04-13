//
//  6502Spec.swift
//  SwiftNESTests
//
//  Created by Jamie Le Souef on 9/4/2024.
//

import XCTest
@testable import SwiftNES

final class _6502Spec: XCTestCase {
  
  var cpu: CPU!
  
  override func setUpWithError() throws {
    self.cpu = CPU.mock()
  }
  
  override func tearDownWithError() throws {
    self.cpu = nil
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
  
}
