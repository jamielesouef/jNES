//
//  CPU+Instructions.swift
//  jNES
//
//  Created by Jamie Le Souef on 3/5/2024.
//

import Foundation

extension CPU {
  
  func ADC(mode: AddressingMode) {
    
    let addr = getOperand(for: mode)
    let data = UInt16(readMem(at: addr))
    
    let result = UInt16(registers.A) + data + (registers.isSet(.carry) ? 1 : 0)
    
    setZeroFlag((result & 0xFF) == 0)
    
    if ((data ^ result) & (result ^ UInt16(registers.A)) & 0x80) != 0 {
      registers.set(.overflow)
    } else {
      registers.clear(.overflow)
    }
    
    registers.set(.A, to: UInt8(result & 0xFF))
    
    setCarryFlag(result > 0xFF)
    setNegativeFlag((result >> 7) & 0x1 == 1)
  }
  
  func AND(mode: AddressingMode) {
    //A,Z,N = A&M
    let addr = getOperand(for: mode)
    let data = readMem(at: addr)
    let result = data & registers.A
    
    setRegisterA(result)
    
  }
  
  private func ASL_Logic(_ data: inout UInt8) {
    setCarryFlag(data >> 7 == 1)
    
    data = (data << 1) & 0xFE
    
    setZeroFlag(data == 0)
    setNegativeFlag(data >> 7 == 1)
  }
  
  private func ASL_accumulator() {
    var data = registers.A
    ASL_Logic(&data)
    registers.set(.A, to: data)
  }
  
  private func ASL_memory(mode: AddressingMode) {
    let addr = getOperand(for: mode)
    var data = readMem(at: addr)
    
    ASL_Logic(&data)
    
    writeMem(at: addr, value: data)
  }
  
  func ASL(mode: AddressingMode) {
    
    if mode == .accumulator {
      ASL_accumulator()
      return
    }
    
    ASL_memory(mode: mode)
    
  }
  // Branch if Carry Clear
  func BCC() {
    branch(when: !registers.isSet(.carry))
  }
  
  // Branch if Carry Clear
  func BCS() {
    branch(when: !registers.isSet(.carry))
  }
  
  // Branch if Equal
  func BEQ() {
    branch(when: registers.isSet(.zero))
  }
  
  
  func BIT(mode: AddressingMode) {
    let addr = getOperand(for: mode)
    let data = readMem(at: addr)
    let a = registers.A
    
    let result = data & a
    
    setNegativeFlag(result)
    setOverflowFlag(result)
    setZeroFlag(result)
    
  }
  
  // Branch if negative
  func BMI() {
    branch(when: registers.isSet(.negative))
  }
  
  func BNE() {
    branch(when: !registers.isSet(.zero))
  }
  
  func BPL() {
    branch(when: !registers.isSet(.negative))
  }
  
  // Break
  func BRK() {
    //
    //    let vector = readMem16(at: 0xFFFE)
    //
    //    stackPush16(pc)
    //    stackPush(registers.p)
    //    setProgramCounter(vector)
    
    return
  }
  
  // Branch if Overflow Clear
  func BVC() {
    branch(when: !registers.isSet(.overflow))
  }
  
  // Branch if Overflow Set
  func BVS() {
    branch(when: registers.isSet(.overflow))
  }
  
  // Clear Carry Flag
  func CLC() {
    setCarryFlag(false)
  }
  
  // Clear Decimal Mode
  func CLD() {
    registers.clear(.decimal)
  }
  
  // Clear Interrupt Disable
  func CLI() {
    registers.clear(.interrupt)
  }
  
  // Clear Overflow Flag
  func CLV() {
    setOverflowFlag(false)
  }
  
  // Compare Accumulator
  func CMP(mode: AddressingMode) {
    compare(against: registers.A, mode: mode)
  }
  
  // Compare X Register
  func CPX(mode: AddressingMode) {
    compare(against: registers.X, mode: mode)
  }
  
  // Compare Y Register
  func CPY(mode: AddressingMode) {
    compare(against: registers.Y, mode: mode)
  }
  
  // Decrement Memory
  
