//
//  6502.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 8/4/2024.
//

import Foundation

final class CPU {
  
  let bus: Bus
  
  private var loop = true
  private var programCounterAtOppcodeRun: UInt16 = 0x00
  private (set) var registers: Registers
  private (set) var PC: UInt16 = 0x00
  private var trace: Bool = false
  
  typealias RunCallback = (CPUState) -> Void
  
  enum CPUError: Error {
    case invalidOpcode(String)
    case missingOpcode(String)
  }
  
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
  
  init(bus: Bus,
       registers: Registers = Registers()
  ) {
    self.registers = registers
    self.bus = bus
   
  }
  
  func reset() {
    bus.reset()
    registers.reset()
//    setProgramCounter(0xC000)
  }
  
  func __run_with_trace(callback: @escaping (CPUState) -> Void) {
    self.trace = true
    _run(trace: true) { state in
      callback(state)
    }
  }
  
  func run(callback: @escaping RunCallback) {
    _run(callback: callback)
  }
  
  private func _run(trace: Bool = false, callback: @escaping RunCallback) {
    DispatchQueue.global().async { [weak self] in
      guard let self else { return }
      while loop {
        
        let opcode: UInt8 = readMem(at: PC)
        let instruction: Instruction = getInstructions(for: opcode)
        let newProgramCounter = PC + 1
        
        setProgramCounter(newProgramCounter)
        programCounterAtOppcodeRun = newProgramCounter
        
        instruction.fn()
        
        //handle(controllerState: controllerState)
        
        // if the opperation does not change the program counter
        // we need to increment it by the number of bytes in the instruction
        let postOpcodePC = PC
        
        if programCounterAtOppcodeRun == 0xFFFF {
          loop = false
          return
        }
        
        if programCounterAtOppcodeRun == postOpcodePC {
          setProgramCounter(postOpcodePC + UInt16(instruction.bytes) - 1)
        }
        
        let state = __build_state(with: instruction)
        callback(state)
      }
    }
  }
  
  func __build_state(with instruction: Instruction) -> CPUState {
    return CPUState(
      address: String(format: "%04X", PC),
      hexDump: String(format: "%02X", readMem(at: PC)),
      instruction: instruction.name,
      registerA: String(format: "%02X", registers.A),
      registerX: String(format: "%02X", registers.X),
      registerY: String(format: "%02X", registers.Y),
      status: String(format: "%02X", registers.p),
      stackPointer: String(format: "%02X", bus.getStackPointer())
    )
  }
  
  func stop() {
    loop = false
    reset()
  }
  
  func setProgramCounter(_ value: UInt16) {
    PC = value
  }
  
  func getProgramCounter() -> UInt16 {
    return PC
  }
  
  func getOperand(for mode: AddressingMode) -> UInt16 {
    
    switch mode {
    case .accumulator:
      return UInt16(registers.A)
    case .absolute:
      return bus.readMem16(at: PC)
    case .immediate:
      return PC
    case .zeroPage:
      return UInt16(bus.readMem(at: PC))
    case .zeroPageX:
      let data: UInt8 = bus.readMem(at: PC)
      let addr = data.addingReportingOverflow(registers.X).partialValue
      return UInt16(addr)
    case .zeroPageY:
      let data: UInt8 = bus.readMem(at: PC)
      let addr = data.addingReportingOverflow(registers.Y).partialValue
      return UInt16(addr)
    case .absoluteX:
      let data = bus.readMem16(at: PC)
      let addr = data.addingReportingOverflow(UInt16(registers.X)).partialValue
      return addr
    case .absoluteY:
      let data = bus.readMem16(at: PC)
      let addr = data.addingReportingOverflow(UInt16(registers.Y)).partialValue
      return addr
    case .indirectX:
      return indirectX()
    case .indirectY:
      return indirectY()
    default: fatalError("Addressing mode: \(mode) not implemented")
    }
  }
  
  
  func readMem(at address: UInt16) -> UInt8 {
    bus.readMem(at: address)
  }
  
  func writeMem(at address: UInt16, value: UInt8) {
    bus.writeMem(at: address, value: value)
  }
  
  func readMem16(at address: UInt16) -> UInt16 {
    bus.readMem16(at: address)
  }
  
  func writeMem16(at address: UInt16, value: UInt16) {
    bus.writeMem16(at: address, value: value)
  }
  
