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
      memory.pc += 1
      
      try dispatch(oppcode)
    }
    
    func dispatch(_ opcode: UInt8) throws {
      guard let instruction = InstructionTable[opcode] else {
        throw CPUError.missingOpcode(String(opcode, radix: 16))
      }
      
      self.addressingMode = instruction.addressingMode
      
      switch instruction.oppcode {
      case .ADC: self.ADC()
      case .INX: self.INX()
      case .LDA: self.LDA()
      case .TAX: self.TAX()
      case .BRK: loop = false
      default:
        loop = false
        throw CPUError.invalidOpcode(String(opcode, radix: 16))
      }
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
    let addr = memory.getOpperandAddress(for: unsafeGetAddresingMode())
    let byte = memory.readMem(at: addr)
    memory.pc += 1
    return byte
  }
  
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
    
    memory.registers.set(.A, to: UInt8(result & 0xFF))
    
    setZeroAndNegativeFlag(memory.registers.A)
  }
  
  func INX() {
    memory.registers.set(.X, to: memory.registers.X + 1)
    setZeroAndNegativeFlag(memory.registers.X)
  }
  
  func TAX() {
    memory.registers.set(.X, to: memory.registers.A)
    setZeroAndNegativeFlag(memory.registers.X)
  }
  
  func LDA() {

    let param = loadByteFromMemory()
    
    memory.registers.set(.A, to: param)
    
    setZeroAndNegativeFlag(param)
  }
  
  func AND() {
    //A,Z,N = A&M
    fatalError("AND Not Implimented")
  }
  
  func ASL() {
    fatalError("ASL Not Implimented")
  }
  
  func BCC() {
    fatalError("BCC Not Implimented")
  }
  
  func BCS() {
    fatalError("BCS Not Implimented")
  }
  
  func BEQ() {
    fatalError("BEQ Not Implimented")
  }
  
  func BIT() {
    fatalError("BIT Not Implimented")
  }
  
  func BMI() {
    fatalError("BMI Not Implimented")
  }
  
  func BNE() {
    fatalError("BNE Not Implimented")
  }
  
  func BPL() {
    fatalError("BPL Not Implimented")
  }
  
  func BRK() {
    fatalError("BRK Not Implimented")
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
  
  func INY() {
    fatalError("INY Not Implimented")
  }
  
  func JMP() {
    fatalError("JMP Not Implimented")
  }
  
  func JSR() {
    fatalError("JSR Not Implimented")
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
}


