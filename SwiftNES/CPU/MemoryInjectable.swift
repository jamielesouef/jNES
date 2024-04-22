//
//  MemoryInjectable.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 22/4/2024.
//

import Foundation

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
