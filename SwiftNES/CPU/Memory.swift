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

final class Memory {
  
  var pc: UInt16 = 0x0000
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
  
  func getAddress(for mode: AddressingMode) -> UInt16 {
    
    log("addressingMode \(mode.rawValue)")
    switch mode {
    case .accumulator:
      return UInt16(registers.A)
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
  }
  
  func getProgramCounter() -> UInt16 {
    return pc
  }
  
  func __debug_getInstructionsBuffer() -> [String] {
    instructionsBuffer.reversed().map {
      let hex = String($0, radix: 16)
      let op = _debug_compiledSnake[$0] ?? ""
      
      return "\(hex):\(op)"
    }
  }
  
  func __debug_updateInstructionsBuffer() {
    
    guard _debug_compiledSnake.keys.contains(pc) else {
      return
    }
    
    if instructionsBuffer.count == 1000 {
      let _ = instructionsBuffer.popLast()
    }
    
    instructionsBuffer.insert(pc, at: 0)
    
  }
  
}

private extension Memory {

  
  // MARK: - Addressing mode
  
  func indirectX() -> UInt16 {
    let storedAddress: UInt8 = readMem(at: pc)
    let addr = storedAddress.addingReportingOverflow(registers.X).partialValue
    
    let lo = UInt16(readMem(at: UInt16(addr)))
    let hi = UInt16(readMem(at: UInt16(addr.addingReportingOverflow(1).partialValue)))
    let ptr = (hi << 8) | lo
    return ptr
  }
  
  func indirectY() -> UInt16 {
    let storedAddress = UInt16(readMem(at: pc))
    let lo: UInt8 = readMem(at: storedAddress)
    let hi: UInt8 = readMem(at: storedAddress.addingReportingOverflow(1).partialValue)
    let pointer = UInt16(hi) << 8 | UInt16(lo)
    return pointer.addingReportingOverflow(UInt16(registers.Y)).partialValue
  }
}
