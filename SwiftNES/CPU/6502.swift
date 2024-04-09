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

  func interpret(program: Array<UInt8>) {
    self.pc = 0x00
    let oppcode: UInt8 = program[Int(self.pc)]
    self.pc += 1
    
    switch oppcode {
      case 0x0A: self.LDA()
      default: break
    }
  }
}

private extension CPU {
  func LDA() {
    
  }
}
