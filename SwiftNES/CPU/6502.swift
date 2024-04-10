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
  
  let memory: Memory = Memory()
  
  private var loop = true //temport until flags
  
  enum CPUError: Error {
    case invalidOpcode(String)
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

// MARK: Instructions
private extension CPU {
  func INX() {
    memory.registers.set(.X, param: memory.registers.X + 1)
    setZeroAndNegativeFlag(memory.registers.X)
  }
  
  func TAX() {
    memory.registers.set(.X, param: memory.registers.A)
    setZeroAndNegativeFlag(memory.registers.X)
  }
  
  func LDA() {
    let param: UInt8 = memory.readMemAtCounter()
    memory.pc += 1
    memory.registers.set(.A, param: param)
    
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