  func stackPush(_ value: UInt8) {
    bus.stackPush(value)
  }
  
  func stackPush16(_ value: UInt16) {
    bus.stackPush16(value)
  }
  
  func stackPop() -> UInt8 {
    bus.stackPop()
  }
  
  func stackPop16() -> UInt16 {
    bus.stackPop16()
  }
  
  func setStackPointer(_ value: UInt8) {
    bus.setStackPointer(value)
  }
  
  func getStackPointer() -> UInt8 {
    bus.getStackPointer()
  }
}

private extension CPU {
  
  func indirectX() -> UInt16 {
    let storedAddress: UInt8 = readMem(at: PC)
    let addr = storedAddress.addingReportingOverflow(registers.X).partialValue
    
    let lo = UInt16(readMem(at: UInt16(addr)))
    let hi = UInt16(readMem(at: UInt16(addr.addingReportingOverflow(1).partialValue)))
    let ptr = (hi << 8) | lo
    return ptr
  }
  
  func indirectY() -> UInt16 {
    let storedAddress = UInt16(readMem(at: PC))
    let lo: UInt8 = readMem(at: storedAddress)
    let hi: UInt8 = readMem(at: storedAddress.addingReportingOverflow(1).partialValue)
    let pointer = UInt16(hi) << 8 | UInt16(lo)
    return pointer.addingReportingOverflow(UInt16(registers.Y)).partialValue
  }
  // MARK: - Addressing mode
  
  func handle(controllerState state: UInt8) {
    
    if state & ControllerButton.left.mask != 0 {
      writeMem(at: 0xFF, value: 0x61)
      print("left written")
      return
    }
    
    if state & ControllerButton.right.mask != 0 {
      writeMem(at: 0xFF, value: 0x64)
      print("right written")
      return
    }
    
    if state & ControllerButton.up.mask != 0 {
      writeMem(at: 0xFF, value: 0x77)
      print("up written")
      return
    }
    
    if state & ControllerButton.down.mask != 0 {
      print("down written")
      writeMem(at: 0xFF, value: 0x73)
      return
    }
  }
}

extension CPU {
  func branch(when condition: Bool) {
    if condition {
      
      let pc = PC
      let data = readMem(at: pc)
      let signedOffset = Int8(bitPattern: data)
      
      var targetAddress: UInt16
      
      if signedOffset >= 0 {
        targetAddress = pc &+ UInt16(signedOffset) + 1
      } else {
        targetAddress = pc &- UInt16(abs(signedOffset)) + 1
      }
      
      setProgramCounter(targetAddress)
      
    }
  }
  
  func compare(against value: UInt8, mode: AddressingMode) {
    compare(against: Int(value), mode: mode)
  }
  
  func compare(against value: Int, mode: AddressingMode) {
    let addr = getOperand(for: mode)
    let data = Int(readMem(at: addr))
    
    let result = value - data
    
    setNegativeFlag(result >> 7 == 1)
    setZeroFlag(result == 0)
    
    setCarryFlag(value >= data)
    
  }
  
  func setRegisterA(_ value: UInt8) {
    registers.set(.A, to: value)
    setZeroFlag(value)
    setNegativeFlag(value)
  }
  
  //MARK: - Set flag Functions
  
  func setCarryFlag(_ set: Bool) {
    if set {
      registers.set(.carry)
    } else {
      registers.clear(.carry)
    }
  }
  
  func setCarryFlag(_ value: UInt8) {
    setCarryFlag(value >> 7 == 1)
  }
  
  func setZeroFlag(_ condition: Bool) {
    if condition {
      registers.set(.zero)
    } else {
      registers.clear(.zero)
    }
  }
  
  func setZeroFlag(_ value: UInt8) {
    setZeroFlag(value == 0)
  }
  
  func setOverflowFlag(_ condition: Bool) {
    if condition {
      registers.set(.overflow)
    } else {
      registers.clear(.overflow)
    }
  }
  
  func setOverflowFlag(_ value: UInt8) {
    setOverflowFlag((value & 1 << 6) != 0)
  }
  
  func setNegativeFlag(_ condition: Bool) {
    if condition {
      registers.set(.negative)
    } else {
      registers.clear(.negative)
    }
  }
  
  func setNegativeFlag(_ value: UInt8) {
    setNegativeFlag(value >> 7 == 1)
  }
}