  private func decrement(_ value: UInt8) -> UInt8 {
    let result = UInt8((Int(value) - 1) & 0xFF)
    setNegativeFlag((result >> 7) & 0x1 == 1)
    setZeroFlag(result == 0)
    
    return result
  }
  
  func DEC(mode: AddressingMode) {
    let addr = getOperand(for: mode)
    let data = readMem(at: addr)
    
    let result = decrement(data)
    writeMem(at: addr, value: result)
    
  }
  
  // Decrement X Register
  func DEX() {
    registers.set(.X, to: decrement(registers.X))
  }
  
  // Decrement Y Register
  func DEY() {
    registers.set(.Y, to: decrement(registers.Y))
  }
  
  // Exclusive OR
  func EOR(mode: AddressingMode) {
    let addr = getOperand(for: mode)
    let data = readMem(at: addr)
    let result = registers.A ^ data
    
    setRegisterA(result)
  }
  
  // Increment Memory
  func INC(mode: AddressingMode) {
    let addr = getOperand(for: mode)
    let data = Int(readMem(at: addr)) + 1
    
    setNegativeFlag((data >> 7) == 1)
    setZeroFlag((data & 0xFF) == 0)
    
    writeMem(at: addr, value: UInt8(data & 0xFF))
  }
  
  // Increment X Register
  func INX() {
    let data = Int(registers.X) + 1
    
    setNegativeFlag((data >> 7) == 1)
    setZeroFlag((data & 0xFF) == 0)
    
    registers.set(.X, to: UInt8(data & 0xFF))
  }
  
  // Increment Y Register
  func INY() {
    let data = Int(registers.Y) + 1
    
    setNegativeFlag((data >> 7) == 1)
    setZeroFlag((data & 0xFF) == 0)
    
    registers.set(.Y, to: UInt8(data & 0xFF))
  }
  
  func JMP(mode: AddressingMode) {
    switch mode {
    case .absolute:
      
      let ptr: UInt16 = readMem16(at: PC)
      setProgramCounter(ptr)
      
    case .indirect:
      
      
      let ptr: UInt16 = readMem16(at: PC)
      
      /*
       NB:
       An original 6502 has does not correctly fetch the target address if
       the indirect vector falls on a page boundary (e.g. $xxFF where xx is
       any value from $00 to $FF). In this case fetches the LSB from $xxFF
       as expected but takes the MSB from $xx00. This is fixed in some
       later chips like the 65SC02 so for compatibility always ensure the
       indirect vector is not at the end of the page.
       */
      
      var indrectPtr: UInt16!
      
      if ptr & 0x00FF == 0x00FF {
        let lo = readMem(at: ptr)
        let hi = readMem(at: ptr & 0xFF00)
        indrectPtr = UInt16(hi) << 8 | UInt16(lo)
      } else {
        indrectPtr = readMem16(at: ptr)
      }
      
      setProgramCounter(indrectPtr)
      
    default:
      fatalError("Invalid addressing mode for JMP")
    }
  }
  
  
  // Jump to Subroutine
  func JSR() {
    stackPush16(PC + 1)
    let addr = readMem16(at: PC)
    setProgramCounter(addr)
  }
  
  // Load Accumulator
  func LDA(mode: AddressingMode) {
    let addr = getOperand(for: mode)
    let data = readMem(at: addr)
    
    setRegisterA(data)
    
  }
  
  // Load X Register
  func LDX(mode: AddressingMode) {
    let addr = getOperand(for: mode)
    let data = readMem(at: addr)
    registers.set(.X, to: data)
    setZeroFlag(data)
    setNegativeFlag(data)
  }
  
  // Load Y Register
  func LDY(mode: AddressingMode) {
    let addr = getOperand(for: mode)
    let data = readMem(at: addr)
    registers.set(.Y, to: data)
    setZeroFlag(data)
    setNegativeFlag(data)
  }
  
  
  // Logical Shift Right
  
  private func LSR_Logic(_ data: inout UInt8) {
    setCarryFlag((data & 0x1) == 1)
    
    data = (data >> 1) & 0x7F
    
    setNegativeFlag(false)
    setZeroFlag(data)
    setCarryFlag(data)
  }
  
