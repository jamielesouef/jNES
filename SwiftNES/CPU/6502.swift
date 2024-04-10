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
    case missingOpcode(String)
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
      
      switch instruction.oppcode {
      case .TAX: self.TAX(addressing: instruction.addressingMode)
      case .LDA: self.LDA(addressing: instruction.addressingMode)
      case .INX: self.INX(addressing: instruction.addressingMode)
        
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
  func INX(addressing: AddressingMode) {
    memory.registers.set(.X, param: memory.registers.X + 1)
    setZeroAndNegativeFlag(memory.registers.X)
  }
  
  func TAX(addressing: AddressingMode) {
    memory.registers.set(.X, param: memory.registers.A)
    setZeroAndNegativeFlag(memory.registers.X)
  }
  
  func LDA(addressing: AddressingMode) {
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


