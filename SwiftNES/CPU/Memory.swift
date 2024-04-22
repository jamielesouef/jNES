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
  func getAddress(for mode: AddressingMode) -> MemoryAddress
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
  func getProgramCounter() -> UInt16
  
  func setStackPointer(_ value: UInt8)
  func getStackPointer() -> UInt8
  func readMemAtCounter() -> UInt8
  func reset()
}


extension MemoryInjectable where Self: AnyObject {
  
  func readMem(at address: MemoryAddress) -> UInt8 {
    let value = readBuffer(at: address)
    log("address, value", address, UInt16(value), r: 16)
    return value
  }
  
  func writeMem(at address: MemoryAddress, value: UInt8) {
    writeBuffer(at: address, value: value)
    log("address, value", address, UInt16(value))
  }
  
  func readMem16(at address: MemoryAddress) -> MemoryAddress {
    let lo = readMem(at: address)
    let hi = readMem(at: address + 1)
    
    let ptr = UInt16(hi) << 8 | UInt16(lo)
    return ptr
  }
  
  func writeMem16(at address: UInt16, value: UInt16) {
    let lo = UInt8(value & 0xFF)
    let hi = UInt8(value >> 8)
    
    log("hi, lo", hi, lo)
    self.writeMem(at: address, value: lo)
    self.writeMem(at: address + 1, value: hi)
    
  }

  func stackPush(_ value: UInt8) {
    let sp = getStackPointer()
    let stackAddress = 0x0100 | UInt16(sp)
    writeMem(at: stackAddress, value: value)
    setStackPointer(sp.subtractingReportingOverflow(1).partialValue)
    log("stackAddress, value", stackAddress, UInt16(value))
  }
  
  func stackPush16(_ value: UInt16) {
    let hi = UInt8(value >> 8)
    let lo = UInt8(value & 0xFF)
    
    log("lo hi, value", UInt16(lo), UInt16(hi), value ,r: 16)
    
    stackPush(hi)
    stackPush(lo)
  }
  
  func stackPop() -> UInt8 {
    let sp = getStackPointer().addingReportingOverflow(1).partialValue
    setStackPointer(sp)
    let value = readMem(at: 0x100 + UInt16(sp))
    log("value", value)
    return value
  }
  
  func stackPop16() -> UInt16 {
    let lo = UInt16(stackPop())
    let hi = UInt16(stackPop())
    let value = hi << 8 | lo
    log("lo, hi, value", lo, hi, value)
    return value
  }
  
  func reset() {
    registers.reset()
    setProgramCounter(readMem16(at: 0xFFFC))
  }
}

final class Memory {
  
  var pc: MemoryAddress = 0x0000
  let registers: Registers
  
  private var sp: UInt8 = 0xFF
  private var buffer: [UInt8] = .init(repeating: 0, count: 0xFFFF)
  
  var instructionsBuffer: [UInt16] = []
  
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
  
  func getAddress(for mode: AddressingMode) -> MemoryAddress {
    
    log("addressingMode \(mode.rawValue)")
    switch mode {
    case .accumulator:
      return 0x0000
    case .absolute:
      return readMem16(at: pc)
    case .immediate:
      return pc
    case .zeroPage:
      return UInt16(readMem(at: pc))
    case .zeroPageX:
      let data: UInt8 = readMem(at: pc)
      let addr = data.addingReportingOverflow(registers.X).partialValue
      return UInt16(addr)
    case .zeroPageY:
      let data: UInt8 = readMem(at: pc)
      let addr = data.addingReportingOverflow(registers.Y).partialValue
      return UInt16(addr)
    case .absoluteX:
      let data = readMem16(at: pc)
      let addr = data.addingReportingOverflow(UInt16(registers.X)).partialValue
      return addr
    case .absoluteY:
      let data = readMem16(at: pc)
      let addr = data.addingReportingOverflow(UInt16(registers.Y)).partialValue
      return addr
    case .indirectX: 
      return indirectX()
    case .indirectY:
      return indirectY()
    default: fatalError("Addressing mode: \(mode) not implemented")
    }
    
  }
  
  func load(program: [UInt8]) {
    buffer.insert(contentsOf: program, at: 0x0600)
    writeMem16(at: 0xFFFC, value: 0x0600)
  }
  
  func reset() {
    registers.reset()
    setProgramCounter(readMem16(at: 0xFFFC))
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
    log("sp", sp)
    sp = value
  }
  
  func getStackPointer() -> UInt8 {
    return sp
  }
  
  func setProgramCounter(_ value: UInt16) {
    log("value", value)
    pc = value
    
    updateInstructionsBuffer()
  }
  func getProgramCounter() -> UInt16 {
    return pc
  }
  
  func _debug_getInstructionsBuffer() -> [String] {
    instructionsBuffer.reversed().map {
      let hex = String($0, radix: 16)
      let op = _debug_compiledSnake[$0] ?? ""
      
      return "\(hex):\(op)"
    }
  }
}

private extension Memory {
  func updateInstructionsBuffer() {
    
    guard _debug_compiledSnake[pc] != nil else {
      return
    }
    
    if instructionsBuffer.count == 100 {
      let _ = instructionsBuffer.popLast()
    }
    
    instructionsBuffer.insert(pc, at: 0)
    
  }
  
  // MARK: - Addressing mode
  
  func indirectX() -> MemoryAddress {
    let storedAddress: UInt8 = readMem(at: pc)
    let addr = storedAddress.addingReportingOverflow(registers.X).partialValue
    
    let lo = UInt16(readMem(at: MemoryAddress(addr)))
    let hi = UInt16(readMem(at: MemoryAddress(addr.addingReportingOverflow(1).partialValue)))
    let ptr = (hi << 8) | lo
    return ptr
  }
  
  func indirectY() -> MemoryAddress {
    let storedAddress = UInt16(readMem(at: pc))
    let lo: UInt8 = readMem(at: storedAddress)
    let hi: UInt8 = readMem(at: storedAddress.addingReportingOverflow(1).partialValue)
    let pointer = UInt16(hi) << 8 | UInt16(lo)
    return pointer.addingReportingOverflow(UInt16(registers.Y)).partialValue
  }
}
