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
  
  let memory: MemoryInjectable
  
  private var loop = true
  private var programCounterAtOppcodeRun: MemoryAddress = 0x00
  
  let callback: () -> UInt8
  
  enum CPUError: Error {
    case invalidOpcode(String)
    case missingOpcode(String)
  }
  
  init(memory: MemoryInjectable = Memory(),
       callback: @escaping () -> UInt8 = { 0x00 }
  ) {
    self.memory = memory
    self.callback = callback
  }
  
  func load(program: [UInt8]) {
    memory.load(program: program)
  }
  
  func reset() {
    memory.reset()
  }
  
  func run(callback:() -> UInt8) {
    while loop {
      
      let opcode: UInt8 = memory.readMemAtCounter()
      let instruction = getInstructions(forOpcode: opcode)
      let newProgramCounter = memory.getProgramCounter() + 1
      
      memory.setProgramCounter(newProgramCounter)
      programCounterAtOppcodeRun = newProgramCounter
      
      log("instruction \(instruction.name) \(String(opcode, radix: 16))")
      instruction.fn()
      
      let controllerState = callback()
      handle(controllerState: controllerState)

      // if the opperation does not change the program counter
      // we need to increment it by the number of bytes in the instruction
      let postOpcodePC = memory.getProgramCounter()
      if programCounterAtOppcodeRun == postOpcodePC {
        memory.setProgramCounter(postOpcodePC + UInt16(instruction.bytes) - 1)
      }
    }
  }
  
  func stop() {
    loop = false
    reset()
  }
}

// MARK: Opcode functions helpers
private extension CPU {
  
  func handle(controllerState state: UInt8) {
    
    if state & Controller.Button.left.mask != 0 {
      memory.writeMem(at: 0xFF, value: 0x61)
      return
    }
    
    if state & Controller.Button.right.mask != 0 {
      memory.writeMem(at: 0xFF, value: 0x64)
      return
    }
    
    if state & Controller.Button.up.mask != 0 {
      memory.writeMem(at: 0xFF, value: 0x77)
      return
    }
    
    if state & Controller.Button.down.mask != 0 {
      memory.writeMem(at: 0xFF, value: 0x73)
      return
    }
  }
  
  func signedValue(from byte: UInt8) -> (UInt8, Bool) {
    let isSigned = byte & 0b1000_0000 != 0
    return (byte & 0b0111_1111, isSigned)
  }
  
  func branch(when condition: Bool) {
    if condition {
      let pc = memory.getProgramCounter()
      let data = UInt16(memory.readMem(at: pc))
      let offset = pc + 1
      
      let destAddress = offset &+ (data ^ 0x80) &- 0x80


      memory.setProgramCounter(UInt16(destAddress))
    
      log("Branch taken")
    }
  }
  
  func compare(against value: UInt8, mode: AddressingMode) {
      compare(against: Int(value), mode: mode)
  }
  
  func compare(against value: Int, mode: AddressingMode) {
    let addr = memory.getAddress(for: mode)
    let data = value - Int(memory.readMem(at: addr))
  
    setNegativeFlag(data  >> 7 == 1)
    
    setCarryFlag(value >= data)
    setZeroFlag(data == 0)
    
  }
    
  func setRegisterA(_ value: UInt8) {
    memory.registers.set(.A, to: value)
    setZeroFlag(value)
    setNegativeFlag(value)
  }
}

// MARK: Opcode functions
extension CPU {
  
  func addToRegisterA(value: UInt8) {
   
  }
  
  func ADC(mode: AddressingMode) {
    
    let addr = memory.getAddress(for: mode)
    let data = UInt16(memory.readMem(at: addr))
    
    let result = UInt16(memory.registers.A) + data + (memory.registers.isSet(.carry) ? 1 : 0)
        
    setCarryFlag((result & 0xFF) == 0)

    if ((data ^ result) & (result ^ UInt16(memory.registers.A)) & 0x80) != 0 {
      memory.registers.set(.overflow)
    } else {
      memory.registers.clear(.overflow)
    }

    setRegisterA(UInt8(result & 0xFF))
    
    log("param, result", UInt16(data), result)
  }
  
  func AND(mode: AddressingMode) {
    //A,Z,N = A&M
    let addr = memory.getAddress(for: mode)
    let data = memory.readMem(at: addr)
    let result = data & memory.registers.A
    
    setRegisterA(result)
    
    log("data, result", data, result)
  }
  
  func ASL(mode: AddressingMode) {
    
    var data: UInt8!
    let addr = memory.getAddress(for: mode)
    
    if mode == .accumulator {
      data = memory.registers.A
    } else {
      data = memory.readMem(at: addr)
    }
    
      
    data = (data << 1) & 0xFE
    
    if mode == .accumulator {
      memory.registers.set(.A, to: data)
    } else {
      memory.writeMem(at: addr, value: data)
    }
    
    setCarryFlag(data >> 7 == 1)
    setZeroFlag(data == 0)
    setNegativeFlag(data >> 7 == 1)
    
  }
  // Branch if Carry Clear
  func BCC() {
    branch(when: !memory.registers.isSet(.carry))
  }
  
