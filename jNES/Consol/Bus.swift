//
//  6502Memory.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 10/4/2024.
//

import Foundation

final class Bus {
  
  private var sp: UInt8 = 0xFF
  private var cpu_vram: [UInt8] = .init(repeating: 0, count: 0xFFFF)
  
  init(
    buffer: [UInt8] = .init(
      repeating: 0,
      count: 0xFFFF
    )
  ) {
    self.cpu_vram = buffer
  }
  
  func load(program: [UInt8]) {
    cpu_vram.insert(contentsOf: program, at: 0x0600)
    writeMem16(at: 0xFFFC, value: 0x0600)
  }
  
  func readMem(at address: UInt16) -> UInt8 {
    let value = readBuffer(at: address)
    return value
  }
  
  func writeMem(at address: UInt16, value: UInt8) {
    writeBuffer(at: address, value: value)
  }
  
  func readMem16(at address: UInt16) -> UInt16 {
    let lo = readMem(at: address)
    let hi = readMem(at: address + 1)
    
    let ptr = UInt16(hi) << 8 | UInt16(lo)
    return ptr
  }
  
  func writeMem16(at address: UInt16, value: UInt16) {
    let lo = UInt8(value & 0xFF)
    let hi = UInt8(value >> 8)
    
    self.writeMem(at: address, value: lo)
    self.writeMem(at: address + 1, value: hi)
    
  }
  
  func stackPush(_ value: UInt8) {
    let sp = getStackPointer()
    let stackAddress = 0x0100 | UInt16(sp)
    writeMem(at: stackAddress, value: value)
    setStackPointer(sp.subtractingReportingOverflow(1).partialValue)
  }
  
  func stackPush16(_ value: UInt16) {
    let hi = UInt8(value >> 8)
    let lo = UInt8(value & 0xFF)
    
    
    stackPush(hi)
    stackPush(lo)
  }
  
  func stackPop() -> UInt8 {
    let sp = getStackPointer().addingReportingOverflow(1).partialValue
    setStackPointer(sp)
    let value = readMem(at: 0x100 + UInt16(sp))
    return value
  }
  
  func stackPop16() -> UInt16 {
    let lo = UInt16(stackPop())
    let hi = UInt16(stackPop())
    let value = hi << 8 | lo
    return value
  }
  
  func reset() {
   
  }
  
  func writeBuffer(at address: UInt16, value: UInt8) {
    cpu_vram[address] = value
  }
  
  func readBuffer(at address: UInt16) -> UInt8 {
    return cpu_vram[address]
  }
  
  func setStackPointer(_ value: UInt8) {
    sp = value
  }
  
  func getStackPointer() -> UInt8 {
    return sp
  }
}
