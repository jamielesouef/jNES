//
//  6502+Opcodes.swift
//  SwiftNESTests
//
//  Created by Jamie Le Souef on 15/4/2024.
//

import XCTest
@testable import SwiftNES
final class _6502_Opcodes: XCTestCase {
  
  var cpu: CPU!
  
  override func setUpWithError() throws {
    self.cpu = CPU.mock()
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testADC() throws {
    XCTAssertEqual(cpu.memory.registers.A, 0x33)
    cpu.memory.writeMem(at: 0x00, value: 0xA4)
    cpu.ADC()
    XCTAssertEqual(cpu.memory.registers.A, 0xD7)
    
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
    XCTAssertFalse(cpu.memory.registers.isSet(.zero))
    XCTAssertTrue(cpu.memory.registers.isSet(.negative))
  }
  
  func testADC_carry() throws {
    XCTAssertEqual(cpu.memory.registers.A, 0x33)
    cpu.memory.writeMem(at: 0x00, value: 0xFF)
    cpu.ADC()
    XCTAssertEqual(cpu.memory.registers.A, 0x32)
    XCTAssertTrue(cpu.memory.registers.isSet(.carry))
    
  }
  
  func testADC_zero() throws {
    XCTAssertEqual(cpu.memory.registers.A, 0x33)
    cpu.memory.writeMem(at: 0x00, value: 0xCD)
    cpu.ADC()
    XCTAssertEqual(cpu.memory.registers.A, 0x00)
    XCTAssertTrue(cpu.memory.registers.isSet(.zero))
  }
  
  func testADC_negative() throws {
    XCTAssertEqual(cpu.memory.registers.A, 0x33)
    cpu.memory.writeMem(at: 0x00, value: 0xCC)
    cpu.ADC()
    XCTAssertEqual(cpu.memory.registers.A, 0xFF)
    XCTAssertTrue(cpu.memory.registers.isSet(.negative))
  }
  
  func testAND() throws {
    XCTAssertEqual(cpu.memory.registers.A, 0b0011_0011)
    cpu.memory.writeMem(at: 0x00, value: 0b1000_1110)
    cpu.AND()
    XCTAssertEqual(cpu.memory.registers.A, 0b0000_0010)
  }
  
  func testASL_accumulator() throws {
    XCTAssertEqual(cpu.memory.registers.A, 0b0011_0011)
    cpu.ASL()
    XCTAssertEqual(cpu.memory.registers.A, 0b0110_0110)
  }
  
  func testASL_accumulator_zero_is_set() throws {
    cpu.memory.registers.set(.A, to: 0b1000_0000)
    cpu.ASL()
    XCTAssertTrue(cpu.memory.registers.isSet(.zero))
  }
  
  func testASL_accumulator_zero_not_set() throws {
    cpu.memory.registers.set(.A, to: 0b0100_0000)
    cpu.ASL()
    XCTAssertFalse(cpu.memory.registers.isSet(.zero))
  }
  
  func testASL_accumulator_negative_is_set() throws {
    cpu.memory.registers.set(.A, to: 0b0100_0000)
    cpu.ASL_accumulator()
    XCTAssertTrue(cpu.memory.registers.isSet(.negative))
  }
  
  func testASL_accumulator_negative_is_not_set() throws {
    cpu.memory.registers.set(.A, to: 0b0010_0000)
    cpu.ASL_accumulator()
    XCTAssertFalse(cpu.memory.registers.isSet(.negative))
  }
  
  func testASL_accumulator_carry_is_set() throws {
    cpu.memory.registers.set(.A, to: 0b1010_0000)
    cpu.ASL_accumulator()
    XCTAssertTrue(cpu.memory.registers.isSet(.carry))
  }
  
  func testBCC_when_carry_set() throws {
    cpu.memory.registers.set(.carry)
    cpu.BCC()
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0x2A)
  }
  
