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
  private var addressingMode: AddressingMode?
  
  enum CPUError: Error {
    case invalidOpcode(String)
    case missingOpcode(String)
  }
  
  init(memory: MemoryInjectable = Memory(), addressingMode: AddressingMode? = nil) {
    self.memory = memory
    self.addressingMode = addressingMode
  }
  
  func load(program: [UInt8]) {
    memory.load(program: program)
  }
  
  func run() {
    run {
      log("running")
    }
  }
  
  private func run(callback: @escaping () -> Void) {
    while loop {
      callback()
      let opcode: UInt8 = memory.readMemAtCounter()
      log(opcode, r: 16)
      memory.incrementProgramCounter()
      
      dispatch(opcode)
    }
    
    func dispatch(_ opcode: UInt8) {
      let instruction = getInstructions(forOpcode: opcode)
      self.addressingMode = instruction.mode
      instruction.fn()
    }
  }
  
  func receivedButtonPress(code: UInt16) {
    log("button", code)
  }
}

// MARK: Opcode functions helpers
private extension CPU {
  func unsafeGetAddresingMode() -> AddressingMode {
    guard let mode = self.addressingMode else {
      fatalError("Addressing mode not set")
    }
    
    self.addressingMode = nil
    
    return mode
  }
  
  func loadByteFromMemory() -> UInt8 {
    let addressingMode = unsafeGetAddresingMode()
    
    if addressingMode == .accumulator {
      log("return A register value")
      log(memory.registers.A)
      return memory.registers.A
    }
    
    let addr = memory.getOpperandAddress(for: addressingMode)
    let byte = memory.readMem(at: addr)
    memory.incrementProgramCounter()
    log("return byte", byte)
    return byte
  }
  
  func loadByteFromMemory() -> UInt16 {
    let addressingMode = unsafeGetAddresingMode()
    
    if addressingMode == .accumulator {
      log("return A register value")
      log(memory.registers.A)
      return UInt16(memory.registers.A)
    }
    
    let addr = memory.getOpperandAddress(for: addressingMode)
    let byte = memory.readMem16(at: addr)
    memory.incrementProgramCounter()
    log("byte addr", byte, addr)
    return byte
  }
  
  func signedValue(from byte: UInt8) -> (UInt8, Bool) {
    let isSigned = byte & 0b1000_0000 != 0
    return (byte & 0b0111_1111, isSigned)
  }
  
  func branch(when condition: Bool) {
    if condition {
      let offset: UInt8 = memory.readMem(at: memory.getprogramCounter())
      let (singedValue, isSigned): (UInt8, Bool) = signedValue(from: offset)
      
      memory.setProgramCounter(
        UInt16(
          isSigned
          ? offset.subtractingReportingOverflow(
            singedValue
          ).partialValue
          : offset.addingReportingOverflow(
            singedValue
          ).partialValue
        )
      )
    }
  }
  
  func compare(against value: UInt8) {
    let param: UInt8 = loadByteFromMemory()
    let subtractedResult = value.subtractingReportingOverflow(param).partialValue
    
    
    setZeroFlag(subtractedResult)
    setNegativeFlag(subtractedResult)
    
    setCarryFlag( value >= param ? 1 : 0)
  }
  
  func increment(param: UInt8) -> UInt8 {
    let result = param.addingReportingOverflow(1).partialValue
    
    setZeroAndNegativeFlag(result)
    
    return result
  }
  
  func loadFromMemory(into register: Registers.Accumulator) {
    let param: UInt8 = loadByteFromMemory()
    memory.registers.set(register, to: param)
    setZeroAndNegativeFlag(param)
  }
  
  func _ASL(param: UInt8) {
    let bit7 = param & 0b1000_0000
    let result = memory.registers.A << 1
    
    log("bit7", bit7)
    
    log("result", result)
    
    memory.registers.set(.A, to: result)
    setZeroAndNegativeFlag(result)
    setCarryFlag(bit7)
  }
  
  func _LSR(param: UInt8) -> UInt8 {
    let lsb = param & 1
    let result = param >> 1
    setZeroFlag(result)
    setNegativeFlag(result)
    setCarryFlag(lsb)
    return result
  }
  
  func _ST(value: UInt8) {
    let memoryAddress: UInt8 = loadByteFromMemory()
    memory.writeMem(at: MemoryAddress(memoryAddress), value: value)
  }
  
