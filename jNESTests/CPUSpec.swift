////
////  6502Spec.swift
////  SwiftNESTests
////
////  Created by Jamie Le Souef on 9/4/2024.
////
//
// import XCTest
// @testable import jNES
//
// final class CPUSpec: XCTestCase {
//
//  var cpu: CPU!
//
//  override func setUpWithError() throws {
//    self.cpu = CPU.mock()
//  }
//
//  override func tearDownWithError() throws {
//    self.cpu = nil
//  }
//
//  func testReadMem16() {
//    let expected: UInt16 = 0xC102
//    let location: UInt16 = 0x0602
//    cpu.writeMem16(at: location, value: expected)
//    let result = cpu.readMem16(at: location)
//    XCTAssertEqual(result, expected)
//  }
//
//  func testWriting16BitAddressTomMemoy() {
//
//    let address : UInt16 = 0x4000
//    let value: UInt16 = 0xA9AA
//    cpu.writeMem16(at: address, value: value)
//
//    let lo = cpu.readMem(at: address)
//    let hi = cpu.readMem(at: address + 1)
//    let readBackValue = cpu.readMem16(at: address)
//
//    XCTAssertEqual(lo, 0xAA)
//    XCTAssertEqual(hi, 0xA9)
//    XCTAssertEqual(readBackValue, 0xA9AA)
//
//  }
//
//  func testWriting16BitAddressTomStack() {
//    let value: UInt16 = 0xA9AA
//    cpu.stackPush16(value)
//    let result = cpu.stackPop16()
//
//    XCTAssertEqual(result, value)
//  }
//
//  func testWriteToMemoeryWith8BitAddress() {
//
//    cpu.writeMem(at: 0x4000, value: 0xA9)
//    cpu.writeMem(at: 0x4001, value: 0x05)
//    cpu.writeMem(at: 0x4002, value: 0x00)
//
//    XCTAssertEqual(cpu.readMem(at: 0x4000), 0xA9)
//    XCTAssertEqual(cpu.readMem(at: 0x4001), 0x05)
//    XCTAssertEqual(cpu.readMem(at: 0x4002), 0x00)
//  }
//
//  func testWriteToMemoeryWith16BitAddress() {
//
//    cpu.writeMem16(at: 0x4000, value: 0xA9AA)
//    cpu.writeMem16(at: 0x4002, value: 0x0501)
//    cpu.writeMem16(at: 0x4004, value: 0x0024)
//
//    XCTAssertEqual(cpu.readMem16(at: UInt16(0x4000)), 0xA9AA)
//    XCTAssertEqual(cpu.readMem16(at: UInt16(0x4002)), 0x0501)
//    XCTAssertEqual(cpu.readMem16(at: UInt16(0x4004)), 0x0024)
//  }
//
//  func testSettingNegativeFlag() {
//    cpu.reset()
//    cpu.setNegativeFlag(0b1000_0000)
//    XCTAssertTrue(cpu.registers.isSet(.negative))
//    cpu.registers.clear(.negative)
//    XCTAssertFalse(cpu.registers.isSet(.negative))
//
//    cpu.reset()
//    cpu.setNegativeFlag(0b0100_0000)
//    XCTAssertFalse(cpu.registers.isSet(.negative))
//  }
//
//  func testSettingZeroFlag() {
//    cpu.reset()
//    cpu.setZeroFlag(0b0000_0000)
//    XCTAssertTrue(cpu.registers.isSet(.zero))
//    cpu.registers.clear(.zero)
//    XCTAssertFalse(cpu.registers.isSet(.zero))
//
//    cpu.reset()
//    cpu.setZeroFlag(0b0000_0001)
//    XCTAssertFalse(cpu.registers.isSet(.zero))
//  }
// }
