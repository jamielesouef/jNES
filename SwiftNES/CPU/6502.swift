//
//  6502.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 8/4/2024.
//

import Foundation

final class CPU {
  typealias MemoryAddress = UInt16
  typealias Opperand = UInt8
  typealias Oppcode = UInt8
  
  private (set) var pc: MemoryAddress = 0x0000
  private (set) var registers: Registers = Registers()
  
  private var mem: [UInt8] = .init(repeating: 0, count: 0xFFFF)
  
  private var loop = true //temport until flags
  
  enum AddressingIndex {
    case X
    case Y
  }
  
  enum CPUError: Error {
    case invalidOpcode(String)
  }
  
  func run() throws {
    while loop {
      let oppcode: UInt8 = mem[pc]
      self.pc += 1
      
      try dispatch(oppcode)
    }
    
    func dispatch(_ opcode: Oppcode) throws {
      switch opcode {
      case 0xAA: self.TAX()
      case 0xA9: self.LDA()
      case 0xE8: self.INX()
        
      case 0x00: loop = false
      default:
        loop = false
        throw CPUError.invalidOpcode(String(opcode, radix: 16))
      }
    }
  }
}
// MARK: Memory Access

enum AddressingMode {
  case immediate
  case zeroPage
  case zeroPageX
  case zeroPageY
  case absolute
  case absoluteX
  case absoluteY
  case indirect
  case indirectIndexed
  case relative
}

extension CPU {
  
  private func getRegisterValue(for register: AddressingIndex) -> UInt8 {
    switch register {
    case .X: return registers.X
    case .Y: return registers.Y
    }
  }
  
  private func getZeroPage(for register: AddressingIndex) -> MemoryAddress {
    let operand = readMem(at: pc)
    var registerValue: UInt8 = getRegisterValue(for: register)
    
    return MemoryAddress(operand.addingReportingOverflow(registerValue).partialValue)
  }
  
  private func getAbsolute(for register: AddressingIndex) -> MemoryAddress {
    let operand = readMem16(at: pc)
    var registerValue: MemoryAddress = MemoryAddress(getRegisterValue(for: register))
    
    return MemoryAddress(operand.addingReportingOverflow(registerValue).partialValue)
  }
  
  func getOpperandAddress(for mode: AddressingMode) -> MemoryAddress {
    switch mode {
    case .immediate:
      return pc
    case .zeroPage:
      return MemoryAddress(readMem(at: pc))
    case .zeroPageX: return getZeroPage(for: .X)
    case .zeroPageY: return getZeroPage(for: .Y)
    case .relative:
      <#code#>
    case .absolute:
      return readMem16(at: pc)
    case .absoluteX:
      <#code#>
    case .absoluteY:
      <#code#>
    case .indirect:
      <#code#>
    case .indirectIndexed:
      <#code#>
    }
  }
  
  func load(program: [UInt8]) {
    self.mem.insert(contentsOf: program, at: 0x8000)
    writeMem16(at: 0xFFFC, value: 0x8000)
    reset()
  }
  
  func reset() {
    registers.reset()
    pc = readMem16(at: 0xFFFC)
  }
  
 
  
  func readMem(at address: MemoryAddress) -> Opperand {
    return mem[address]
  }
  
  func writeMem(at address: MemoryAddress, value: Opperand) {
    mem[address] = value
  }
  
  func readMem16(at address: MemoryAddress) -> MemoryAddress {
    return UInt16(mem[address]) | UInt16(mem[address + 1]) << 8
  }
  
  func writeMem16(at address: UInt16, value: UInt16) {
    mem[address] = UInt8(value & 0xFF)
    mem[address + 1] = UInt8(value >> 8)
  }
}

// MARK: Instructions
private extension CPU {
  func INX() {
    registers.set(.X, param: registers.X + 1)
    setZeroAndNegativeFlag(registers.X)
  }
  
  func TAX() {
    registers.set(.X, param: registers.A)
    setZeroAndNegativeFlag(registers.X)
  }
  
  func LDA() {
    let param: UInt8 = mem[pc]
    pc += 1
    registers.set(.A, param: param)
    
    setZeroAndNegativeFlag(param)
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
      registers.set(.zero)
    } else {
      registers.unset(.zero)
    }
  }
  
  func setNegativeFlag(_ value: UInt8) {
    if value & (1 << 7) != 0 {
      registers.set(.negative)
    } else {
      registers.unset(.negative)
    }
  }
}


