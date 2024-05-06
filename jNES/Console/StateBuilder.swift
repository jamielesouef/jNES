//
//  StateBuilder.swift
//  jNES
//
//  Created by Jamie Le Souef on 5/5/2024.
//

import Foundation


final class StateBuilder {
  let cpu: CPU
  let instruction: Instruction
  let address: UInt16
  
  init(cpu: CPU, instruction: Instruction, address: UInt16) {
    self.cpu = cpu
    self.instruction = instruction
    self.address = address
  }
  
  
  func build() -> CPUState {
    let hex: String = (0..<instruction.bytes)
      .map { cpu.readMem(at: address + UInt16($0))}
      .map { String(format: "%02X", $0) }
      .joined(separator: " ")
    
    
    var instructionString: String!
    
    switch instruction.bytes {
    case 1: instructionString = buildSingleBiteInstruction()
    case 2: instructionString = buildTwoBitInstruction()
    case 3: instructionString = buildThreeBitInstruction()
    default: fatalError("Unhandled byte count")
    }
    
    return CPUState(
      address: String(format: "%04X", address),
      hexDump: hex,
      instruction: instructionString,
      registerA: String(format: "A:%02X", cpu.registers.A),
      registerX: String(format: "X:%02X", cpu.registers.X),
      registerY: String(format: "Y:%02X", cpu.registers.Y),
      status: String(format: "P:%02X", cpu.registers.p),
      stackPointer: String(format: "SP:%02X", cpu.bus.getStackPointer())
    )
  }
  
  private func buildSingleBiteInstruction() -> String {
    switch instruction.address {
    case 0x0a, 0x4a, 0x2a, 0x6a: return "\(instruction.name) A"
    default: return instruction.name
    }
  }
  
  private func buildTwoBitInstruction() -> String {
    let (memAdr, data) = getAddressAndValue()
    
    let address: UInt8 = cpu.readMem(at: cpu.PC + 1);
    
    var arg: String!
    
    switch instruction.mode {
    case .immediate :
      arg = String(format: "#$%02X", data)
    case .indirectX, .indirectY:
      let index = instruction.mode == .indirectX ? cpu.registers.X : cpu.registers.Y
      
      arg = String(
        format: "($%02X,X) @ %02X = %04X = %02X",
        address,
        address &+ index,
        memAdr,
        data
      )
      
    case .zeroPage: 
      arg = String(format: "$%02X = %02X", memAdr, data)
      
    case .zeroPageX, .zeroPageY: 
      let index = instruction.mode == .zeroPageX ? "X" : "Y"
      arg = String(format:"$%02X,\(index) @ %02X = %02X",
      address, index, memAdr, data)
    case .none:
      arg = String(format: "$%04X", (cpu.PC + 2) &+ UInt16(address))
    default: fatalError("Unexpected addressing mode \(instruction.mode) \(instruction.name)")
    }
    
    return "\(instruction.name) \(arg!)"
  }
  
  private func buildThreeBitInstruction() -> String {
    
    let address = cpu.readMem16(at: cpu.PC + 1)
    let (memAddr, data) = getAddressAndValue()
    
    var arg: String = ""
    
    switch instruction.mode {
    case .none: 
              arg = String(format: "$%04X", memAddr, cpu.readMem(at: address))
    case .absolute:

        arg = String(format: "$%04X = %02X", memAddr, cpu.readMem(at: address))
      
    case .absoluteX: arg = String(format: "$%04X,X @ %04X = %02X}", data, memAddr, 1231)
    case .absoluteY: arg = String(format: "$%04X,Y @ %04X = %02X}", data, memAddr, 1231)
  
    default: fatalError("Unexpected addressing mode \(instruction.mode) \(instruction.name)")
    }
    
    return "\(instruction.name) \(arg)"
  }
  
  private func getAddressAndValue() -> (UInt16, UInt8) {
//    if instruction.mode == .implied || instruction.mode == .relative {
//      return (0,0)
//    }
    
    let addr = cpu.getAddressForOpperate(with: instruction.mode, at: cpu.PC + 1)
    let mem = cpu.readMem(at: addr)
    return (addr, mem)
  }
  
}
