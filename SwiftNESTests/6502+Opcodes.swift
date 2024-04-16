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
    cpu.memory.writeMem16(at: pc, value: 0x01FF)
    cpu.memory.setProgramCounter(pc)
    XCTAssertEqual(cpu.memory.getprogramCounter(), pc)
    
    cpu.JSR()
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0x01FF)
    
    let stackPtr = cpu.memory.stackPop16()
    XCTAssertEqual(stackPtr, 0xAAFF)
    
  }
  
  func testLDA() throws {
    let pc: UInt16 = 0x0022
    cpu.memory.setProgramCounter(pc)
    cpu.memory.writeMem(at: pc, value: 0x33)
    cpu.LDA()
    XCTAssertEqual(cpu.memory.registers.A, 0x33)
  }
  
  func testLDA_zero() throws {
    let pc: UInt16 = 0xF1
    cpu.memory.setProgramCounter(pc)
    cpu.memory.writeMem(at: pc, value: 0x00)
    cpu.LDA()
    XCTAssertTrue(cpu.memory.registers.isSet(.zero))
  }
  
  func testLDA_negative() throws {
    let pc: UInt16 = 0xFB
    cpu.memory.setProgramCounter(pc)
    cpu.memory.writeMem(at: pc, value: 0b1000_0001)
    cpu.LDA()
    XCTAssertTrue(cpu.memory.registers.isSet(.negative))
  }
  
  func testLDX() throws {
    let pc: UInt16 = 0x0022
    cpu.memory.setProgramCounter(pc)
    cpu.memory.writeMem(at: pc, value: 0x33)
    cpu.LDX()
    XCTAssertEqual(cpu.memory.registers.X, 0x33)
  }
  
  func testLDY() throws {
    let pc: UInt16 = 0x0022
    cpu.memory.setProgramCounter(pc)
    cpu.memory.writeMem(at: pc, value: 0x33)
    cpu.LDY()
    XCTAssertEqual(cpu.memory.registers.Y, 0x33)
  }
  
  func testLSR_accumulator() throws {
    let val: UInt8 =  0b1001_1110
    let exp: UInt8 =  0b01001_111
    
    let pc: UInt16 = 0x23
    cpu.memory.setProgramCounter(pc)
    cpu.memory.registers.set(.A, to: val)
    cpu.LSR_accumulator()
    XCTAssertEqual(cpu.memory.registers.A, exp)
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
  }
  
  func testLSR_accumulator_carry() throws {
    let val: UInt8 =  0b1001_1111
    let pc: UInt16 = 0x23
    cpu.memory.setProgramCounter(pc)
    cpu.memory.registers.set(.A, to: val)
    cpu.LSR_accumulator()
    XCTAssertTrue(cpu.memory.registers.isSet(.carry))
  }
  
  func testLSR_accumulator_zero() throws {
    let val: UInt8 =  0b000_0000
    let pc: UInt16 = 0x23
    cpu.memory.setProgramCounter(pc)
    cpu.memory.registers.set(.A, to: val)
    cpu.LSR_accumulator()
    XCTAssertTrue(cpu.memory.registers.isSet(.zero))
  }
  
  func testORA() throws {
    let pc: UInt16 = 0x0022
    let a: UInt8 = 0b1111_0000
    let mem: UInt8 = 0b0000_1111
    cpu.memory.registers.set(.A, to: a)
    cpu.memory.setProgramCounter(pc)
    
    cpu.memory.writeMem(at: pc, value: mem)
    cpu.ORA()
    XCTAssertEqual(cpu.memory.registers.A, 0xFF)
  }
  
  func testPHA() throws {
    cpu.memory.registers.set(.A, to: 0x11)
    cpu.PHA()
    XCTAssertEqual(cpu.memory.stackPop(), 0x11)
  }
  
  func testPHP() throws {
    cpu.memory.registers.set(programStatus: 0x11)
    cpu.PHP()
    XCTAssertEqual(cpu.memory.stackPop(), 0x11)
    cpu.PHP()
  }
  
  func testPLA() throws {
    cpu.memory.stackPush(0xC1)
    cpu.PLA()
    XCTAssertEqual(cpu.memory.registers.A, 0xC1)
  }
  
  func testPLA_zero() throws {
    cpu.memory.stackPush(0x00)
    cpu.PLA()
    XCTAssertEqual(cpu.memory.registers.A, 0x00)
    XCTAssertTrue(cpu.memory.registers.isSet(.zero))
  }
  
  func testPLP() throws {
    cpu.memory.stackPush(0xC1)
    cpu.PLP()
    XCTAssertEqual(cpu.memory.registers.p, 0xC1)
  }
  
  func testROL_accumulator() throws {
    let val: UInt8 =  0b1001_1110 // 158
    let exp: UInt8 =  0b0011_1101 // 61
    
    cpu.memory.registers.set(.carry)
    cpu.memory.registers.set(.A, to: val)
    cpu.ROL_accumulator()
    XCTAssertEqual(cpu.memory.registers.A, exp)
    XCTAssertTrue(cpu.memory.registers.isSet(.carry))
  }
  
  func testROL() throws {
    let val: UInt8 =  0b1001_0000 // 144 0x90
    let exp: UInt8 =  0b001_00001 // 33 0x21
    let pc: UInt16 =  0x23 // 35 0x23
    let ptr: UInt16 = 0xC1 // 193
    
    cpu.memory.registers.set(.carry)
    cpu.memory.setProgramCounter(pc)
    cpu.memory.writeMem(at: pc, value: 0xC1)
    cpu.memory.writeMem(at: ptr, value: val)
    cpu.ROL()
    
    let result = cpu.memory.readMem(at: ptr)
    
    XCTAssertEqual(result, exp)
    XCTAssertTrue(cpu.memory.registers.isSet(.carry))
  }
  
  func testROL_negative() throws {
    let val: UInt8 =  0b0101_1110
    let exp: UInt8 =  0b101_11100
    let pc: UInt16 =  0x23
    
    cpu.memory.registers.set(.A, to: val)
    cpu.ROL_accumulator()
    XCTAssertEqual(cpu.memory.registers.A, exp)
    XCTAssertTrue(cpu.memory.registers.isSet(.negative))
  }
  
  func testROL_zero() throws {
    let val: UInt8 =  0b1000_0000
    let exp: UInt8 =  0b0
    
    let pc: UInt16 = 0x23
    
    cpu.memory.registers.set(.A, to: val)
    cpu.ROL_accumulator()
    XCTAssertEqual(cpu.memory.registers.A, exp)
    XCTAssertTrue(cpu.memory.registers.isSet(.zero))
    XCTAssertFalse(cpu.memory.registers.isSet(.negative))
  }

  func testROR() throws {
    let val: UInt8 =  0b1001_1110 // 158 0x9E
    let exp: UInt8 =  0b1100_1111 // 79 0x4F
                      0b1100_1111
          
    let pc: UInt16 =  0x23 // 35 0x23
    let ptr: UInt16 = 0xC1
    
    cpu.memory.registers.set(.carry)
    cpu.memory.setProgramCounter(pc)
    cpu.memory.writeMem(at: pc, value: 0xC1)
    cpu.memory.writeMem(at: ptr, value: val)
    cpu.ROR()
    
    let result = cpu.memory.readMem(at: ptr)
    
    XCTAssertEqual(result, exp)
    XCTAssertFalse(cpu.memory.registers.isSet(.carry))
  }
  
  func testRORL_negative() throws {
    let val: UInt8 =  0b1000_0000 // 158 0x9E
    let exp: UInt8 =  0b1100_0000 // 79 0x4F
    let pc: UInt16 =  0x23
    
    cpu.memory.registers.set(.carry)
    cpu.memory.setProgramCounter(pc)
    cpu.memory.registers.set(.A, to: val)
    cpu.ROR_accumulator()
    XCTAssertEqual(cpu.memory.registers.A, exp)
    XCTAssertTrue(cpu.memory.registers.isSet(.negative))
  }
  
  func testROR_zero() throws {
    let val: UInt8 =  0b0000_0000 // 158 0x9E
    let exp: UInt8 =  0 // 79 0x4F
    
    let pc: UInt16 = 0x23
    
    cpu.memory.setProgramCounter(pc)
    cpu.memory.registers.set(.A, to: val)
    cpu.ROR_accumulator()
    XCTAssertEqual(cpu.memory.registers.A, exp)
    XCTAssertTrue(cpu.memory.registers.isSet(.zero))
    XCTAssertFalse(cpu.memory.registers.isSet(.negative))
  }
  
  func testRTI() throws {
    cpu.memory.writeMem16(at: 0xFFFE, value: 0xFFCC)
    cpu.memory.setProgramCounter(0xc1)
    cpu.memory.registers.set(programStatus: 0b1100_0101)
    cpu.BRK()
    cpu.memory.registers.set(programStatus: 0b1100_1111)
    
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0xFFCC)
    XCTAssertEqual(cpu.memory.registers.p, 0b1100_1111)
    cpu.RTI()
    XCTAssertEqual(cpu.memory.registers.p, 0b1100_0101)
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0xc1)
  }
  
  func testRTS() throws {
    
    let pc: UInt16 = 0xC1C1
    cpu.memory.writeMem16(at: pc, value: 0x110B)
    cpu.memory.setProgramCounter(pc)
    cpu.JSR()
    
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0x110B)
    
    cpu.RTS()
    
    XCTAssertEqual(cpu.memory.getprogramCounter(), 0xC1C1)
    
  }
  
  func testSBC() throws {
    let val: UInt8 = 0x0A
    let exp: UInt8 = 0xF5
    let pc: UInt16 = 0x23
    
    cpu.memory.registers.set(.A, to: 0xFF)
    cpu.memory.setProgramCounter(pc)
    cpu.memory.writeMem(at: pc, value: val)
    cpu.SBC()
    
    XCTAssertEqual(cpu.memory.registers.A, exp)
    XCTAssertTrue(cpu.memory.registers.isSet(.carry))
    
  }
  
  func testSEC() throws {
    cpu.SEC()
    XCTAssertTrue(cpu.memory.registers.isSet(.carry))
  }
  
  func testSED() throws {
    cpu.SED()
    XCTAssertTrue(cpu.memory.registers.isSet(.decimal))
  }
  
  func testSEI() throws {
    cpu.SEI()
    XCTAssertTrue(cpu.memory.registers.isSet(.interrupt))
  }
  
  func testSTA() throws {
    cpu.memory.writeMem(at: 0xC1, value: 0xAA)
    cpu.memory.setProgramCounter(0xC1)
    cpu.memory.registers.set(.A, to: 0xFF)
    cpu.STA()
    
    let result = cpu.memory.readMem(at: 0xAA)
    XCTAssertEqual(result, 0xFF)
    
  }
  
  func testSTX() throws {
    cpu.memory.writeMem(at: 0xC1, value: 0xAA)
    cpu.memory.setProgramCounter(0xC1)
    cpu.memory.registers.set(.X, to: 0xFF)
    cpu.STX()
    
    let result = cpu.memory.readMem(at: 0xAA)
    XCTAssertEqual(result, 0xFF)
  }
  
  func testSTY() throws {
    cpu.memory.writeMem(at: 0xC1, value: 0xAA)
    cpu.memory.setProgramCounter(0xC1)
    cpu.memory.registers.set(.Y, to: 0xF1)
    cpu.STY()
    
    let result = cpu.memory.readMem(at: 0xAA)
    XCTAssertEqual(result, 0xF1)
  }
  
  func testTAX() throws {
    cpu.memory.registers.set(.A, to: 0x01)
    cpu.TAX()
    XCTAssertEqual(cpu.memory.registers.A, 0x01)
  }
  
  func testTAX_zero() throws {
    cpu.memory.registers.set(.A, to: 0x0)
    cpu.TAX()
    XCTAssertTrue(cpu.memory.registers.isSet(.zero))
  }
  
  func testTAX_zegative() throws {
    cpu.memory.registers.set(.A, to: 0b1000_0000)
    cpu.TAX()
    XCTAssertTrue(cpu.memory.registers.isSet(.negative))
  }
  
  func testTAY() throws {
    cpu.memory.registers.set(.A, to: 0x01)
    cpu.TAY()
    XCTAssertEqual(cpu.memory.registers.Y, 0x01)
  }
  
  func testTAY_zero() throws {
    cpu.memory.registers.set(.A, to: 0x0)
    cpu.TAY()
    XCTAssertTrue(cpu.memory.registers.isSet(.zero))
  }
  
  func testTAY_zegative() throws {
    cpu.memory.registers.set(.A, to: 0b1000_0000)
    cpu.TAY()
    XCTAssertTrue(cpu.memory.registers.isSet(.negative))
  }
  
  func testTSX() throws {
    cpu.memory.setStackPointer(0xC1)
    cpu.TSX()
    XCTAssertEqual(cpu.memory.registers.X, 0xC1)
  }
  
  func testTSX_zero() throws {
    cpu.memory.setStackPointer(0x0)
    cpu.TSX()
    XCTAssertTrue(cpu.memory.registers.isSet(.zero))
  }
  
  func testTSX_zegative() throws {
    cpu.memory.setStackPointer(0b1000_0001) //
    cpu.TSX()
    XCTAssertTrue(cpu.memory.registers.isSet(.negative))
  }
  
  func testTXA() throws {
      cpu.memory.registers.set(.X, to: 0x01)
      cpu.TXA()
      XCTAssertEqual(cpu.memory.registers.A, 0x01)
  }
  
  func testTXS() throws {
    cpu.memory.registers.set(.X, to: 0xC1)
    cpu.TXS()
    XCTAssertEqual(cpu.memory.getStackPointer(), cpu.memory.registers.X)
  }
  
  func testTYA() throws {
    cpu.memory.registers.set(.Y, to: 0x01)
    cpu.TYA()
    XCTAssertEqual(cpu.memory.registers.A, cpu.memory.registers.Y)
  }
}