  private func LSR_Accumulator() {
    var data = registers.A
    LSR_Logic(&data)
    registers.set(.A, to: data)
  }
  
  private func LSR_Memory(mode: AddressingMode) {
    let addr = getOperand(for: mode)
    var data = readMem(at: addr)
    
    LSR_Logic(&data)
    
    writeMem(at: addr, value: data)
  }
  
  func LSR(mode: AddressingMode) {
    if mode == .accumulator {
      LSR_Accumulator()
    } else {
      LSR_Memory(mode: mode)
    }
  }
  
  // No Operation
  func NOP() {
    // NOP
  }
  
  // Logical Inclusive OR
  func ORA(mode: AddressingMode) {
    let addr = getOperand(for: mode)
    let data = readMem(at: addr)
    let result = registers.A | data
    
    setRegisterA(result)
  }
  
  // Push Accumulator
  func PHA() {
    stackPush(registers.A)
  }
  
  // Push Processor Status
  func PHP() {
    stackPush(registers.p)
  }
  
  // Pull Accumulator
  func PLA() {
    let result = stackPop()
    setRegisterA(result)
  }
  
  // Pull Processor Status
  func PLP() {
    registers.set(programStatus: stackPop())
  }
  
  private func ROL_logic(_ data: inout UInt8) {
    let carry = (data >> 7) & 0x1
    setCarryFlag(carry == 1)
    
    data = data << 1
    data = data + (registers.isSet(.carry) ? 1 : 0)
    
    setZeroFlag(data == 0)
    setNegativeFlag(data >> 7 == 1)
  }
  
  private func ROL_accumulator() {
    
    var data = registers.A
    
    ROL_logic(&data)
    
    registers.set(.A, to: data)
  }
  
  // Rotate Left
  private func ROL_memory(mode: AddressingMode) {
    let addr = getOperand(for: mode)
    var data = readMem(at: addr)
    
    ROL_logic(&data)
    
    writeMem(at: addr, value: data)
  }
  
  
  // Rotate Left
  func ROL(mode: AddressingMode) {
    if mode == .accumulator {
      ROL_accumulator()
      return
    }
    
    ROL_memory(mode: mode)
  }
  
  // Rotate Right
  
  
  private func ROR_Logic(_ data: inout UInt8) {
    data = (data >> 1) & 0x7F
    data = data | (registers.isSet(.carry) ? 0x80:0)
    
    setZeroFlag(data)
    setNegativeFlag(data)
    setCarryFlag(data)
  }
  
  private func ROR_accumulator() {
    
    var data = registers.A
    
    ROR_Logic(&data)
    
    registers.set(.A, to: data)
  }
  
  private func ROR_memory(mode: AddressingMode) {
    
    let addr = getOperand(for: mode)
    var data = readMem(at: addr)
    
    ROR_Logic(&data)
    
    writeMem(at: addr, value: data)
  }
  
  func ROR(mode: AddressingMode) {
    if mode == .accumulator {
      ROR_accumulator()
      return
    }
    
    ROR_memory(mode: mode)
  }
  
  
  // Return from interrupt
  func RTI() {
    let programStatus = stackPop()
    let pc = stackPop16()
    
    registers.set(programStatus: programStatus)
    setProgramCounter(pc)
  }
  
  // Return from Subroutine
  func RTS() {
    
    let returnAddress = stackPop16() + 1
    setProgramCounter(returnAddress)
  }
  
  // Subtract with Carry
  func SBC(mode: AddressingMode) {
    let addr = getOperand(for: mode)
    let data = Int(readMem(at: addr))
    let a = Int(registers.A)
    
    let result = a - data - (registers.isSet(.carry) ? 1:0)
    
    //    setOverflowFlag(((a ^ data) & (a ^ UInt8(result & 0xFF)) & 0x80) == 0x80)
    setCarryFlag(result >= 0)
    setNegativeFlag(UInt8(result & 0xFF) == 1)
    setZeroFlag(result & 0xFF == 0)
    
    registers.set(.A, to: UInt8(result & 0xFF))
    
  }
  
  // Set Carry Flag
  func SEC() {
    registers.set(.carry)
  }
  
  
  // Set Decimal Flag
  func SED() {
    registers.set(.decimal)
  }
  
