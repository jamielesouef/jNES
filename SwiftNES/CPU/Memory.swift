//
//  6502Memory.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 10/4/2024.
//

import Foundation

enum AddressingMode: String {
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

protocol MemoryInjectable {
  var registers: Registers { get}
  func getOpperandAddress(for mode: AddressingMode) -> MemoryAddress
  func load(program: [UInt8])
  func readMem(at address: MemoryAddress) -> UInt8
  func readMem16(at address: MemoryAddress) -> MemoryAddress
  func writeMem(at address: MemoryAddress, value: UInt8)
  func writeMem16(at address: UInt16, value: UInt16)
  func stackPush(_ value: UInt8)
  func stackPop() -> UInt8
  func stackPush16(_ value: UInt16)
  func stackPop16() -> UInt16
  
  func writeBuffer(at address: UInt16, value: UInt8)
  func readBuffer(at address: UInt16) -> UInt8
  
  func setProgramCounter(_ value: UInt16)
  func getprogramCounter() -> UInt16
  func incrementProgramCounter()
  
  func setStackPointer(_ value: UInt8)
  func getStackPointer() -> UInt8
  func readMemAtCounter() -> UInt8
}


extension MemoryInjectable where Self: AnyObject {
  
  private func truncate(address: MemoryAddress) -> MemoryAddress {
    let truncated = UInt8(truncatingIfNeeded: address)
    return MemoryAddress(truncated)
  }
  
  func readMem(at address: MemoryAddress) -> UInt8 {
    let tructatedAddress = truncate(address: address)
    return readBuffer(at: tructatedAddress)
  }
  
  func writeMem(at address: MemoryAddress, value: UInt8) {
    let tructatedAddress = truncate(address: address)
    writeBuffer(at: tructatedAddress, value: value)
  }
  
  func readMem16(at address: MemoryAddress) -> MemoryAddress {
    let lo = readMem(at: address)
    let hi = readMem(at: address.addingReportingOverflow(1).partialValue)
    
    let ptr = UInt16(hi) << 8 | UInt16(lo)
    log("lo, hi, address", UInt16(lo), UInt16(hi), address, r: 16)
    return ptr
  }
  
  func writeMem16(at address: UInt16, value: UInt16) {
    let lo = UInt8(value & 0xFF)
    let hi = UInt8(value >> 8)
    self.writeMem(at: address, value: lo)
    self.writeMem(at: address.addingReportingOverflow(1).partialValue , value: hi)
    
    log("lo, hi, address", UInt16(lo), UInt16(hi), address)
  }
  
  func stackPush(_ value: UInt8) {
    let sp = getStackPointer()
    log("sp, value", sp, value)
    writeMem(at: 0x0100 + UInt16(sp), value: value)
    setStackPointer(sp.subtractingReportingOverflow(1).partialValue)
    
  }
  
  func stackPop() -> UInt8 {
    let sp = getStackPointer().addingReportingOverflow(1).partialValue
    setStackPointer(sp)
    let value = readMem(at: 0x100 + UInt16(sp))
    log("sp, value", sp, value)
    return value
  }
  
  func stackPush16(_ value: UInt16) {
    let hi = UInt8(value >> 8)
    let lo = UInt8(value & 0xFF)
    
    log("lo hi, value", UInt16(lo), UInt16(hi), value ,r: 16)

    stackPush(hi)
    stackPush(lo)
    
  
  }
  
  func stackPop16() -> UInt16 {
    let lo = UInt16(stackPop())
    let hi = UInt16(stackPop())
    let value = hi << 8 | lo
    log("lo, hi, value", lo, hi, value)
    return value
  }
}

final class Memory {
  
  var pc: MemoryAddress = 0x0000
  let registers: Registers
  
  private var sp: UInt8 = 0xFF
  private var buffer: [UInt8] = .init(repeating: 0, count: 0xFFFF)
  
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
    case .accumulator: return 0x0000
    case .immediate:  return pc
    case .zeroPage:   return MemoryAddress(readMem(at: pc))
    case .zeroPageX:  return getZeroPage(offsetBy: .X)
    case .zeroPageY:  return getZeroPage(offsetBy: .Y)
    case .absolute:   return readMem16(at: pc)
    case .absoluteX: return getAbsolute(offsetBy: .X)
    case .absoluteY: return getAbsolute(offsetBy: .Y)
    case .indirectX: return indirectX()
    case .indirectY: return indirectY()
    default: fatalError("Addressing mode: \(mode) not implemented")
    }
  }
  
  func load(program: [UInt8]) {
    let insertionPoint: MemoryAddress = 0x0000
    
    for (i, v) in program.enumerated() {
      buffer[insertionPoint + UInt16(i)] = v
    }
    
    writeMem16(at: 0xFFFC, value: insertionPoint)
    pc = insertionPoint
    reset()
  }
  
  func reset() {
    registers.reset()
    
  }
  
  func readMemAtCounter() -> UInt8 {
    buffer[pc]
  }
}

extension Memory: MemoryInjectable {
  func writeBuffer(at address: UInt16, value: UInt8) {
    buffer[address] = value
  }
  
  func readBuffer(at address: UInt16) -> UInt8 {
    return buffer[address]
  }
  
  func setStackPointer(_ value: UInt8) {
    sp = value
  }
  
  func getStackPointer() -> UInt8 {
    return sp
  }
  
  func setProgramCounter(_ value: UInt16) {
    pc = value
  }
  func getprogramCounter() -> UInt16 {
    return pc
  }
  
  func incrementProgramCounter() {
    pc += 1
  }
  
}

private extension Memory {
  
  func getRegisterValue(for register: AddressingIndex) -> UInt8 {
    switch register {
    case .X: return registers.X
    case .Y: return registers.Y
    }
  }
  
  // MARK: - Addressing mode
  
  func getZeroPage(offsetBy register: AddressingIndex) -> MemoryAddress {
    let operand: Operand = readMem(at: pc)
    let registerValue: ZeroMemoryAddress = getRegisterValue(for: register)
    
    return MemoryAddress(operand.addingReportingOverflow(registerValue).partialValue)
  }
  
  func getAbsolute(offsetBy register: AddressingIndex) -> MemoryAddress {
    let address: MemoryAddress = readMem16(at: pc)
    let offsetValue: MemoryAddress = MemoryAddress(getRegisterValue(for: register))
    
    return MemoryAddress(address.addingReportingOverflow(offsetValue).partialValue)
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
