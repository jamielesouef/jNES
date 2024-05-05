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
    case 1: instructionString = instruction.name
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
  
  private func buildTwoBitInstruction() -> String {
    let (addr, value) = getAddressAndValue()
    
    let rAddress: UInt8 = cpu.readMem(at: cpu.PC + 1);
    
    let arg = switch instruction.mode {
    case .immediate : String(format: "#$%02X", value)
    case .indirectX:
      String(
        format: "($%02X,X) @ %02X = %04X = %02X",
        address,
        address.addingReportingOverflow(
          UInt16(cpu.registers.X)).partialValue,
        addr,
        value
      )
      
    case .indirectY:
      String(
        format: "($%02X,X) @ %02X = %04X = %02X",
        address,
        address.addingReportingOverflow(
          UInt16(cpu.registers.Y)).partialValue,
        addr,
        value
      )
    case .zeroPage: String(format: "$%02X = %02X", addr, value)
    case .none: String(format: "$%04X", (cpu.PC + 2).addingReportingOverflow(UInt16(rAddress)).partialValue)
    default: fatalError("Unexpected addressing mode \(instruction.mode) \(instruction.name)")
    }
    
    return "\(instruction.name) \(arg)"
  }
  
  private func buildThreeBitInstruction() -> String {
    
    let (addr, value) = getAddressAndValue()
    
    var arg: String = ""
    
    switch instruction.mode {
    case .none: 
              arg = String(format: "$%04X", addr, cpu.readMem(at: addr))
    case .absolute:

        arg = String(format: "$%04X = %02X", addr, cpu.readMem(at: addr))
      
    case .absoluteX: arg = String(format: "$%04X,X @ %04X = %02X}", value, addr, 1231)
    case .absoluteY: arg = String(format: "$%04X,Y @ %04X = %02X}", value, addr, 1231)
  
    default: fatalError("Unexpected addressing mode \(instruction.mode) \(instruction.name)")
    }
    
    return "\(instruction.name) \(arg)"
  }
  
  private func getAddressAndValue() -> (UInt16, UInt8) {
    if instruction.mode == .implied || instruction.mode == .relative {
      return (0,0)
    }
    let addr = cpu.getAddressForOpperate(with: instruction.mode, at: cpu.PC + 1)
    let mem = cpu.readMem(at: addr)
    return (addr, mem)
  }
  
}