  func testBCC_when_carry_cleared() throws {
    cpu.memory.registers.clear(.carry)
    cpu.BMI()
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0x00)
  }
  
  func testBCS() throws {
    cpu.memory.registers.set(.A, to: 0b1010_0000)
    XCTAssertEqual(cpu.memory.readMem(at: 0x00), 0x15)
    cpu.BCS()
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0x2A)
  }
  
  func testBEQ() throws {
    cpu.memory.registers.set(.A, to: 0b1010_0000)
    XCTAssertEqual(cpu.memory.readMem(at: 0x00), 0x15)
    cpu.BEQ()
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0x00)
  }
  
  func testBIT_zero_set() throws {
    cpu.memory.registers.set(.A, to: 0b0000_0000)
    cpu.BIT()
    XCTAssertTrue(cpu.memory.registers.isSet(.zero))
  }
  
  func testBIT_negative_set() throws {
    cpu.memory.registers.set(.A, to: 0b1000_0001)
    cpu.memory.writeMem(at: 0x00, value: 0b1000_0000)
    cpu.BIT()
    XCTAssertTrue(cpu.memory.registers.isSet(.negative))
  }
  
  func testBIT_overflow_set() throws {
    cpu.memory.registers.set(.A, to: 0b0100_0000)
    cpu.memory.writeMem(at: 0x00, value: 0b1100_0000)
    cpu.BIT()
    XCTAssertTrue(cpu.memory.registers.isSet(.overflow))
  }
  
  func testBMI_negative_set() throws {
    cpu.memory.registers.set(.negative)
    cpu.BMI()
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0x2A)
  }
  
  func testBMI_negative_cleared() throws {
    cpu.memory.registers.clear(.negative)
    cpu.BMI()
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0x00)
  }
  
  func testBNE_brance_when_zero_not_1() throws {
    cpu.memory.registers.set(.zero)
    cpu.BNE()
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0x00)
  }
  
  func testBNE_zero_when_zero_not_0() throws {
    cpu.memory.registers.clear(.zero)
    cpu.BNE()
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0x2A)
  }
  
  func testBPL_when_not_equal_set() throws {
    cpu.memory.registers.clear(.zero)
    cpu.BPL()
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0x2A)
  }
  
  func testBPL_when_cleared() throws {
    cpu.memory.registers.clear(.zero)
    cpu.BPL()
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0x2A)
  }
  
  func testBRK() throws {
    cpu.memory.setProgramCounter(0x00A1)
    cpu.memory.writeMem16(at: 0xFFFE, value: 0x1C1C)
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0xA1)
    cpu.BRK()
    
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0x1C1C)
    
  }
  
  func testBVC_branch() throws {
    cpu.memory.setProgramCounter(0x00A1)
    cpu.memory.registers.clear(.overflow)
    cpu.BVC()
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0xA0)
  }
  
  func testBVC_dont_branch() throws {
    cpu.memory.setProgramCounter(0x00A1)
    cpu.memory.registers.set(.overflow)
    cpu.BVC()
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0xA1)

  }
  
  func testBVS_branch() throws {
    cpu.memory.setProgramCounter(0x00A1)
    cpu.memory.registers.set(.overflow)
    cpu.BVS()
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0xA0)
  }
  
  func testBVS_dont_branch() throws {
    cpu.memory.setProgramCounter(0x00A1)
    cpu.memory.registers.clear(.overflow)
    cpu.BVS()
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0xA1)
  }
  
  func testCLC() throws {
    cpu.memory.registers.set(.carry)
    cpu.CLC()
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
  }
  
  func testCLD() throws {
    cpu.memory.registers.set(.decimal)
    cpu.CLD()
    XCTAssertFalse(cpu.memory.registers.isSet(.decimal))
  }
  
  func testCLI() throws {
    cpu.memory.registers.set(.interrupt)
    cpu.CLI()
    XCTAssertFalse(cpu.memory.registers.isSet(.interrupt))
  }
  
  func testCLV() throws {
    cpu.memory.registers.set(.overflow)
    cpu.CLV()
    XCTAssertFalse(cpu.memory.registers.isSet(.overflow))
  }
  
  func testCMP() throws {
    cpu.memory.registers.set(.A, to: 0x01)
    cpu.memory.writeMem(at: 0x00, value: 0xA1)
    cpu.CMP()
    
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
    XCTAssertFalse(cpu.memory.registers.isSet(.zero))
    XCTAssertFalse(cpu.memory.registers.isSet(.negative))
  }
  
  func testCMP_zero() throws {
    cpu.memory.registers.set(.A, to: 0xA1)
    cpu.memory.writeMem(at: 0x00, value: 0xA1)
    cpu.CMP()
    
    XCTAssertTrue(cpu.memory.registers.isSet(.carry))
    XCTAssertTrue(cpu.memory.registers.isSet(.zero))
    XCTAssertFalse(cpu.memory.registers.isSet(.negative))
  }
  
  func testCMP_negative() throws {
    cpu.memory.registers.set(.A, to: 0xA0)
    cpu.memory.writeMem(at: 0x00, value: 0xA1)
    cpu.CMP()
    
    XCTAssertTrue(cpu.memory.registers.isSet(.negative))
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
    XCTAssertFalse(cpu.memory.registers.isSet(.zero))
  }
  
  func testCPX() throws {
    cpu.memory.registers.set(.X, to: 0x01)
    cpu.memory.writeMem(at: 0x00, value: 0xA1)
    cpu.CPX()
    
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
    XCTAssertFalse(cpu.memory.registers.isSet(.zero))
    XCTAssertFalse(cpu.memory.registers.isSet(.negative))
  }
  
  func testCPY() throws {
    cpu.memory.registers.set(.Y, to: 0x01)
    cpu.memory.writeMem(at: 0x00, value: 0xA1)
    cpu.CPY()
    
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
    XCTAssertFalse(cpu.memory.registers.isSet(.zero))
    XCTAssertFalse(cpu.memory.registers.isSet(.negative))
  }
  
  func testDEC() throws {
    cpu.memory.setProgramCounter(0x00)
    cpu.memory.writeMem(at: 0x00, value: 0xFF)
    cpu.DEC()
    
    XCTAssertEqual(cpu.memory.readMem(at: 0x00), 0xFE)
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
    XCTAssertFalse(cpu.memory.registers.isSet(.zero))
    XCTAssertTrue(cpu.memory.registers.isSet(.negative))
  }
  
  func testDEY() throws {
    cpu.memory.registers.set(.Y, to: 0x01)
    cpu.DEY()
    
    XCTAssertEqual(cpu.memory.registers.Y, 0x00)
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
    XCTAssertTrue(cpu.memory.registers.isSet(.zero))
    XCTAssertFalse(cpu.memory.registers.isSet(.negative))
  }
  
  func testDEX() throws {
    cpu.memory.registers.set(.X, to: 0x01)
    cpu.DEX()
    
    XCTAssertEqual(cpu.memory.registers.X, 0x00)
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
    XCTAssertTrue(cpu.memory.registers.isSet(.zero))
    XCTAssertFalse(cpu.memory.registers.isSet(.negative))
    
  }
  
  func testEOR() throws {
    cpu.memory.registers.set(.A, to: 0b1010_0101)
    cpu.memory.writeMem(at: 0x00, value: 0b1010_1010)
    cpu.EOR()
    
    XCTAssertEqual(cpu.memory.registers.A, 0b0000_1111)
  }
  
  func testINC() throws {
    cpu.memory.writeMem(at: 0x00, value: 0x00)
    cpu.INC()
    
    XCTAssertEqual(cpu.memory.readMem(at: 0x00), 0x01)
  }
  
  func testINX() throws {
    cpu.memory.registers.set(.X, to: 0x00)
    cpu.memory.writeMem(at: 0x00, value: 0x00)
    cpu.INX()
    
    XCTAssertEqual(cpu.memory.registers.X, 0x01)
  }
  
  func testINY() throws {
    cpu.memory.registers.set(.Y, to: 0x00)
    cpu.memory.writeMem(at: 0x00, value: 0x00)
    cpu.INY()
    
    XCTAssertEqual(cpu.memory.registers.Y, 0x01)
  }
  
  func testJMP() throws {
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0x0000)
    cpu.memory.writeMem(at: 0x00, value: 0x33)
    cpu.memory.writeMem(at: 0x01, value: 0xFF)
    cpu.JMP()
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0xFF33)
  }
  
  func testJSR() throws {
    let pc:UInt16 = 0xAAFF
    cpu.memory.setProgramCounter(pc)
    XCTAssertEqual(cpu.memory.getprogramCounter(), pc)
    cpu.memory.writeMem16(at: pc, value: 0x33FF)
    
    cpu.JSR()
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0x33FF)
    XCTAssertEqual(cpu.memory.stackPop16(), pc - 1)
  }
  
  func testLDA() throws {
    cpu.LDA()
  }
  
  func testLDX() throws {
    cpu.LDX()
  }
  
  func testLDY() throws {
    cpu.LDY()
  }
  
  func testLSR() throws {
    cpu.LSR()
  }
  
  func testNOP() throws {
    cpu.NOP()
  }
  
  func testORA() throws {
    cpu.ORA()
  }
  
  func testPHA() throws {
    cpu.PHA()
  }
  
  func testPHP() throws {
    cpu.PHP()
  }
  
  func testPLA() throws {
    cpu.PLA()
  }
  
  func testPLP() throws {
    cpu.PLP()
  }
  
  func testROL() throws {
    cpu.ROL()
  }
  
  func testROR() throws {
    cpu.ROR()
  }
  
  func testRTI() throws {
    cpu.RTI()
  }
  
  func testRTS() throws {
    cpu.RTS()
  }
  
  func testSBC() throws {
    cpu.SBC()
  }
  
  func testSEC() throws {
    cpu.SEC()
  }
  
  func testSED() throws {
    cpu.SED()
  }
  
  func testSEI() throws {
    cpu.SEI()
  }
  
  func testSTA() throws {
    cpu.STA()
  }
  
  func testSTX() throws {
    cpu.STX()
  }
  
  func testSTY() throws {
    cpu.STY()
  }
  
  func testTAX() throws {
    cpu.TAX()
  }
  
  func testTAY() throws {
    cpu.TAY()
  }
  
  func testTSX() throws {
    cpu.TSX()
  }
  
  func testTXA() throws {
    cpu.TXA()
  }
  
  func testTXS() throws {
    cpu.TXS()
  }
  
  func testTYA() throws {
    cpu.TYA()
  }
}
