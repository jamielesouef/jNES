//
//  6502.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 8/4/2024.
//

import Foundation

typealias Operand = UInt8
typealias Oppecode = UInt8
typealias MemoryAddress = UInt16
typealias ZeroMemoryAddress = UInt8



final class CPU {
  
  let memory: Memory
  
  private var loop = true //temport until flags
  private var addressingMode: AddressingMode? = nil
  
  enum CPUError: Error {
    case invalidOpcode(String)
    case missingOpcode(String)
  }
  
  init(memory: Memory = Memory()) {
    self.memory = memory
  }

  func load(program: [UInt8]) {
    memory.load(program: program)
  }
  
  func run() throws {
    while loop {
      let oppcode: UInt8 = memory.readMemAtCounter()
      l(oppcode, r: 16)
      memory.pc += 1
      
      try dispatch(oppcode)
    }
    
    func dispatch(_ opcode: UInt8) throws {
      let instruction = getInstructions(forOpcode: opcode)
      self.addressingMode = instruction.addressingMode
      instruction.fn()
    }
  }
}

// MARK: Instructions
private extension CPU {
  func unsafeGetAddresingMode() -> AddressingMode {
    guard let mode = self.addressingMode else {
      fatalError("Addressing mode not set")
    }
    
    self.addressingMode = nil
    return mode
  }
  
  func loadByteFromMemory() -> UInt8 {
    let addressingMode = unsafeGetAddresingMode()
    
    if addressingMode == .accumulator {
      return memory.registers.A
    }
    
    let addr = memory.getOpperandAddress(for: addressingMode)
    let byte = memory.readMem(at: addr)
    memory.pc += 1
    return byte
  }
  
  func signedValue(from byte: UInt8) -> (UInt8, Bool) {
    let isSigned = byte & 0b1000_0000 != 0
    return (byte & 0b0111_1111, isSigned)
  }
  
  func branch(when condition: Bool) {
    if condition {
      let offset: UInt8 = memory.readMem(at: memory.pc)
      let (singedValue, isSigned): (UInt8, Bool) = signedValue(from: offset)
      
      memory.pc = UInt16(isSigned
      ? offset.subtractingReportingOverflow(singedValue).partialValue
      : offset.addingReportingOverflow(singedValue).partialValue)
    }
  }
}
 
extension CPU {
  func ADC() {
    // A,Z,C,N = A+M+C
    
    let param = UInt16(loadByteFromMemory())
    
    let carry: UInt16 = memory.registers.isSet(.carry) ? 1 : 0
    let a = UInt16(memory.registers.A)
    let result = a + param + carry

    if result > 0xFF {
      memory.registers.set(.carry)
    } else {
      memory.registers.unset(.carry)
    }
    
    memory.registers.set(.accumulator, to: UInt8(result & 0xFF))
    
    setZeroAndNegativeFlag(memory.registers.A)
  }
    
  func AND() {
    //A,Z,N = A&M
    let param = loadByteFromMemory()
    let result = memory.registers.A & param
    memory.registers.set(.accumulator, to: result)
  }
  
  func ASL() {
    let param = loadByteFromMemory()
    let bit7 = param >> 7
    let result = memory.registers.A << 1

    if bit7 == 0 {
      memory.registers.unset(.carry)
    } else {
      memory.registers.set(.carry)
    }
    
    memory.registers.set(.accumulator, to: result)
    setZeroAndNegativeFlag(result)
  
  }
  
  func BCC() {
    branch(when: memory.registers.isSet(.carry))
  }
  
  func BCS() {
    branch(when: !memory.registers.isSet(.carry))
  }
  
  func BEQ() {
    branch(when: memory.registers.isSet(.zero))
  }
  
  func BIT() {
    let param = loadByteFromMemory()
    let a = memory.registers.A
    
    let result = param & a
    setZeroAndNegativeFlag(result)
    setOverflowFlag(result)
  }
  
  func BMI() {
    branch(when: memory.registers.isSet(.negative))
  }
  
  func BNE() {
    branch(when: !memory.registers.isSet(.zero))
  }
  
  func BPL() {
    fatalError("BPL Not Implimented")
  }
  
  func BRK() {
    loop = false
  }
  
  func BVC() {
    fatalError("BVC Not Implimented")
  }
  
  func BVS() {
    fatalError("BVS Not Implimented")
  }
  
