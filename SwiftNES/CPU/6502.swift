//
//  6502.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 8/4/2024.
//

import Foundation

final class CPU {
  private (set) var pc: UInt16 = 0x0000
  private (set) var registers: Registers = Registers()
  
  private var mem: [UInt8] = .init(repeating: 0, count: 0xFFFF)
  
  private var loop = true //temport until flags
  
  enum CPUError: Error {
    case invalidOpcode(String)
  }
  
  func run() throws {
    while loop {
      let oppcode: UInt8 = mem[pc]
      self.pc += 1
      
      try dispatch(oppcode)
    }
    
    func dispatch(_ opcode: UInt8) throws {
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
extension CPU {
  
  func load(program: [UInt8]) {
    self.mem.insert(contentsOf: program, at: 0x8000)
    writeMem16(at: 0xFFFC, value: 0x8000)
    reset()
  }
  
  func reset() {
    registers.reset()
    pc = readMem16(at: 0xFFFC)
  }
  
  func readMem(at address: UInt16) -> UInt8 {
    return mem[address]
  }
  
  func writeMem(at address: UInt16, value: UInt8) {
    mem[address] = value
  }
  
  func readMem16(at address: UInt16) -> UInt16 {
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


