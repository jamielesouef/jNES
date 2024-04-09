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
  
  private var mem: [UInt8] = []
  
  private var run = true //temport until flags
  
  enum CPUError: Error {
    case invalidOpcode(String)
  }
  func interpret(program: Array<UInt8>) throws {
    self.mem = program
    self.pc = 0
    
    while run {
      let oppcode: UInt8 = mem[pc]
      self.pc += 1
      
      try dispatch(oppcode)
    }
    
    func dispatch(_ opcode: UInt8) throws {
      switch opcode {
      case 0xAA: self.TAX()
      case 0xA9: self.LDA()
      case 0xE8: self.INX()
        
      case 0x00: run = false
      default:
        run = false
        throw CPUError.invalidOpcode(String(opcode, radix: 16))
      }
    }
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


