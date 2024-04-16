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
  
  private var loop = true //temport until flags
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
  
  func run() throws {
    while loop {
      let opcode: UInt8 = memory.readMemAtCounter()
      log(opcode, r: 16)
      memory.incrementProgramCounter()
      
      try dispatch(opcode)
    }
    
    func dispatch(_ opcode: UInt8) throws {
      let instruction = getInstructions(forOpcode: opcode)
      self.addressingMode = instruction.mode
      instruction.fn()
    }
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
  
  func _ROL(param: UInt8) -> UInt8 {
    let msb = param >> 7
    let result = (param << 1) | msb
    
    setZeroAndNegativeFlag(param)
    setCarryFlag(param)
    
    return result
  }
  
  func _ROR(param: UInt8) -> UInt8 {
    let previousCarry: UInt8 = memory.registers.isSet(.carry) ? 1 : 0
    let lsb = param & 1
    
    let result = (param >> 1) | (previousCarry << 7)
    
    setZeroFlag(result)
    setNegativeFlag(result)
    setCarryFlag(lsb)
    
    return result
  }
  
  func _STA(value: UInt8) {
    let memoryAddress: UInt8 = loadByteFromMemory()
    memory.writeMem(at: MemoryAddress(memoryAddress), value: value)
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
  
  func BRK() {
    let pc = memory.getprogramCounter()
    let vector = memory.readMem16(at: 0xFFFE)
    
    memory.stackPush16(pc)
    memory.stackPush(memory.registers.p)
    memory.setProgramCounter(vector)
  }
  
  func BVC() {
    branch(when: !memory.registers.isSet(.overflow))
  }
  
  func BVS() {
    branch(when: memory.registers.isSet(.overflow))
  }
  
  func CLC() {
    memory.registers.clear(.carry)
  }
  
  func CLD() {
    memory.registers.clear(.decimal)
  }
  
  func CLI() {
    memory.registers.clear(.interrupt)
  }
  
  func CLV() {
    memory.registers.clear(.overflow)
  }
  
  func CMP() {
    compare(against: memory.registers.A)
  }
  
  func CPX() {
    compare(against: memory.registers.X)
  }
  
  func CPY() {
    compare(against: memory.registers.Y)
  }
  
  func DEC() {
    let param: UInt8 = loadByteFromMemory()
    let result = param - 1
    let pc = memory.getprogramCounter() - 1
    memory.writeMem(at: pc, value: result)
    setZeroAndNegativeFlag(result)
  }
  
  func DEX() {
    let param = memory.registers.X - 1
    memory.registers.set(.X, to: param)
    setZeroAndNegativeFlag(param)
  }
  
  func DEY() {
    let param = memory.registers.Y - 1
    memory.registers.set(.Y, to: param)
    setZeroAndNegativeFlag(param)
  }
  
  func EOR() {
    let param: UInt8 = loadByteFromMemory()
    let result = memory.registers.A ^ param
    memory.registers.set(.A, to: result)
    setZeroAndNegativeFlag(result)
  }
  
  func INC() {
    let param: UInt8 = loadByteFromMemory()
    let i = increment(param: param)
    let pc = memory.getprogramCounter() - 1
    memory.writeMem(at: pc, value: i)
  }
  
  func INX() {
    let i = increment(param: memory.registers.X)
    memory.registers.set(.X, to: i)
  }
  
  func INY() {
    let i = increment(param: memory.registers.Y)
    memory.registers.set(.Y, to: i)
  }
  
  /*
   NB:
   An original 6502 has does not correctly fetch the target address if the indirect vector falls on a page boundary (e.g. $xxFF where xx is any value from $00 to $FF). In this case fetches the LSB from $xxFF as expected but takes the MSB from $xx00. This is fixed in some later chips like the 65SC02 so for compatibility always ensure the indirect vector is not at the end of the page.
   */
  
  func JMP() {
    let pc = memory.getprogramCounter()
    let ptr = memory.readMem16(at: pc)
    memory.setProgramCounter(ptr)
  }
  
  func JSR() {
    
    let returnPoint = memory.getprogramCounter()
    let param: UInt16 = loadByteFromMemory()
    log("param, returnPoint", param, returnPoint)
    
    memory.stackPush16(returnPoint)
    memory.setProgramCounter(param)
  }
  
  func LDA() {
    loadFromMemory(into: .A)
  }
  
  func LDX() {
    loadFromMemory(into: .X)
  }
  
  func LDY() {
    loadFromMemory(into: .Y)
  }
  
  
  func LSR() {
    let ptr: UInt8 = loadByteFromMemory()
    var mem = memory.readMem(at: MemoryAddress(ptr))
    
    mem = _LSR(param: mem)
    memory.writeMem(at: MemoryAddress(ptr), value: mem)
  }
  
  func LSR_accumulator() {
    let mem = _LSR(param: memory.registers.A)
    memory.registers.set(.A, to: mem)
  }
  
  func NOP() {
    // NOP
  }
  
  func ORA() {
    let param: UInt8 = loadByteFromMemory()
    let result = memory.registers.A ^ param
    memory.registers.set(.A, to: result)
    setZeroAndNegativeFlag(result)
  }
  
  func PHA() {
    memory.stackPush(memory.registers.A)
  }
  
  func PHP() {
    memory.stackPush(memory.registers.p)
  }
  
  func PLA() {
    memory.registers.set(.A, to: memory.stackPop())
  }
  
  func PLP() {
    memory.registers.set(programStatus: memory.stackPop())
  }
  
  func ROL() {
    let memoryAddress: UInt8 = loadByteFromMemory()
    let param = memory.readMem(at: MemoryAddress(memoryAddress))
    memory.writeMem(at: MemoryAddress(memoryAddress), value: _ROL(param: param))
  }
  
  func ROL_accumulator() {
    memory.registers.set(.A, to: _ROL(param: memory.registers.A))
  }
  
  func ROR() {
    let memoryAddress: UInt8 = loadByteFromMemory()
    var param = memory.readMem(at: MemoryAddress(memoryAddress))
    
    let result = _ROL(param: param)
    
    memory.writeMem(at: memory.getprogramCounter(), value: result)
  }
  
  func ROR_accumulator() {
    let result = _ROL(param: memory.registers.A)
    memory.registers.set(.A, to: result)
  }
  
  func RTI() {
    let programStatus = memory.stackPop()
    let pc = memory.stackPop16()
    
    memory.registers.set(programStatus: programStatus)
    memory.setProgramCounter(pc)
  }
  
  func RTS() {
    let returnAddress = memory.stackPop16()
    memory.setProgramCounter(returnAddress)
  }
  
  func SBC() {
    let param: UInt8 = loadByteFromMemory()
    
    let result = memory.registers.A.subtractingReportingOverflow(param)
    memory.registers.set(.A, to: result.partialValue)
    
    setZeroAndNegativeFlag(result.partialValue)
    
    if result.overflow {
      memory.registers.set(.carry)
    } else {
      memory.registers.clear(.carry)
    }
    
  }
  
  func SEC() {
    memory.registers.set(.carry)
  }
  
  func SED() {
    memory.registers.set(.decimal)
  }
  
  func SEI() {
    memory.registers.set(.interrupt)
  }
  
  func STA() {
    _STA(value: memory.registers.A)
  }
  
  func STX() {
    _STA(value: memory.registers.X)
  }
  
  func STY() {
    _STA(value: memory.registers.Y)
  }
  
  func TAX() {
    memory.registers.set(.X, to: memory.registers.A)
    setZeroAndNegativeFlag(memory.registers.X)
  }
  
  func TAY() {
    memory.registers.set(.Y, to: memory.registers.A)
    setZeroAndNegativeFlag(memory.registers.Y)
  }
  
  func TSX() {
    memory.registers.set(.X, to: memory.getStackPointer())
    setZeroFlag(memory.getStackPointer())
  }
  
  func TXA() {
    memory.registers.set(.X, to: memory.registers.A)
    setZeroFlag(memory.registers.A)
  }
  
  func TXS() {
    memory.setStackPointer(memory.registers.X)
  }
  
  func TYA() {
    memory.registers.set(.A, to: memory.registers.Y)
    setZeroFlag(memory.registers.Y)
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