  // Branch if Carry Clear
  func BCS() {
    branch(when: memory.registers.isSet(.carry))
  }
  
  // Branch if Equal
  func BEQ() {
    branch(when: memory.registers.isSet(.zero))
  }
  
  
  func BIT(mode: AddressingMode) {
    let addr = memory.getAddress(for: mode)
    let data = memory.readMem(at: addr)
    let a = memory.registers.A
    
    let result = data & a
    
    setNegativeFlag(result)
    setOverflowFlag(result)
    setZeroFlag(result)
    
    log("data, a, result", data, a, result)
  }
  
  
  func BMI() {
    branch(when: memory.registers.isSet(.negative))
  }
  
  func BNE() {
    branch(when: !memory.registers.isSet(.zero))
  }
  
  func BPL() {
    branch(when: !memory.registers.isSet(.negative))
  }
  
  // Break
  func BRK() {
//    let pc = memory.getProgramCounter()
//    let vector = memory.readMem16(at: 0xFFFE)
//    
//    memory.stackPush16(pc)
//    memory.stackPush(memory.registers.p)
//    memory.setProgramCounter(vector)
    
    return
  }
  
  // Branch if Overflow Clear
  func BVC() {
    branch(when: !memory.registers.isSet(.overflow))
  }
  
  // Branch if Overflow Set
  func BVS() {
    branch(when: memory.registers.isSet(.overflow))
  }
  
  // Clear Carry Flag
  func CLC() {
    setCarryFlag(false)
    log("carry flag", memory.registers.isSet(.carry) ? 1 : 0)
  }
  
  // Clear Decimal Mode
  func CLD() {
    memory.registers.clear(.decimal)
  }
  
  // Clear Interrupt Disable
  func CLI() {
    memory.registers.clear(.interrupt)
  }
  
  // Clear Overflow Flag
  func CLV() {
    setOverflowFlag(false)
  }
  
  // Compare Accumulator
  func CMP(mode: AddressingMode) {
    log("CMP")
    compare(against: memory.registers.A, mode: mode)
  }
  
  // Compare X Register
  func CPX(mode: AddressingMode) {
    compare(against: memory.registers.X, mode: mode)
  }
  
  // Compare Y Register
  func CPY(mode: AddressingMode) {
    compare(against: memory.registers.Y, mode: mode)
  }
  
  // Decrement Memory
  func DEC(mode: AddressingMode) {
    let addr = memory.getAddress(for: mode)
    let data = Int(memory.readMem(at: addr)) - 1
    
    
    setNegativeFlag((data >> 7) & 0x1 == 1)
    setZeroFlag((data & 0xFF) == 1)
    
    memory.writeMem(at: addr, value: UInt8(data & 0xFF))
    
  }
  
  // Decrement X Register
  func DEX() {
    let data = Int(memory.registers.X) - 1
    
    memory.registers.set(.X, to: UInt8(data & 0xFF))
    
    setNegativeFlag((data >> 7) & 0x1 == 1)
    setZeroFlag((data & 0xFF) == 1)
    
  }
  
  // Decrement Y Register
  func DEY() {
    let data = Int(memory.registers.Y) - 1
    
    memory.registers.set(.Y, to: UInt8(data & 0xFF))
    
    setNegativeFlag((data >> 7) & 0x1 == 1)
    setZeroFlag((data & 0xFF) == 1)
  }
  
  // Exclusive OR
  func EOR(mode: AddressingMode) {
    let addr = memory.getAddress(for: mode)
    let data = memory.readMem(at: addr)
    let result = memory.registers.A ^ data
    
    setRegisterA(result)
  }
  
  // Increment Memory
  func INC(mode: AddressingMode) {
    let addr = memory.getAddress(for: mode)
    let data = Int(memory.readMem(at: addr)) + 1
    
    setNegativeFlag((data >> 7) == 1)
    setZeroFlag((data & 0xFF) == 0)
    
    memory.writeMem(at: addr, value: UInt8(data & 0xFF))
  }
  
  // Increment X Register
  func INX() {
    let data = Int(memory.registers.X) + 1
    
    setNegativeFlag((data >> 7) == 1)
    setZeroFlag((data & 0xFF) == 0)
    
    memory.registers.set(.X, to: UInt8(data & 0xFF))
  }
  
  // Increment Y Register
  func INY() {
    let data = Int(memory.registers.Y) + 1
    
    setNegativeFlag((data >> 7) == 1)
    setZeroFlag((data & 0xFF) == 0)
    
    memory.registers.set(.Y, to: UInt8(data & 0xFF))
  }
  