  private func _ROL(param: UInt8) -> UInt8 {
    // DON'T TOUCH THIS
    let msb = param >> 7
    
    let lsb: UInt8 = memory.registers.isSet(.carry) ? 1 : 0
    
    let result = (param << 1) | lsb
    
    log("result", result, r: 2)
    setZeroAndNegativeFlag(result)
    setCarryFlag(msb)
    
    log("param", param, r:10)
    log("result", result, r:10)
    return result
  }
  
  private func _ROR(param: UInt8) -> UInt8 {
    
    let msb: UInt8 = memory.registers.isSet(.carry) ? 1 : 0
    let lsb = param & 1
    let result = (param >> 1) | (msb << 7)
    
    log("result", result, r: 2)
    setZeroAndNegativeFlag(result)
    setCarryFlag(lsb)
    
    log("param", param, r:10)
    log("result", result, r:10)
    return result
  }
  
}

// MARK: Opcode functions
extension CPU {
  func ADC() {
    
    let param: UInt8 = loadByteFromMemory()
    
    let carry: UInt8 = memory.registers.isSet(.carry) ? 1 : 0
    let a = memory.registers.A
    let result = a.addingReportingOverflow(param + carry)
    
    if result.overflow {
      memory.registers.set(.carry)
    } else {
      memory.registers.clear(.carry)
    }
    
    memory.registers.set(.A, to: result.partialValue)
    
    setZeroAndNegativeFlag(memory.registers.A)
  }
  
  func AND() {
    //A,Z,N = A&M
    let param: UInt8 = loadByteFromMemory()
    let result = memory.registers.A & param
    memory.registers.set(.A, to: result)
  }
  
  func ASL() {
    _ASL(param: loadByteFromMemory())
  }
  
  func ASL_accumulator(){
    _ASL(param: memory.registers.A)
  }
  
  func BCC() {
    branch(when: memory.registers.isSet(.carry))
  }
  
  func BCS() {
    branch(when: !memory.registers.isSet(.carry))
  }
  
  func BEQ() {
    branch(when: memory.registers.isSet(.zero))
  }
  
