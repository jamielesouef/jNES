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
  
  let memory: Memory
  
  private var loop = true //temport until flags
  private var addressingMode: AddressingMode? = nil
  
  enum CPUError: Error {
    case invalidOpcode(String)
    case missingOpcode(String)
  }
  
  init(memory: Memory = Memory()) {
    self.memory = memory
  }

  func load(program: [UInt8]) {
    memory.load(program: program)
  }
  
  func run() throws {
    while loop {
      let oppcode: UInt8 = memory.readMemAtCounter()
      log(oppcode, r: 16)
      memory.pc += 1
      
      try dispatch(oppcode)
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
    log("Addressing mode: \(mode)")
    return mode
  }
  
  func loadByteFromMemory() -> UInt8 {
    let addressingMode = unsafeGetAddresingMode()
    
    if addressingMode == .accumulator {
      log("return A register value \(memory.registers.A))")
      return memory.registers.A
    }
    
    let addr = memory.getOpperandAddress(for: addressingMode)
    let byte = memory.readMem(at: addr)
    memory.pc += 1
    log("return byte \(byte)")
    return byte
  }
  
  func loadByteFromMemory() -> UInt16 {
    let addressingMode = unsafeGetAddresingMode()
    
    if addressingMode == .accumulator {
      log("return A register value \(memory.registers.A))")
      return UInt16(memory.registers.A)
    }
    
    let addr = memory.getOpperandAddress(for: addressingMode)
    let byte = memory.readMem16(at: addr)
    memory.pc += 1
    log("return byte \(byte)")
    return byte
  }
  
  func signedValue(from byte: UInt8) -> (UInt8, Bool) {
    let isSigned = byte & 0b1000_0000 != 0
    return (byte & 0b0111_1111, isSigned)
  }
  
  func branch(when condition: Bool) {
    if condition {
      let offset: UInt8 = memory.readMem(at: memory.pc)
      let (singedValue, isSigned): (UInt8, Bool) = signedValue(from: offset)
      
      memory.pc = UInt16(isSigned
      ? offset.subtractingReportingOverflow(singedValue).partialValue
      : offset.addingReportingOverflow(singedValue).partialValue)
    }
  }
  
  func compare(against value: UInt8) {
    let param: UInt8 = loadByteFromMemory()
    let result = value.subtractingReportingOverflow(param).partialValue
    
    if param <= value {
      memory.registers.set(.carry)
    } else {
      memory.registers.clear(.carry)
    }
    
    setZeroAndNegativeFlag(result)
  }
  
  func increment(param: UInt8) -> UInt8 {
    let result = param.addingReportingOverflow(1)
   
    setZeroAndNegativeFlag(result.partialValue)
    
    if result.overflow {
      memory.registers.set(.carry)
    } else {
      memory.registers.clear(.carry)
    }
    
    return result.partialValue
  }
  
  func loadMem(to register: Registers.Accumulator) {
    let param: UInt8 = loadByteFromMemory()
    memory.registers.set(register, to: param)
    setZeroAndNegativeFlag(param)
  }
}
 
// MARK: Opcode functions
extension CPU {
  func ADC() {
    // A,Z,C,N = A+M+C
    
    let param: UInt8 = loadByteFromMemory()
    
    let carry: UInt16 = memory.registers.isSet(.carry) ? 1 : 0
    let a = UInt16(memory.registers.A)
    let result = a + UInt16(param) + carry

    if result > 0xFF {
      memory.registers.set(.carry)
    } else {
      memory.registers.clear(.carry)
    }
    
    memory.registers.set(.A, to: UInt8(result & 0xFF))
    
    setZeroAndNegativeFlag(memory.registers.A)
  }
    
  func AND() {
    //A,Z,N = A&M
    let param: UInt8 = loadByteFromMemory()
    let result = memory.registers.A & param
    memory.registers.set(.A, to: result)
  }
  
  private func _ASL(param: UInt8) {
    let bit7 = param >> 7
    let result = memory.registers.A << 1

    memory.registers.set(.A, to: result)
    setZeroAndNegativeFlag(result)
    setCarryFlag(result)
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
    
    if (result & 0b0100_0000) > 0 {
      memory.registers.set(.overflow)
    } else {
      memory.registers.clear(.overflow)
    }
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
    memory.stackPush16(memory.pc)
    memory.stackPush(memory.registers.p)
    let vector = memory.readMem16(at: 0xFFFE)
    memory.pc = vector
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
    memory.writeMem(at: memory.pc, value: result)
    setZeroAndNegativeFlag(result)
  }
  
  func DEX() {
    let param = memory.registers.X - 1
    memory.registers.set(.X, to: param)
    setZeroFlag(param)
  }
  
