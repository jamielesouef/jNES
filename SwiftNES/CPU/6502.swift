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
  
  
  func interpret(program: Array<UInt8>) {
    self.mem = program
    self.pc = 0
    
    while run {
      let oppcode: UInt8 = mem[pc]
      self.pc += 1
      
      switch oppcode {
      case 0xAA: self.TAX()
      case 0xA9: self.LDA()
      case 0xE8: self.INX()
        
      case 0x00: run = false
      default: run = false
      }
    }
  }
}
// instructions
private extension CPU {
  func INX() {
    registers.set(.X, param: registers.X + 1)
    setZeroFlag(registers.X)
    setNegativeFlag(registers.X)
  }
  
  func TAX() {
    //Copies the current contents of the accumulator into the X register and sets the zero and negative flags as appropriate.
    
    registers.set(.X, param: registers.A)
    setZeroFlag(registers.X)
    setNegativeFlag(registers.X)
  }
  
  func LDA() {
    let param: UInt8 = mem[pc]
    pc += 1
    registers.set(.A, param: param)
    
    setZeroFlag(param)
    setNegativeFlag(param)
    
    if registers.A & (1 << 7) != 0 {
      registers.set(.negative)
    } else {
      registers.unset(.negative)
    }
  }
}

// Helpers

private extension CPU {
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