  func CLC() {
    fatalError("CLC Not Implimented")
  }
  
  func CLD() {
    fatalError("CLD Not Implimented")
  }
  
  func CLI() {
    fatalError("CLI Not Implimented")
  }
  
  func CLV() {
    fatalError("CLV Not Implimented")
  }
  
  func CMP() {
    fatalError("CMP Not Implimented")
  }
  
  func CPX() {
    fatalError("CPX Not Implimented")
  }
  
  func CPY() {
    fatalError("CPY Not Implimented")
  }
  
  func DEC() {
    fatalError("DEC Not Implimented")
  }
  
  func DEY() {
    fatalError("DEY Not Implimented")
  }
  
  func EOR() {
    fatalError("EOR Not Implimented")
  }
  
  func INC() {
    fatalError("INC Not Implimented")
  }
  
  func INX() {
    let newX = memory.registers.X.addingReportingOverflow(1).partialValue
    memory.registers.set(.X, to: newX)
    setZeroAndNegativeFlag(memory.registers.X)
  }
  
  func INY() {
    fatalError("INY Not Implimented")
  }
  
  
 
  
  func JMP() {
    fatalError("JMP Not Implimented")
  }
  
  func JSR() {
    fatalError("JSR Not Implimented")
  }
  
  func LDA() {
    let param = loadByteFromMemory()
    memory.registers.set(.accumulator, to: param)
    setZeroAndNegativeFlag(param)
  }
  
  func LDX() {
    fatalError("LDX Not Implimented")
  }
  
  func LDY() {
    fatalError("LDY Not Implimented")
  }
  
  func LSR() {
    fatalError("LSR Not Implimented")
  }
  
  func NOP() {
    fatalError("NOP Not Implimented")
  }
  
  func ORA() {
    fatalError("ORA Not Implimented")
  }
  
  func PHA() {
    fatalError("PHA Not Implimented")
  }
  
  func PHP() {
    fatalError("PHP Not Implimented")
  }
  
  func PLA() {
    fatalError("PLA Not Implimented")
  }
  
  func PLP() {
    fatalError("PLP Not Implimented")
  }
  
  func ROL() {
    fatalError("ROL Not Implimented")
  }
  
  func ROR() {
    fatalError("ROR Not Implimented")
  }
  
  func RTI() {
    fatalError("RTI Not Implimented")
  }
  
  func RTS() {
    fatalError("RTS Not Implimented")
  }
  
  func SBC() {
    fatalError("SBC Not Implimented")
  }
  
  func SEC() {
    fatalError("SEC Not Implimented")
  }
  
  func SED() {
    fatalError("SED Not Implimented")
  }
  
  func SEI() {
    fatalError("SEI Not Implimented")
  }
  
  func STA() {
    fatalError("STA Not Implimented")
  }
  
  func STX() {
    fatalError("STX Not Implimented")
  }
  
  func STY() {
    fatalError("STY Not Implimented")
  }
  
  func TAX() {
    memory.registers.set(.X, to: memory.registers.A)
    setZeroAndNegativeFlag(memory.registers.X)
  }

  func TAY() {
    fatalError("TAY Not Implimented")
  }
  
  func TSX() {
    fatalError("TSX Not Implimented")
  }
  
  func TXA() {
    fatalError("TXA Not Implimented")
  }
  
  func TXS() {
    fatalError("TXS Not Implimented")
  }
  
  func TYA() {
    fatalError("TYA Not Implimented")
  }
  
  func DEX() {
    fatalError("DEX Not ImplimentedlError")
  }
}

// Helpers

private extension CPU {
  func setZeroAndNegativeFlag(_ value: UInt8) {
    setZeroFlag(value)
    setNegativeFlag(value)
  }
  
  func setZeroFlag(_ value: UInt8) {
    if value == 0 {
      memory.registers.set(.zero)
    } else {
      memory.registers.unset(.zero)
    }
  }
  
  func setNegativeFlag(_ value: UInt8) {
    if value & (1 << 7) != 0 {
      memory.registers.set(.negative)
    } else {
      memory.registers.unset(.negative)
    }
  }
  
  func setOverflowFlag(_ value: UInt8) {
    if (value & 0b0100_0000) > 0 {
      memory.registers.set(.overflow)
    } else {
      memory.registers.unset(.overflow)
    })
    
  }
}


