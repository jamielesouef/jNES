//
//  6502Memory.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 10/4/2024.
//

import Foundation

enum AddressingMode {
  case accumulator
  case immediate
  case zeroPage
  case zeroPageX
  case zeroPageY
  case absolute
  case absoluteX
  case absoluteY
  case indirectX
  case indirectY
  case relative
  case implied
  case indirect
}

final class Memory {
 
  var pc: MemoryAddress = 0x0000
  
  private var buffer: [UInt8] = .init(repeating: 0, count: 0xFFFF)
  
  private (set) var registers: Registers = Registers()
  
  enum AddressingIndex {
    case X
    case Y
  }
  
  init(
    registers: Registers = Registers(),
    buffer: [UInt8] = .init(
      repeating: 0,
      count: 0xFFFF
    )
  ) {
    self.registers = registers
    self.buffer = buffer
  }
  
  func getOpperandAddress(for mode: AddressingMode) -> MemoryAddress {
    switch mode {
    case .immediate:  return pc
    case .zeroPage:   return MemoryAddress(readMem(at: pc))
    case .zeroPageX:  return getZeroPage(offsetBy: .X)
    case .zeroPageY:  return getZeroPage(offsetBy: .Y)
    case .absolute:   return readMem16(at: pc)
    case .absoluteX: return getAbsolute(offsetBy: .X)
    case .absoluteY: return getAbsolute(offsetBy: .Y)
    case .indirectX: return indirectX()
    case .indirectY: return indirectX()
    default: fatalError("Addressing mode: \(mode) not implemented")
    }
  }
  
  func load(program: [UInt8]) {
    buffer.insert(contentsOf: program, at: 0x8000)
    writeMem16(at: 0xFFFC, value: 0x8000)
    reset()
  }
  
  func reset() {
    registers.reset()
    pc = readMem16(at: 0xFFFC)
  }
  
  func readMemAtCounter() -> UInt8 {
    readMem(at: pc)
  }
  
  func readMem(at address: MemoryAddress) -> UInt8 {
    buffer[address]
  }
  
  func writeMem(at address: MemoryAddress, value: UInt8) {
    buffer[address] = value
  }
  
  func readMem16(at address: MemoryAddress) -> MemoryAddress {
    let lo = readMem(at: address)
    let hi = readMem(at: address.addingReportingOverflow(1).partialValue)
    
    let ptr = UInt16(hi) << 8 | UInt16(lo)
    return ptr
  }
  
  func writeMem16(at address: UInt16, value: UInt16) {
    buffer[address] = UInt8(value & 0xFF)
    buffer[address + 1] = UInt8(value >> 8)
  }
}

private extension Memory {
  
  func getRegisterValue(for register: AddressingIndex) -> UInt8 {
    switch register {
    case .X: return registers.X
    case .Y: return registers.Y
    }
  }
  
  func getZeroPage(offsetBy register: AddressingIndex) -> MemoryAddress {
    let operand: Operand = readMem(at: pc)
    let registerValue: ZeroMemoryAddress = getRegisterValue(for: register)
    
    return MemoryAddress(operand.addingReportingOverflow(registerValue).partialValue)
  }
  
  func getAbsolute(offsetBy register: AddressingIndex) -> MemoryAddress {
    let address: MemoryAddress = readMem16(at: pc)
    let registerValue: MemoryAddress = MemoryAddress(getRegisterValue(for: register))
    
    return MemoryAddress(address.addingReportingOverflow(registerValue).partialValue)
  }
  
  func indirectX() -> MemoryAddress {
    let base: ZeroMemoryAddress = readMem(at: pc)
    let pointer: ZeroMemoryAddress = base.addingReportingOverflow(registers.X).partialValue
    let lo: UInt8 = readMem(at: MemoryAddress(pointer))
    let hi: UInt8 = readMem(at: MemoryAddress(pointer.addingReportingOverflow(1).partialValue))
    let ptr = UInt16(hi) << 8 | UInt16(lo)
    return ptr
  }
  
  func indirectY() -> MemoryAddress {
    let lo = readMem(at: pc)
    let hi = readMem(at: pc + 1)
    let pointer = UInt16(hi) << 8 | UInt16(lo)
    return pointer.addingReportingOverflow(UInt16(registers.Y)).partialValue
  }
}