  func JMP(mode: AddressingMode) {
    switch mode {
    case .absolute:
      let pc = memory.getProgramCounter()
      let ptr: MemoryAddress = memory.readMem16(at: pc)
      memory.setProgramCounter(ptr)
      
    case .indirect:
      
      let pc = memory.getProgramCounter()
      let ptr: MemoryAddress = memory.readMem16(at: pc)
      
      /*
       NB:
       An original 6502 has does not correctly fetch the target address if
       the indirect vector falls on a page boundary (e.g. $xxFF where xx is
       any value from $00 to $FF). In this case fetches the LSB from $xxFF
       as expected but takes the MSB from $xx00. This is fixed in some
       later chips like the 65SC02 so for compatibility always ensure the
       indirect vector is not at the end of the page.
       */
      
      var indrectPtr: MemoryAddress!
      
      if ptr & 0x00FF == 0x00FF {
        let lo = memory.readMem(at: ptr)
        let hi = memory.readMem(at: ptr & 0xFF00)
        indrectPtr = UInt16(hi) << 8 | UInt16(lo)
      } else {
        indrectPtr = memory.readMem16(at: ptr)
      }
      
      memory.setProgramCounter(indrectPtr)
      
    default:
      fatalError("Invalid addressing mode for JMP")
    }
  }
  
  
  // Jump to Subroutine
  func JSR() {
    memory.stackPush16(memory.getProgramCounter() + 1)
    let addr = memory.readMem16(at: memory.getProgramCounter())
    memory.setProgramCounter(addr)
  }
  
  // Load Accumulator
  func LDA(mode: AddressingMode) {
    let addr = memory.getAddress(for: mode)
    let data = memory.readMem(at: addr)
    
    setRegisterA(data)
    
  }
  
  // Load X Register
  func LDX(mode: AddressingMode) {
    let addr = memory.getAddress(for: mode)
    let data = memory.readMem(at: addr)
    memory.registers.set(.X, to: data)
    setZeroFlag(data)
    setNegativeFlag(data)
  }
  
  // Load Y Register
  func LDY(mode: AddressingMode) {
    let addr = memory.getAddress(for: mode)
    let data = memory.readMem(at: addr)
    memory.registers.set(.Y, to: data)
    setZeroFlag(data)
    setNegativeFlag(data)
  }
  
  
  // Logical Shift Right
  func LSR(mode: AddressingMode) {
    var data: UInt8!
    if mode == .accumulator {
      data = memory.registers.A
    } else {
      let addr = memory.getAddress(for: mode)
      data = memory.readMem(at: addr)
    }
    
    setCarryFlag(data & 1 == 1)
    
    data = data >> 1
    
    setNegativeFlag(false)
    setZeroFlag(data)
    setCarryFlag(data)
    
    if mode == .accumulator {
      memory.registers.set(.A, to: data)
    } else {
      let addr = memory.getAddress(for: mode)
      memory.writeMem(at: addr, value: data)
    }
  }
  
  // No Operation
  func NOP() {
    // NOP
  }
  
  // Logical Inclusive OR
  func ORA(mode: AddressingMode) {
    let addr = memory.getAddress(for: mode)
    let data = memory.readMem(at: addr)
    let result = memory.registers.A | data

    setRegisterA(result)
  }
  
  // Push Accumulator
  func PHA() {
    memory.stackPush(memory.registers.A)
  }
  
  // Push Processor Status
  func PHP() {
    memory.stackPush(memory.registers.p)
  }
  
  // Pull Accumulator
  func PLA() {
    let result = memory.stackPop()
    setRegisterA(result)
  }
  
  // Pull Processor Status
  func PLP() {
    memory.registers.set(programStatus: memory.stackPop())
  }
  
  // Rotate Left
  func ROL(mode: AddressingMode) {
    var data: UInt8!
    
    if mode == .accumulator {
      data = memory.registers.A
    } else {
      let addr = memory.getAddress(for: mode)
      data = memory.readMem(at: addr)
    }
    
    data = data << 1
    data = data | (memory.registers.isSet(.carry) ? 1 : 0)
    
    setCarryFlag(data)
    setZeroFlag(data)
    setNegativeFlag(data)
    
    if mode == .accumulator {
      memory.registers.set(.A, to: data)
    } else {
      let addr = memory.getAddress(for: mode)
      memory.writeMem(at: addr, value: data)
    }
  }
  