  // Set Interrupt Disable
  func SEI() {
    registers.set(.interrupt)
  }
  
  // Store Accumulator
  func STA(mode: AddressingMode) {
    let address = getOperand(for: mode)
    writeMem(at: address, value: registers.A)
  }
  
  // Store X Register
  func STX(mode: AddressingMode) {
    let address = getOperand(for: mode)
    writeMem(at: address, value: registers.X)
  }
  
  // Store Y Register
  func STY(mode: AddressingMode) {
    let address = getOperand(for: mode)
    writeMem(at: address, value: registers.Y)
  }
  
  // Transfer Accumulator to X
  func TAX() {
    registers.set(.X, to: registers.A)
    setZeroFlag(registers.X)
    setNegativeFlag(registers.X)
  }
  
  // Transfer Accumulator to Y
  func TAY() {
    registers.set(.Y, to: registers.A)
    setZeroFlag(registers.Y)
    setNegativeFlag(registers.Y)
  }
  
  // Transfer Stack Pointer to X
  func TSX() {
    registers.set(.X, to: getStackPointer())
    setZeroFlag(registers.X)
    setNegativeFlag(registers.X)
  }
  
  //Transfer X to Accumulator
  func TXA() {
    setRegisterA(registers.X)
    setZeroFlag(registers.X)
    setNegativeFlag(registers.X)
  }
  
  // Transfer X to Stack Pointer
  func TXS() {
    setStackPointer(registers.X)
    setZeroFlag(registers.X)
    setNegativeFlag(registers.X)
  }
  
  //Transfer Y to Accumulator
  func TYA() {
    setRegisterA(registers.Y)
  }
  
  //MARK: - Illegal Opcodes
  
  func AAC(mode: AddressingMode) {
    fatalError("Illegal Opcode AAC")
    
  }
  
  func AAX(mode: AddressingMode) {
    fatalError("Illegal Opcode AAX")
  }
  
  func ARR(mode: AddressingMode) {
    fatalError("Illegal Opcode ASR")
  }
  
  func ASR(mode: AddressingMode) {
    fatalError("Illegal Opcode ASR")
  }
  
  func ATX(mode: AddressingMode) {
    fatalError("Illegal Opcode ATX")
  }
  
  func AXA(mode: AddressingMode) {
    fatalError("Illegal Opcode AXA")
  }
  
  func AXS(mode: AddressingMode) {
    fatalError("Illegal Opcode AXS")
  }
  
  func DCP(mode: AddressingMode) {
    fatalError("Illegal Opcode DCP")
  }
  
  func DOP(mode: AddressingMode) {
    fatalError("Illegal Opcode DOP")
  }
  
  func ISC(mode: AddressingMode) {
    fatalError("Illegal Opcode ISC")
  }
  
  func KIL() {
    fatalError("Illegal Opcode KIL")
  }
  
  func LAR(mode: AddressingMode) {
    fatalError("Illegal Opcode LAR")
  }
  
  func LAX(mode: AddressingMode) {
    fatalError("Illegal Opcode LAX")
  }
  
  func RLA(mode: AddressingMode) {
    fatalError("Illegal Opcode RLA")
  }
  
  func RLN(mode: AddressingMode) {
    fatalError("Illegal Opcode RLN")
  }
  
  func RRA(mode: AddressingMode) {
    fatalError("Illegal Opcode RRA")
  }
  
  func SLO(mode: AddressingMode) {
    fatalError("Illegal Opcode SLO")
  }
  
  func SRE(mode: AddressingMode) {
    fatalError("Illegal Opcode SRE")
  }
  
  func SXA(mode: AddressingMode) {
    fatalError("Illegal Opcode SXA")
  }
  
  func SYA(mode: AddressingMode) {
    fatalError("Illegal Opcode SYA")
  }
  
  func TOP(mode: AddressingMode) {
    fatalError("Illegal Opcode TOP")
  }
  
  func XAA(mode: AddressingMode) {
    fatalError("Illegal Opcode XAA")
  }
  
  func XAS(mode: AddressingMode) {
    fatalError("Illegal Opcode XAS")
  }
  
}
  
