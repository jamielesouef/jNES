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
      
      let controllerState = callback()
      let opcode: UInt8 = memory.readMemAtCounter()
      let instruction = getInstructions(forOpcode: opcode)
      let newProgramCounter = memory.getProgramCounter() + 1
      
      memory.setProgramCounter(newProgramCounter)
      programCounterAtOppcodeRun = newProgramCounter
      
      handle(controllerState: controllerState)
      
      log("instruction \(instruction.name) \(String(opcode, radix: 16))")
      instruction.fn()
      
      // if the opperation does not change the program counter
      // we need to increment it by the number of bytes in the instruction
      let pc = memory.getProgramCounter()
      if programCounterAtOppcodeRun == pc {
        memory.setProgramCounter(pc + UInt16(instruction.bytes) - 1)
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
      let offset: UInt8 = memory.readMem(at: pc)
      
      let addr = pc
        .addingReportingOverflow(UInt16(offset) + 1).partialValue
        

      memory.setProgramCounter(addr)
      log("Branch taken")
    }
  }
  
  func compare(against value: UInt8, mode: AddressingMode) {
    let addr = memory.getAddress(for: mode)
    let data = memory.readMem(at: addr)
  
    setCarryFlag(value <= data)
    
    let subResult = value.subtractingReportingOverflow(data).partialValue
    setZeroAndNegativeFlag(subResult)
  }
  
  func increment(param: UInt8) -> UInt8 {
    let result = param.addingReportingOverflow(1).partialValue
    
    setZeroAndNegativeFlag(result)
    
    return result
  }
  
  func setRegisterA(_ value: UInt8) {
    memory.registers.set(.A, to: value)
    setZeroAndNegativeFlag(value)
  }
}

// MARK: Opcode functions
extension CPU {
  
  func addToRegisterA(value: UInt8) {
   
  }
  
  func ADC(mode: AddressingMode) {
    
    let addr = memory.getAddress(for: mode)
    let data: UInt8 = memory.readMem(at: addr)
    
    let sum = UInt16(memory.registers.A)
      .addingReportingOverflow(UInt16(data)).partialValue
      .addingReportingOverflow(memory.registers.isSet(.carry) ? 1 : 0).partialValue
        
    if  sum > 0xFF {
      memory.registers.set(.carry)
    } else {
      memory.registers.clear(.carry)
    }

    let truncatedResult = UInt8(truncatingIfNeeded: sum)

    if ((data ^ truncatedResult) & (truncatedResult ^ memory.registers.A) & 0x80) != 0 {
      memory.registers.set(.overflow)
    } else {
      memory.registers.clear(.overflow)
    }

    setRegisterA(truncatedResult)
    
    log("param, result", data, truncatedResult)
  }
  
  func AND(mode: AddressingMode) {
    //A,Z,N = A&M
    let addr = memory.getAddress(for: mode)
    let param: UInt8 = memory.readMem(at: addr)
    let result = param & memory.registers.A
    
    setRegisterA(result)
    
    log("param, result", param, result)
  }
  
  func ASL(mode: AddressingMode) {
    let address = memory.getAddress(for: mode)
    var data = memory.readMem(at: address)
    
    setCarryFlag(data >> 7 == 1)
      
    data = data << 1
    
    memory.writeMem(at: address, value: data)
    
    setZeroAndNegativeFlag(data)
  }
  
  func ASL_accumulator(){
    let address = memory.getAddress(for: .accumulator)
    var data = memory.registers.A
    
    setCarryFlag(data >> 7 == 1)
      
    data = data << 1
    
    memory.writeMem(at: address, value: data)
  }
  
  func BCC() {
    branch(when: memory.registers.isSet(.carry))
  }
  
  // Branch if Carry Clear
  func BCS() {
    branch(when: memory.registers.isSet(.carry))
  }
  
  func BEQ() {
    branch(when: memory.registers.isSet(.zero))
  }
  
  func BIT(mode: AddressingMode) {
    let addr = memory.getAddress(for: mode)
    let data = memory.readMem(at: addr)
    let a = memory.registers.A
    
    let result = data & a
    setZeroAndNegativeFlag(result)
    
    setOverflowFlag(result)
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
    let pc = memory.getProgramCounter()
    let vector = memory.readMem16(at: 0xFFFE)
    
    memory.stackPush16(pc)
    memory.stackPush(memory.registers.p)
    memory.setProgramCounter(vector)
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
    memory.registers.clear(.carry)
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
    memory.registers.clear(.overflow)
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
    let data = memory.readMem(at: addr)
    let result = data - 1
    
    memory.writeMem(at: addr, value: result)
    setZeroAndNegativeFlag(result)
  }
  
  // Decrement X Register
  func DEX() {
    let param = memory.registers.X.subtractingReportingOverflow(1).partialValue
    memory.registers.set(.X, to: param)
    setZeroAndNegativeFlag(param)
  }
  
  // Decrement Y Register
  func DEY() {
    let param = memory.registers.Y - 1
    memory.registers.set(.Y, to: param)
    setZeroAndNegativeFlag(param)
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
    let data = memory.readMem(at: addr)
    let i = increment(param: data)
    let pc = memory.getProgramCounter() - 1
    memory.writeMem(at: pc, value: i)
  }
  