  func BIT() {
    let param: UInt8 = loadByteFromMemory()
    let a = memory.registers.A
    
    let result = param & a
    setZeroAndNegativeFlag(result)
    
    setOverflowFlag(result)
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
    let pc = memory.getprogramCounter()
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
  func CMP() {
    compare(against: memory.registers.A)
  }
  
  // Compare X Register
  func CPX() {
    compare(against: memory.registers.X)
  }
  
  // Compare Y Register
  func CPY() {
    compare(against: memory.registers.Y)
  }
  
  // Decrement Memory
  func DEC() {
    let param: UInt8 = loadByteFromMemory()
    let result = param - 1
    let pc = memory.getprogramCounter() - 1
    memory.writeMem(at: pc, value: result)
    setZeroAndNegativeFlag(result)
  }
  
  // Decrement X Register
  func DEX() {
    let param = memory.registers.X - 1
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
  func EOR() {
    let param: UInt8 = loadByteFromMemory()
    let result = memory.registers.A ^ param
    memory.registers.set(.A, to: result)
    setZeroAndNegativeFlag(result)
  }
  
  // Increment Memory
  func INC() {
    let param: UInt8 = loadByteFromMemory()
    let i = increment(param: param)
    let pc = memory.getprogramCounter() - 1
    memory.writeMem(at: pc, value: i)
  }
  
  // Increment X Register
  func INX() {
    let i = increment(param: memory.registers.X)
    memory.registers.set(.X, to: i)
  }
  
  // Increment Y Register
  func INY() {
    let i = increment(param: memory.registers.Y)
    memory.registers.set(.Y, to: i)
  }
  
  /*
   NB:
   An original 6502 has does not correctly fetch the target address if the indirect vector falls on a page boundary (e.g. $xxFF where xx is any value from $00 to $FF). In this case fetches the LSB from $xxFF as expected but takes the MSB from $xx00. This is fixed in some later chips like the 65SC02 so for compatibility always ensure the indirect vector is not at the end of the page.
   */
  
  // Jump
  func JMP() {
    let pc = memory.getprogramCounter()
    let ptr = memory.readMem16(at: pc)
    memory.setProgramCounter(ptr)
  }
  
  
  // Jump to Subroutine
  func JSR() {
    
    let returnPoint = memory.getprogramCounter()
    let newPtr: UInt16 = loadByteFromMemory()
    log("newPtr, returnPoint", newPtr, returnPoint)
    
    memory.stackPush16(returnPoint)
    memory.setProgramCounter(newPtr)
  }
  
  // Load Accumulator
  func LDA() {
    loadFromMemory(into: .A)
  }
  
  // Load X Register
  func LDX() {
    loadFromMemory(into: .X)
  }
  
  // Load Y Register
  func LDY() {
    loadFromMemory(into: .Y)
  }
  
  // Logical Shift Right
  func LSR() {
    let ptr: UInt8 = loadByteFromMemory()
    var mem = memory.readMem(at: MemoryAddress(ptr))
    
    mem = _LSR(param: mem)
    memory.writeMem(at: MemoryAddress(ptr), value: mem)
  }
  
  // Logical Shift Right Accumulator
  func LSR_accumulator() {
    let mem = _LSR(param: memory.registers.A)
    memory.registers.set(.A, to: mem)
  }
  
  // No Operation
  func NOP() {
    // NOP
  }
  
  // Logical Inclusive OR
  func ORA() {
    let param: UInt8 = loadByteFromMemory()
    let result = memory.registers.A | param
    memory.registers.set(.A, to: result)
    setZeroAndNegativeFlag(result)
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
    setZeroFlag(result)
    memory.registers.set(.A, to: result)
  }
  
  // Pull Processor Status
  func PLP() {
    memory.registers.set(programStatus: memory.stackPop())
  }
  
  // Rotate Left
  func ROL() {
    let ptr: UInt8 = loadByteFromMemory()
    let address = MemoryAddress(ptr)
    let param = memory.readMem(at: address)
    let result = _ROL(param: param)
    memory.writeMem(at: address, value: result)
    log("address", address, r:10)
  }
  
  // Rotate Left Accumulator
  func ROL_accumulator() {
    let result = _ROL(param: memory.registers.A)
    memory.registers.set(.A, to: result)
  }
  
  // Rotate Right
  func ROR() {
    let ptr: UInt8 = loadByteFromMemory()
    let address = MemoryAddress(ptr)
    let param = memory.readMem(at: address)
    let result = _ROR(param: param)
    memory.writeMem(at: address, value: result)
    log("address", address, r:10)
  }
  
  // Rotate Right Accumulator
  func ROR_accumulator() {
    let result = _ROR(param: memory.registers.A)
    memory.registers.set(.A, to: result)
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
    let returnAddress = memory.stackPop16()
    memory.setProgramCounter(returnAddress)
  }
  
  // Subtract with Carry
  func SBC() {
    let param: UInt16 = loadByteFromMemory()
    let currentCarryValue: UInt16 = memory.registers.isSet(.carry) ? 1 : 0
    let a = UInt16(memory.registers.A)
    let result = a.subtractingReportingOverflow(param + currentCarryValue)
    let _8bitResult = UInt8(truncatingIfNeeded: result.partialValue)
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
    
    memory.registers.set(.A, to: _8bitResult)
    setZeroAndNegativeFlag(_8bitResult)
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
  func STA() {
    _ST(value: memory.registers.A)
  }
  
  // Store X Register
  func STX() {
    _ST(value: memory.registers.X)
  }
  
  // Store Y Register
  func STY() {
    _ST(value: memory.registers.Y)
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
    memory.registers.set(.A, to: memory.registers.X)
    setZeroAndNegativeFlag(memory.registers.A)
  }
  
  // Transfer X to Stack Pointer
  func TXS() {
    memory.setStackPointer(memory.registers.X)
    setZeroAndNegativeFlag(memory.registers.X)
  }
  
  //Transfer Y to Accumulator
  func TYA() {
    memory.registers.set(.A, to: memory.registers.Y)
    setZeroAndNegativeFlag(memory.registers.Y)
  }
}

// Helpers

private extension CPU {
  
  func setCarryFlag(_ value: UInt8) {
    log("Setting carry flag")
    log(value)
    
    if value != 0 {
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
    if value & (1 << 7) != 0 {
      memory.registers.set(.negative)
    } else {
      memory.registers.clear(.negative)
    }
  }
}