  // Rotate Right
  func ROR(mode: AddressingMode) {
    
    var data: UInt8!
    if mode == .accumulator {
      data = memory.registers.A
    } else {
      let addr = memory.getAddress(for: mode)
      data = memory.readMem(at: addr)
    }
    
    
    data = (data >> 1) & 0x7F
    data = data | (memory.registers.isSet(.carry) ? 0x80:0)
    
    setZeroFlag(data)
    setNegativeFlag(data)
    setCarryFlag(data)
    
    if mode == .accumulator {
      memory.registers.set(.A, to: data)
    } else {
      let addr = memory.getAddress(for: mode)
      memory.writeMem(at: addr, value: data)
    }
    
  }
  
  
  // Return from interrupt
  func RTI() {
    let programStatus = memory.stackPop()
    let pc = memory.stackPop16()
    
    memory.registers.set(programStatus: programStatus)
    memory.setProgramCounter(pc)
  }
  
  // Return from Subroutine
  func RTS() {

    let returnAddress = memory.stackPop16() + 1
    memory.setProgramCounter(returnAddress)
  }
  
  // Subtract with Carry
  func SBC(mode: AddressingMode) {
    let addr = memory.getAddress(for: mode)
    let data = Int(memory.readMem(at: addr))
    let a = Int(memory.registers.A)
    
    let result = a - data - (memory.registers.isSet(.carry) ? 1:0)
    
//    setOverflowFlag(((a ^ data) & (a ^ UInt8(result & 0xFF)) & 0x80) == 0x80)
    setCarryFlag(result >= 0)
    setNegativeFlag(UInt8(result & 0xFF) == 1)
    setZeroFlag(result & 0xFF == 0)
    
    memory.registers.set(.A, to: UInt8(result & 0xFF))
    
  }
  
  // Set Carry Flag
  func SEC() {
    memory.registers.set(.carry)
  }
  
  
  // Set Decimal Flag
  func SED() {
    memory.registers.set(.decimal)
  }
  
  // Set Interrupt Disable
  func SEI() {
    memory.registers.set(.interrupt)
  }
  
  // Store Accumulator
  func STA(mode: AddressingMode) {
    let address = memory.getAddress(for: mode)
    memory.writeMem(at: address, value: memory.registers.A)
  }
  
  // Store X Register
  func STX(mode: AddressingMode) {
    let address = memory.getAddress(for: mode)
    memory.writeMem(at: address, value: memory.registers.X)
  }
  
  // Store Y Register
  func STY(mode: AddressingMode) {
    let address = memory.getAddress(for: mode)
    memory.writeMem(at: address, value: memory.registers.Y)
  }
  
  // Transfer Accumulator to X
  func TAX() {
    memory.registers.set(.X, to: memory.registers.A)
    setZeroFlag(memory.registers.X)
    setNegativeFlag(memory.registers.X)
  }
  
  // Transfer Accumulator to Y
  func TAY() {
    memory.registers.set(.Y, to: memory.registers.A)
    setZeroFlag(memory.registers.Y)
    setNegativeFlag(memory.registers.Y)
  }
  
  // Transfer Stack Pointer to X
  func TSX() {
    memory.registers.set(.X, to: memory.getStackPointer())
    setZeroFlag(memory.registers.X)
    setNegativeFlag(memory.registers.X)
  }
  
  //Transfer X to Accumulator
  func TXA() {
    setRegisterA(memory.registers.X)
    setZeroFlag(memory.registers.X)
    setNegativeFlag(memory.registers.X)
  }
  
  // Transfer X to Stack Pointer
  func TXS() {
    memory.setStackPointer(memory.registers.X)
    setZeroFlag(memory.registers.X)
    setNegativeFlag(memory.registers.X)
  }
  
  //Transfer Y to Accumulator
  func TYA() {
    setRegisterA(memory.registers.Y)
  }
  
  //MARK: - Set flag Functions
  
  func setCarryFlag(_ set: Bool) {
    if set {
      memory.registers.set(.carry)
    } else {
      memory.registers.clear(.carry)
    }
  }
  
  func setCarryFlag(_ value: UInt8) {
    setCarryFlag(value >> 7 == 1)
  }
  
  func setZeroFlag(_ condition: Bool) {
    if condition {
      memory.registers.set(.zero)
    } else {
      memory.registers.clear(.zero)
    }
  }
  
  func setZeroFlag(_ value: UInt8) {
    setZeroFlag(value == 0)
  }
  
  func setOverflowFlag(_ condition: Bool) {
    if condition {
      memory.registers.set(.overflow)
    } else {
      memory.registers.clear(.overflow)
    }
  }
  
  func setOverflowFlag(_ value: UInt8) {
    setOverflowFlag((value & 1 << 6) != 0)
  }
  
  func setNegativeFlag(_ condition: Bool) {
    if condition {
      memory.registers.set(.negative)
    } else {
      memory.registers.clear(.negative)
    }
  }
  
  func setNegativeFlag(_ value: UInt8) {
    setNegativeFlag(value >> 7 == 1)
  }
}