  // Increment X Register
  func INX() {
    let i = increment(param: memory.registers.X)
    log("i", i)
    memory.registers.set(.X, to: i)
  }
  
  // Increment Y Register
  func INY() {
    let i = increment(param: memory.registers.Y)
    log("i", i)
    memory.registers.set(.Y, to: i)
  }
  
  func JMP() {
    let pc = memory.getProgramCounter()
    let ptr: MemoryAddress = memory.readMem16(at: pc)
    memory.setProgramCounter(ptr)
  }
  
  // Jump
  func JMP_indirect() {
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
    setZeroAndNegativeFlag(data)
  }
  
  // Load Y Register
  func LDY(mode: AddressingMode) {
    let addr = memory.getAddress(for: mode)
    let data = memory.readMem(at: addr)
    memory.registers.set(.Y, to: data)
    setZeroAndNegativeFlag(data)
  }
  
  
  // Logical Shift Right
  func LSR(mode: AddressingMode) {
    let addr = memory.getAddress(for: mode)
    var data = memory.readMem(at: addr)
    
    setCarryFlag(data & 1 == 1)
    
    data = data >> 1
    
    memory.writeMem(at: addr, value: data)
    setZeroAndNegativeFlag(data)
  }
  
  // Logical Shift Right Accumulator
  func LSR_accumulator() {

    var data = memory.registers.A
    
    setCarryFlag(data & 1 == 1)
    
    data = data >> 1
    
    setRegisterA(data)
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
    let addr = memory.getAddress(for: mode)
    var data = memory.readMem(at: addr)
    
    let hadCarry: Bool = memory.registers.isSet(.carry) ? true : false
    
    setCarryFlag(data >> 7 == 1)
    
    data = data << 1
    
    if hadCarry {
      data = data | 1
    }
    
    memory.writeMem(at: addr, value: data)
    setZeroAndNegativeFlag(data)
  }
  
  // Rotate Left Accumulator
  func ROL_accumulator() {
    var data = memory.registers.A
    
    let hadCarry: Bool = memory.registers.isSet(.carry) ? true : false
    
    setCarryFlag(data >> 7 == 1)
    
    data = data << 1
    
    if hadCarry {
      data = data | 1
    }
    
    setRegisterA(data)
  }
  
  // Rotate Right
  func ROR(mode: AddressingMode) {
    let addr = memory.getAddress(for: mode)
    var data = memory.readMem(at: addr)
    
    let currentCarryValue: Bool = memory.registers.isSet(.carry) ? true : false
    
    setCarryFlag(data & 1 == 1)
    
    if currentCarryValue {
      data = data | 0b10000000
    }
    
    memory.writeMem(at: addr, value: data)
    setNegativeFlag(data)
    
  }
  
  // Rotate Right Accumulator
  func ROR_accumulator() {
    var data = memory.registers.A
    
    let currentCarryValue: Bool = memory.registers.isSet(.carry) ? true : false
    
    setCarryFlag(data & 1 == 1)
    
    if currentCarryValue {
      data = data | 0b10000000
    }
    
    setRegisterA(data)
    
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
    let param = memory.readMem(at: addr)
    let currentCarryValue: UInt8 = memory.registers.isSet(.carry) ? 1 : 0
    let a = memory.registers.A
    let result = a.subtractingReportingOverflow(param + currentCarryValue)
    
    let carry = result.partialValue > 0xff
    
    if carry {
      memory.registers.set(.carry)
    } else {
      memory.registers.clear(.carry)
    }
    
    if result.overflow {
      memory.registers.set(.overflow)
    } else {
      memory.registers.clear(.overflow)
    }
    
    setRegisterA(result.partialValue)
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
    setZeroAndNegativeFlag(memory.registers.X)
  }
  
  // Transfer Accumulator to Y
  func TAY() {
    memory.registers.set(.Y, to: memory.registers.A)
    setZeroAndNegativeFlag(memory.registers.Y)
  }
  
  // Transfer Stack Pointer to X
  func TSX() {
    memory.registers.set(.X, to: memory.getStackPointer())
    setZeroAndNegativeFlag(memory.registers.X)
  }
  
  //Transfer X to Accumulator
  func TXA() {
    setRegisterA(memory.registers.X)
  }
  
  // Transfer X to Stack Pointer
  func TXS() {
    memory.setStackPointer(memory.registers.X)
    setZeroAndNegativeFlag(memory.registers.X)
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
  
  func setZeroAndNegativeFlag(_ value: UInt8) {
    setZeroFlag(value)
    setNegativeFlag(value)
  }
  
  func setZeroFlag(_ value: UInt8) {
    if value == 0 {
      memory.registers.set(.zero)
    } else {
      memory.registers.clear(.zero)
    }
  }
  
  func setOverflowFlag(_ value: UInt8) {
    if (value & 1 << 6) != 0 {
      memory.registers.set(.overflow)
    } else {
      memory.registers.clear(.overflow)
    }
  }
  
  func setNegativeFlag(_ value: UInt8) {
    log("value", value)
    if value >> 7 == 1 {
      memory.registers.set(.negative)
    } else {
      memory.registers.clear(.negative)
    }
  }
}


