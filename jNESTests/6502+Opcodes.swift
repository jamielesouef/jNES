//
//  6502+Opcodes.swift
//  SwiftNESTests
//
//  Created by Jamie Le Souef on 15/4/2024.
//

import XCTest
@testable import jNES
final class _6502_Opcodes: XCTestCase {
  
  var cpu: CPU!
  
  override func setUpWithError() throws {
    self.cpu = CPU.mock()
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testADC() throws {
    XCTAssertEqual(cpu.registers.A, 0x33)
    cpu.writeMem(at: 0x00, value: 0xA4)
    cpu.ADC(mode: .immediate)
    XCTAssertEqual(cpu.registers.A, 0xD7)
    
    XCTAssertFalse(cpu.registers.isSet(.carry))
    XCTAssertFalse(cpu.registers.isSet(.zero))
    
  }
  
  func testADC_carry() throws {
    XCTAssertEqual(cpu.registers.A, 0x33)
    cpu.writeMem(at: 0x00, value: 0xFF)
    cpu.ADC(mode: .immediate)
    XCTAssertEqual(cpu.registers.A, 0x32)
    XCTAssertTrue(cpu.registers.isSet(.carry))
    
  }
  
  func testADC_zero() throws {
    XCTAssertEqual(cpu.registers.A, 0x33)
    cpu.writeMem(at: 0x00, value: 0xCD)
    cpu.ADC(mode: .immediate)
    XCTAssertEqual(cpu.registers.A, 0x00)
    XCTAssertTrue(cpu.registers.isSet(.zero))
  }
  
  func testAND() throws {
    XCTAssertEqual(cpu.registers.A, 0b0011_0011)
    cpu.writeMem(at: 0x00, value: 0b1000_1110)
    cpu.AND(mode: .immediate)
    XCTAssertEqual(cpu.registers.A, 0b0000_0010)
  }
  
  func testASL() throws {
    XCTAssertEqual(cpu.registers.A, 0b0011_0011)
    cpu.ASL(mode: .accumulator)
    XCTAssertEqual(cpu.registers.A, 0b0110_0110)
  }
  
  func testASL_zero_is_set() throws {
    cpu.registers.set(.A, to: 0b1000_0000)
    cpu.ASL(mode: .accumulator)
    XCTAssertTrue(cpu.registers.isSet(.zero))
  }
  
  func testASL_zero_not_set() throws {
    cpu.registers.set(.A, to: 0b0100_0000)
    cpu.ASL(mode: .accumulator)
    XCTAssertFalse(cpu.registers.isSet(.zero))
  }
  
  func testASL_negative_is_set() throws {
    cpu.registers.set(.A, to: 0b0100_0000)
    cpu.ASL(mode: .accumulator)
    XCTAssertTrue(cpu.registers.isSet(.negative))
  }
  
  func testASL_negative_is_not_set() throws {
    cpu.registers.set(.A, to: 0b0010_0000)
    cpu.ASL(mode: .accumulator)
    XCTAssertFalse(cpu.registers.isSet(.negative))
  }
  
  func testASL_carry_is_set() throws {
    cpu.registers.set(.A, to: 0b1010_0000)
    cpu.ASL(mode: .accumulator)
    XCTAssertTrue(cpu.registers.isSet(.carry))
  }
  
  func testBCC_when_carry_clear() throws {
    cpu.registers.clear(.carry)
    cpu.BCC()
    XCTAssertEqual(cpu.getProgramCounter(), 0x16)
  }
  
  func testBMI() throws {
    
    cpu.registers.clear(.negative)

    cpu.BMI()
    XCTAssertEqual(cpu.getProgramCounter(), 0x00)
    
    cpu.registers.set(.negative)
    cpu.BMI()
    XCTAssertEqual(cpu.getProgramCounter(), 0x16)
  }
  
  func testBCS() throws {
    cpu.registers.set(.A, to: 0b1010_0000)
    XCTAssertEqual(cpu.readMem(at: 0x00), 0x15)
    cpu.BCS()
    XCTAssertEqual(cpu.getProgramCounter(), 0x16)
  }
  
  func testBEQ() throws {
    cpu.registers.set(.zero)
    XCTAssertEqual(cpu.readMem(at: 0x00), 0x15)
    cpu.BEQ()
    XCTAssertEqual(cpu.getProgramCounter(), 0x16)
  }
  
  func testBIT_zero_set() throws {
    cpu.registers.set(.A, to: 0b0000_0000)
    cpu.BIT(mode: .immediate)
    XCTAssertTrue(cpu.registers.isSet(.zero))
  }
  
  func testBIT_negative_set() throws {
    cpu.registers.set(.A, to: 0b1000_0001)
    cpu.writeMem(at: 0x00, value: 0b1000_0000)
      cpu.BIT(mode: .immediate)
    XCTAssertTrue(cpu.registers.isSet(.negative))
  }
  
  func testBIT_overflow_set() throws {
    cpu.registers.set(.A, to: 0b0100_0000)
    cpu.writeMem(at: 0x00, value: 0b1100_0000)
        cpu.BIT(mode: .immediate)
    XCTAssertTrue(cpu.registers.isSet(.overflow))
  }
  
  func testBMI_negative_set() throws {
    cpu.registers.set(.negative)
    cpu.BMI()
    XCTAssertEqual(cpu.getProgramCounter(), 0x16)
  }
  
  func testBMI_negative_cleared() throws {
    cpu.registers.clear(.negative)
    cpu.BMI()
    XCTAssertEqual(cpu.getProgramCounter(), 0)
  }
  
  func testBNE_brance_when_zero_not_1() throws {
    
    
    cpu.registers.clear(.zero)
    cpu.setProgramCounter(0x0644)
    cpu.writeMem(at: 0x0644, value: 0x09)
    cpu.BNE()
    XCTAssertEqual(cpu.getProgramCounter(), 0x64e)
  }
    
  func testBNE_zero_when_zero_not_0() throws {
    cpu.registers.clear(.zero)
    cpu.BNE()
    XCTAssertEqual(cpu.getProgramCounter(), 0x16)
  }
  
  func testBPL_when_not_equal_set() throws {
    cpu.registers.clear(.zero)
    cpu.BPL()
    XCTAssertEqual(cpu.getProgramCounter(), 0x16)
  }
  
  func testBPL_when_cleared() throws {
    cpu.registers.clear(.zero)
    cpu.BPL()
    XCTAssertEqual(cpu.getProgramCounter(), 0x16)
  }
  
  func testBRK() throws {
    cpu.setProgramCounter(0x00A1)
//    cpu.writeMem16(at: 0xFFFE, value: 0x1C1C)
//    XCTAssertEqual(cpu.getProgramCounter(), 0xA1)
//    cpu.BRK()
//    
//    XCTAssertEqual(cpu.getProgramCounter(), 0x1C1C)
    
  }
  
  func testBVC() throws {
    cpu.setProgramCounter(1)
    cpu.registers.set(.overflow)
    cpu.BVC()
    XCTAssertEqual(cpu.getProgramCounter(), 0x01)
    
    cpu.setProgramCounter(1)
    cpu.registers.clear(.overflow)
    cpu.BVC()
    XCTAssertEqual(cpu.getProgramCounter(), 0x40)
  }
  
  func testBVS() throws {
    cpu.setProgramCounter(1)
    cpu.registers.set(.overflow)
    cpu.BVS()
    XCTAssertEqual(cpu.getProgramCounter(), 0x40)
    
    cpu.setProgramCounter(1)
    cpu.registers.clear(.overflow)
    cpu.BVS()
    XCTAssertEqual(cpu.getProgramCounter(), 0x01)
  }
  
  func testCLC() throws {
    cpu.registers.set(.carry)
    cpu.CLC()
    XCTAssertFalse(cpu.registers.isSet(.carry))
  }
  
  func testCLD() throws {
    cpu.registers.set(.decimal)
    cpu.CLD()
    XCTAssertFalse(cpu.registers.isSet(.decimal))
  }
  
  func testCLI() throws {
    cpu.registers.set(.interrupt)
    cpu.CLI()
    XCTAssertFalse(cpu.registers.isSet(.interrupt))
  }
  
  func testCLV() throws {
    cpu.registers.set(.overflow)
    cpu.CLV()
    XCTAssertFalse(cpu.registers.isSet(.overflow))
  }
  
  func testCMP() throws {
    cpu.registers.set(.A, to: 0x01)
    cpu.writeMem(at: 0x00, value: 0xA1)
    cpu.CMP(mode: .immediate)
    
    XCTAssertFalse(cpu.registers.isSet(.zero))
    XCTAssertFalse(cpu.registers.isSet(.negative))
  }
  
  func testCMP_carry_set() throws {
    cpu.registers.set(.A, to: 0xA2)
    cpu.writeMem(at: 0x00, value: 0xA1)
    cpu.CMP(mode: .immediate)
    
    XCTAssertTrue(cpu.registers.isSet(.carry))
  }
  
  func testCMP_carry_cleared() throws {
    cpu.registers.set(.A, to: 0x10)
    cpu.writeMem(at: 0x00, value: 0x20)
    cpu.CMP(mode: .immediate)
    
    XCTAssertFalse(cpu.registers.isSet(.carry))
  }
  
  func testCMP_zero() throws {
    cpu.registers.set(.A, to: 0xA1)
    cpu.writeMem(at: 0x00, value: 0xA1)
    cpu.CMP(mode: .immediate)
    
    XCTAssertTrue(cpu.registers.isSet(.carry))
    XCTAssertTrue(cpu.registers.isSet(.zero))
    XCTAssertFalse(cpu.registers.isSet(.negative))
  }
  
  func testCMP_negative() throws {
    cpu.registers.set(.A, to: 0xA1)
    cpu.writeMem(at: 0x00, value: 0x00)
    cpu.CMP(mode: .immediate)
    
    XCTAssertTrue(cpu.registers.isSet(.negative))
  }
  
  func testCPX() throws {
    cpu.registers.set(.X, to: 0xA2)
    cpu.writeMem(at: 0x00, value: 0xA1)
    cpu.CPX(mode: .immediate)
    
    XCTAssertFalse(cpu.registers.isSet(.zero))
    XCTAssertFalse(cpu.registers.isSet(.negative))
  }
  
  func testCPY() throws {
    cpu.registers.set(.Y, to: 0xA2)
    cpu.writeMem(at: 0x00, value: 0xA1)
    cpu.CPY(mode: .immediate)
    
    XCTAssertFalse(cpu.registers.isSet(.zero))
    XCTAssertFalse(cpu.registers.isSet(.negative))
  }
  
  func testDEC() throws {
    cpu.setProgramCounter(0x00)
    cpu.writeMem(at: 0x00, value: 0xFF)
    cpu.DEC(mode: .immediate)
    
    XCTAssertEqual(cpu.readMem(at: 0x00), 0xFE)
    XCTAssertFalse(cpu.registers.isSet(.zero))
    XCTAssertTrue(cpu.registers.isSet(.negative))
  }
  
  func testDEY() throws {
    cpu.registers.set(.Y, to: 0x01)
    cpu.DEY()
    
    XCTAssertEqual(cpu.registers.Y, 0x00)
    XCTAssertTrue(cpu.registers.isSet(.zero))
    XCTAssertFalse(cpu.registers.isSet(.negative))
    
    cpu.registers.set(.Y, to: 0x00)
    cpu.DEY()
    XCTAssertTrue(cpu.registers.isSet(.negative))
  }
  
  func testDEX() throws {
    cpu.registers.set(.X, to: 0x01)
    cpu.DEX()
    
    XCTAssertEqual(cpu.registers.X, 0x00)
    XCTAssertTrue(cpu.registers.isSet(.zero))
    XCTAssertFalse(cpu.registers.isSet(.negative))
    
    cpu.registers.set(.X, to: 0x00)
    cpu.DEX()
    XCTAssertTrue(cpu.registers.isSet(.negative))
    
  }
  
  func testEOR() throws {
    cpu.registers.set(.A, to: 0b1010_0101)
    cpu.writeMem(at: 0x00, value: 0b1010_1010)
    cpu.EOR(mode: .immediate)
    
    XCTAssertEqual(cpu.registers.A, 0b0000_1111)
  }
  
  func testINC() throws {
    cpu.writeMem(at: 0x00, value: 0x00)
    cpu.INC(mode: .immediate)
    
    XCTAssertEqual(cpu.readMem(at: 0x00), 0x01)
  }
  
  func testINX() throws {
    cpu.registers.set(.X, to: 0x00)
    cpu.writeMem(at: 0x00, value: 0x00)
    cpu.INX()
    
    XCTAssertEqual(cpu.registers.X, 0x01)
  }
  
  func testINY() throws {
    cpu.registers.set(.Y, to: 0x00)
    cpu.writeMem(at: 0x00, value: 0x00)
    cpu.INY()
    
    XCTAssertEqual(cpu.registers.Y, 0x01)
  }
  
  func testJMP() throws {
    XCTAssertEqual(cpu.getProgramCounter(), 0x0000)
    cpu.writeMem(at: 0x00, value: 0x33)
    cpu.writeMem(at: 0x01, value: 0xFF)
    cpu.JMP(mode: .absolute)
    XCTAssertEqual(cpu.getProgramCounter(), 0xFF33)
  }
  
  func testJSR() throws {
    let pc:UInt16 = 0xAAFF
    cpu.writeMem16(at: pc, value: 0x01FF)
    cpu.setProgramCounter(pc)
    XCTAssertEqual(cpu.getProgramCounter(), pc)
    
    cpu.JSR()
    XCTAssertEqual(cpu.getProgramCounter(), 0x01FF)
    
    let stackPtr = cpu.stackPop16()
    XCTAssertEqual(stackPtr, 0xAB00)
    
  }
  
  func testLDA() throws {
    let pc: UInt16 = 0x0022
    cpu.setProgramCounter(pc)
    cpu.writeMem(at: pc, value: 0x33)
    cpu.LDA(mode: .immediate)
    XCTAssertEqual(cpu.registers.A, 0x33)
  }
  
  func testLDA_zero() throws {
    let pc: UInt16 = 0xF1
    cpu.setProgramCounter(pc)
    cpu.writeMem(at: pc, value: 0x00)
    cpu.LDA(mode: .immediate)
    XCTAssertTrue(cpu.registers.isSet(.zero))
  }
  
  func testLDA_negative() throws {
    let pc: UInt16 = 0xFB
    cpu.setProgramCounter(pc)
    cpu.writeMem(at: pc, value: 0b1000_0001)
    cpu.LDA(mode: .immediate)
    XCTAssertTrue(cpu.registers.isSet(.negative))
  }
  
  func testLDX() throws {
    let pc: UInt16 = 0x0022
    cpu.setProgramCounter(pc)
    cpu.writeMem(at: pc, value: 0x33)
    cpu.LDX(mode: .immediate)
    XCTAssertEqual(cpu.registers.X, 0x33)
  }
  
  func testLDY() throws {
    let pc: UInt16 = 0x0022
    cpu.setProgramCounter(pc)
    cpu.writeMem(at: pc, value: 0x33)
    cpu.LDY(mode: .immediate)
    XCTAssertEqual(cpu.registers.Y, 0x33)
  }
  
  func testLSR() throws {
    let val: UInt8 =  0b1001_1110
    let exp: UInt8 =  0b01001_111
    
    let pc: UInt16 = 0x23
    cpu.setProgramCounter(pc)
    cpu.registers.set(.A, to: val)
    cpu.LSR(mode: .accumulator)
    XCTAssertEqual(cpu.registers.A, exp)
    XCTAssertFalse(cpu.registers.isSet(.carry))
  }
  
  func testLSR_zero() throws {
    let val: UInt8 =  0b000_0000
    let pc: UInt16 = 0x23
    cpu.setProgramCounter(pc)
    cpu.registers.set(.A, to: val)
    cpu.LSR(mode: .accumulator)
    XCTAssertTrue(cpu.registers.isSet(.zero))
  }
  
  func testORA() throws {
    let pc: UInt16 = 0x0022
    let a: UInt8 = 0b1111_0000
    let mem: UInt8 = 0b0000_1111
    cpu.registers.set(.A, to: a)
    cpu.setProgramCounter(pc)
    
    cpu.writeMem(at: pc, value: mem)
    cpu.ORA(mode: .immediate)
    XCTAssertEqual(cpu.registers.A, 0xFF)
  }
  
  func testPHA() throws {
    cpu.registers.set(.A, to: 0x11)
    cpu.PHA()
    XCTAssertEqual(cpu.stackPop(), 0x11)
  }
  
  func testPHP() throws {
    cpu.registers.set(programStatus: 0x11)
    cpu.PHP()
    XCTAssertEqual(cpu.stackPop(), 0x11)
    cpu.PHP()
  }
  
  func testPLA() throws {
    cpu.stackPush(0xC1)
    cpu.PLA()
    XCTAssertEqual(cpu.registers.A, 0xC1)
  }
  
  func testPLA_zero() throws {
    cpu.stackPush(0x00)
    cpu.PLA()
    XCTAssertEqual(cpu.registers.A, 0x00)
    XCTAssertTrue(cpu.registers.isSet(.zero))
  }
  
  func testPLP() throws {
    cpu.stackPush(0xC1)
    cpu.PLP()
    XCTAssertEqual(cpu.registers.p, 0xC1)
  }
  
  func testROL() throws {
    let val: UInt8 =  0x10 // 158
    let exp: UInt8 =  0x20 // 61
    
    cpu.registers.set(.A, to: val)
    cpu.ROL(mode: .accumulator)
    XCTAssertEqual(cpu.registers.A, exp)
  }
  
  func testROL_immediate() throws {
    let pc: UInt16 =  0x23
    
    cpu.setProgramCounter(pc)
    cpu.writeMem(at: pc, value: 0x0F)
    
    cpu.ROL(mode: .immediate)
    
    let result = cpu.readMem(at: pc)
        
    XCTAssertEqual(result, 0x0F << 1)
    
  }
  
  func testROL_immediate_carry() throws {
    let pc: UInt16 =  0x23
    
    cpu.setProgramCounter(pc)
    cpu.writeMem(at: pc, value: 0xC1)
    
    cpu.ROL(mode: .immediate)
    
    let result = cpu.readMem(at: pc)
        
    XCTAssertEqual(result, (0xc1 << 1) + 1)
    
  }

  func testROR() throws {
    
    
    let val: UInt8 = 0xC1
    cpu.registers.set(.A, to: val)
    cpu.ROR(mode: .accumulator)
    
    let result = cpu.registers.A
    
    XCTAssertEqual(result, val >> 1)
    
  }
  
  func testRORL_negative() throws {
    let val: UInt8 =  0b1000_0000 // 158 0x9E
    let exp: UInt8 =  0b1100_0000 // 79 0x4F
    let pc: UInt16 =  0x23
    
    cpu.registers.set(.carry)
    cpu.setProgramCounter(pc)
    cpu.registers.set(.A, to: val)
    cpu.ROR(mode: .accumulator)
    XCTAssertEqual(cpu.registers.A, exp)
    XCTAssertTrue(cpu.registers.isSet(.negative))
  }
  
  func testROR_zero() throws {
    let val: UInt8 =  0b0000_0000 // 158 0x9E
    let exp: UInt8 =  0 // 79 0x4F
    
    let pc: UInt16 = 0x23
    
    cpu.setProgramCounter(pc)
    cpu.registers.set(.A, to: val)
    cpu.ROR(mode: .accumulator)
    XCTAssertEqual(cpu.registers.A, exp)
    XCTAssertTrue(cpu.registers.isSet(.zero))
    XCTAssertFalse(cpu.registers.isSet(.negative))
  }
  
  func testRTI() throws {
    cpu.stackPush16(0xCCFF)
    cpu.stackPush(0x1D)
    
    XCTAssertEqual(cpu.getProgramCounter(), 0)
    XCTAssertEqual(cpu.registers.p, 0)
    cpu.RTI()
    XCTAssertEqual(cpu.registers.p, 0x1D)
    XCTAssertEqual(cpu.getProgramCounter(), 0xCCFF)
  }
  
  func testRTS() throws {
    
    let pc: UInt16 = 0xC1C1
    cpu.writeMem16(at: pc, value: 0x110B)
    cpu.setProgramCounter(pc)
    cpu.JSR()
    
    XCTAssertEqual(cpu.getProgramCounter(), 0x110B)
    
    cpu.RTS()
    
    XCTAssertEqual(cpu.getProgramCounter(), 0xC1C3)
    
  }
  
  func testSBC() throws {
    let val: UInt8 = 0x0A
    let exp: UInt8 = 0xF5
    let pc: UInt16 = 0x23
    
    cpu.registers.set(.A, to: 0xFF)
    cpu.setProgramCounter(pc)
    cpu.writeMem(at: pc, value: val)
    cpu.SBC(mode: .immediate)
    
    XCTAssertEqual(cpu.registers.A, exp)
    XCTAssertTrue(cpu.registers.isSet(.carry))
    
  }
  
  func testSEC() throws {
    cpu.SEC()
    XCTAssertTrue(cpu.registers.isSet(.carry))
  }
  
  func testSED() throws {
    cpu.SED()
    XCTAssertTrue(cpu.registers.isSet(.decimal))
  }
  
  func testSEI() throws {
    cpu.SEI()
    XCTAssertTrue(cpu.registers.isSet(.interrupt))
  }
  
  func testSTA() throws {
    cpu.writeMem(at: 0xC1, value: 0xAA)
    cpu.setProgramCounter(0xC1)
    cpu.registers.set(.A, to: 0xFF)
    cpu.STA(mode: .immediate)
    
    let result = cpu.readMem(at: 0xC1)
    XCTAssertEqual(result, 0xFF)
    
  }
  
  func testSTX() throws {
    cpu.writeMem(at: 0xC1, value: 0xAA)
    cpu.setProgramCounter(0xC1)
    cpu.registers.set(.X, to: 0xFF)
    cpu.STX(mode: .immediate)
    
    let result = cpu.readMem(at: 0xc1)
    XCTAssertEqual(result, 0xFF)
  }
  
  func testSTY() throws {
    cpu.writeMem(at: 0xC1, value: 0xAA)
    cpu.setProgramCounter(0xC1)
    cpu.registers.set(.Y, to: 0xF1)
    cpu.STY(mode: .immediate)
    
    let result = cpu.readMem(at: 0xc1)
    XCTAssertEqual(result, 0xF1)
  }
  
  func testTAX() throws {
    cpu.registers.set(.A, to: 0x01)
    cpu.TAX()
    XCTAssertEqual(cpu.registers.A, 0x01)
  }
  
  func testTAX_zero() throws {
    cpu.registers.set(.A, to: 0x0)
    cpu.TAX()
    XCTAssertTrue(cpu.registers.isSet(.zero))
  }
  
  func testTAX_zegative() throws {
    cpu.registers.set(.A, to: 0b1000_0000)
    cpu.TAX()
    XCTAssertTrue(cpu.registers.isSet(.negative))
  }
  
  func testTAY() throws {
    cpu.registers.set(.A, to: 0x01)
    cpu.TAY()
    XCTAssertEqual(cpu.registers.Y, 0x01)
  }
  
  func testTAY_zero() throws {
    cpu.registers.set(.A, to: 0x0)
    cpu.TAY()
    XCTAssertTrue(cpu.registers.isSet(.zero))
  }
  
  func testTAY_zegative() throws {
    cpu.registers.set(.A, to: 0b1000_0000)
    cpu.TAY()
    XCTAssertTrue(cpu.registers.isSet(.negative))
  }
  
  func testTSX() throws {
    cpu.setStackPointer(0xC1)
    cpu.TSX()
    XCTAssertEqual(cpu.registers.X, 0xC1)
  }
  
  func testTSX_zero() throws {
    cpu.setStackPointer(0x0)
    cpu.TSX()
    XCTAssertTrue(cpu.registers.isSet(.zero))
  }
  
  func testTSX_zegative() throws {
    cpu.setStackPointer(0b1000_0001) //
    cpu.TSX()
    XCTAssertTrue(cpu.registers.isSet(.negative))
  }
  
  func testTXA() throws {
      cpu.registers.set(.X, to: 0x01)
      cpu.TXA()
      XCTAssertEqual(cpu.registers.A, 0x01)
  }
  
  func testTXS() throws {
    cpu.registers.set(.X, to: 0xC1)
    cpu.TXS()
    XCTAssertEqual(cpu.getStackPointer(), cpu.registers.X)
  }
  
  func testTYA() throws {
    cpu.registers.set(.Y, to: 0x01)
    cpu.TYA()
    XCTAssertEqual(cpu.registers.A, cpu.registers.Y)
  }
}