  func DEY() {
    let param = memory.registers.Y - 1
    memory.registers.set(.X, to: param)
    setZeroFlag(param)
  }
  
  func EOR() {
    let param: UInt8 = loadByteFromMemory()
    let result = memory.registers.A ^ param
    memory.registers.set(.A, to: result)
    setZeroAndNegativeFlag(result)
  }
    
  func INC() {
    var param: UInt8 = loadByteFromMemory()
    let i = increment(param: param)
    memory.writeMem(at: memory.pc, value: param)
  }
  
  func INX() {
    let i = increment(param: memory.registers.X)
    memory.registers.set(.X, to: i)
    
  }
  
  func INY() {
    let i = increment(param: memory.registers.Y)
    memory.registers.set(.Y, to: i)
  }
    
  func JMP() {
    let ptr = memory.readMem16(at: memory.pc)
    memory.pc = ptr
  }
  
  func JSR() {
    let param: UInt16 = loadByteFromMemory()
    memory.stackPush16(memory.pc)
    memory.pc = param
  }
  
  func LDA() {
    loadMem(to: .A)
  }
  
  func LDX() {
    loadMem(to: .X)
  }
  
  func LDY() {
    loadMem(to: .Y)
  }
  
  func _LSR(param: UInt8) -> UInt8 {
    let result = param >> 1
    setZeroAndNegativeFlag(result)
    setCarryFlag(result)
    return result
  }
    
  func LSR() {
    let ptr: UInt8 = loadByteFromMemory()
    var mem = memory.readMem(at: MemoryAddress(ptr))
    
    mem = _LSR(param: mem)
    memory.writeMem(at: MemoryAddress(ptr), value: mem)
  }
  
  func LSR_accumulator() {
    var mem = _LSR(param: memory.registers.A)
    memory.registers.set(.A, to: mem)
  }
  
  func NOP() {
    // NOP
  }
  
  func ORA() {
    let param: UInt8 = loadByteFromMemory()
    let result = memory.registers.A
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
  
  private func _ROL(param: UInt8) -> UInt8 {
    let msb = param >> 7
    let result = (param << 1) | msb
    
    setZeroAndNegativeFlag(param)
    setCarryFlag(param)
    
    return result
  }
  
  func ROL() {
    let memoryAddress: UInt8 = loadByteFromMemory()
    var param = memory.readMem(at: MemoryAddress(memoryAddress))
    memory.writeMem(at: MemoryAddress(memoryAddress), value: _ROL(param: param))
  }
  
  func ROL_accumulator() {
    memory.registers.set(.A, to: _ROL(param: memory.registers.A))
  }
  
  private func _ROR(param: UInt8) -> UInt8 {
    let previousCarry: UInt8 = memory.registers.isSet(.carry) ? 1 : 0
    let lsb = param & 1
    
    let result = (param >> 1) | (previousCarry << 7)
    
    setZeroFlag(result)
    setNegativeFlag(result)
    setCarryFlag(lsb)
    
    return result
  }
  
  func ROR() {
    let memoryAddress: UInt8 = loadByteFromMemory()
    var param = memory.readMem(at: MemoryAddress(memoryAddress))
    
    let result = _ROL(param: param)
    
    memory.writeMem(at: memory.pc, value: result)
  }
  
  func ROR_accumulator() {
    let result = _ROL(param: memory.registers.A)
    memory.registers.set(.A, to: result)
  }
  
  func RTI() {
    let programStatus = memory.stackPop()
    let pc = memory.stackPop16()
    
    memory.registers.set(programStatus: programStatus)
    memory.pc = pc
  }
  
  func RTS() {
    let returnAddress = memory.stackPop16()
    memory.pc = returnAddress
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
  
  private func _STA(value: UInt8) {
    let memoryAddress: UInt8 = loadByteFromMemory()
    memory.writeMem(at: MemoryAddress(memoryAddress), value: value)
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
    memory.registers.set(.X, to: memory.sp)
    setZeroFlag(memory.sp)
  }
  
  func TXA() {
    memory.registers.set(.X, to: memory.registers.A)
    setZeroFlag(memory.registers.A)
  }
  
  func TXS() {
    memory.sp = memory.registers.X
  }
  
  func TYA() {
    memory.registers.set(.A, to: memory.registers.Y)
    setZeroFlag(<#T##value: UInt8##UInt8#>)
  }
}

// Helpers

private extension CPU {
  
  func setCarryFlag(_ value: UInt8) {
    if value & (1 << 7) != 0 {
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
  
  func setNegativeFlag(_ value: UInt8) {
    if value & (1 << 7) != 0 {
      memory.registers.set(.negative)
    } else {
      memory.registers.clear(.negative)
    }
  }
}


