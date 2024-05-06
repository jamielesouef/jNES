//
//  CPU+Instructions.swift
//  jNES
//
//  Created by Jamie Le Souef on 3/5/2024.
//

import Foundation

extension CPU {
  
  func ADC(mode: AddressingMode) {
    
    let addr = getAddressForOpperate(with: mode, at: PC)
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
    let addr = getAddressForOpperate(with: mode, at: PC)
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
    let addr = getAddressForOpperate(with: mode, at: PC)
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
  
  // Branch if Carry Set
  func BCS() {
    branch(when: registers.isSet(.carry))
  }
  
  // Branch if Equal
  func BEQ() {
    branch(when: registers.isSet(.zero))
  }
  
  
  func BIT(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    let data = readMem(at: addr)
    let a = registers.A
    
    let result = data & a
    
    setFlag(.negative, condition: (data >> 7) == 1)
    setFlag(.overflow, condition: ((data >> 6) & 0x1) == 1)
    setFlag(.zero, condition: (result == 0))
    
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
    let addr = getAddressForOpperate(with: mode, at: PC)
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
    let addr = getAddressForOpperate(with: mode, at: PC)
    let data = readMem(at: addr)
    let result = registers.A ^ data
    
    setRegisterA(result)
  }
  
  // Increment Memory
  func INC(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
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
    let addr = getAddressForOpperate(with: .absolute, at: PC)
    setProgramCounter(addr)
  }
    
  
  // Logical Shift Right
  
  private func LSR_Logic(_ data: inout UInt8) {
    setFlag(.negative, condition: false)
    setFlag(.carry, condition: (data & 0x1) == 1)
    
    data = (data >> 1) & 0x7F
              
    setFlag(.zero, condition: (data == 0))
  }
  
  private func LSR_Accumulator() {
    var data = registers.A
    LSR_Logic(&data)
    registers.set(.A, to: data)
  }
  
  private func LSR_Memory(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    var data = readMem(at: addr)
    
    LSR_Logic(&data)
    
    writeMem(at: addr, value: data)
  }
  
  func LSR(mode: AddressingMode) {
    if mode == .accumulator {
      LSR_Accumulator()
      return
    }
      
    LSR_Memory(mode: mode)
  }
  
  // No Operation
  func NOP() {
    // NOP
  }
  
  // Logical Inclusive OR
  func ORA(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
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
    let p = registers.p | 1 << 4
    
    stackPush(p)
  }
  
  // Pull Accumulator
  func PLA() {
    let result = stackPop()
    setRegisterA(result)
  }
  
  // Pull Processor Status
  func PLP() {
    registers.set(programStatus: stackPop())
    registers.clear(.b)
    registers.set(.b2)
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
    let addr = getAddressForOpperate(with: mode, at: PC)
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
    let carry = data & 0x1
    
    data = (data >> 1) & 0x7F
    data = data | (registers.isSet(.carry) ? 0x80 : 0)
    
    
    setFlag(.carry, condition: carry == 1)
    setFlag(.zero, condition: (data == 0))
    setFlag(.negative, condition: (data >> 7) & 0x1 == 1)
  }
  
  private func ROR_accumulator() {
    
    var data = registers.A
    
    ROR_Logic(&data)
    
    registers.set(.A, to: data)
  }
  
  private func ROR_memory(mode: AddressingMode) {
    
    let addr = getAddressForOpperate(with: mode, at: PC)
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
    registers.clear(.b)
    registers.set(.b2)
    setProgramCounter(pc)
  }
  
  // Return from Subroutine
  func RTS() {
    
    let returnAddress = stackPop16() + 1
    setProgramCounter(returnAddress)
  }
  
  // Subtract with Carry
  func SBC(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    let data = readMem(at: addr)
    
    let result = Int(registers.A) - Int(data) - (registers.isSet(.carry) ? 0:1)
    
    setFlag(.overflow, condition: ((registers.A ^ data) & (registers.A ^ UInt8(result & 0xFF)) & 0x80) == 0x80)
    setFlag(.carry, condition: result >= 0)
    setFlag(.negative, condition: ((result >> 7) & 0x1) == 1)
    setFlag(.zero, condition: (result & 0xFF) == 0)
    
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
  
  // Load Accumulator
  func LDA(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    let data = readMem(at: addr)
    
    setRegisterA(data)
    
  }
  
  // Load X Register
  func LDX(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    let data = readMem(at: addr)
    registers.set(.X, to: data)
    setZeroFlag(data)
    setNegativeFlag(data)
  }
  
  // Load Y Register
  func LDY(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    let data = readMem(at: addr)
    registers.set(.Y, to: data)
    setZeroFlag(data)
    setNegativeFlag(data)
  }
  
  // Store Accumulator
  func STA(mode: AddressingMode) {
    let address = getAddressForOpperate(with: mode, at: PC)
    writeMem(at: address, value: registers.A)
  }
  
  // Store X Register
  func STX(mode: AddressingMode) {
    let address = getAddressForOpperate(with: mode, at: PC)
    writeMem(at: address, value: registers.X)
  }
  
  // Store Y Register
  func STY(mode: AddressingMode) {
    let address = getAddressForOpperate(with: mode, at: PC)
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
//    setZeroFlag(registers.X)
//    setNegativeFlag(registers.X)
  }
  
  //Transfer Y to Accumulator
  func TYA() {
    setRegisterA(registers.Y)
  }
  
  //MARK: - Illegal Opcodes
  
  func AAC(mode: AddressingMode) {
    fatalError("Opcode AAC not implimented")
    
  }
  
  func AAX(mode: AddressingMode) {
    fatalError("Opcode AAX not implimented")
  }
  
  func ARR(mode: AddressingMode) {
    fatalError("Opcode ASR not implimented")
  }
  
  func ASR(mode: AddressingMode) {
    fatalError("Opcode ASR not implimented")
  }
  
  func ATX(mode: AddressingMode) {
    fatalError("Opcode ATX not implimented")
  }
  
  func AXA(mode: AddressingMode) {
    fatalError("Opcode AXA not implimented")
  }
  
  func AXS(mode: AddressingMode) {
    fatalError("Opcode AXS not implimented")
  }
  
  func DCP(mode: AddressingMode) {
    fatalError("Opcode DCP not implimented")
  }
  
  func DOP(mode: AddressingMode) {
    fatalError("Opcode DOP not implimented")
  }
  
  func ISC(mode: AddressingMode) {
    fatalError("Opcode ISC not implimented")
  }
  
  func KIL() {
    fatalError("Opcode KIL not implimented")
  }
  
  func LAR(mode: AddressingMode) {
    fatalError("Opcode LAR not implimented")
  }
  
  func LAX(mode: AddressingMode) {
    fatalError("Opcode LAX not implimented")
  }
  
  func RLA(mode: AddressingMode) {
    fatalError("Opcode RLA not implimented")
  }
  
  func RLN(mode: AddressingMode) {
    fatalError("Opcode RLN not implimented")
  }
  
  func RRA(mode: AddressingMode) {
    fatalError("Opcode RRA not implimented")
  }
  
  func SLO(mode: AddressingMode) {
    fatalError("Opcode SLO not implimented")
  }
  
  func SRE(mode: AddressingMode) {
    fatalError("Opcode SRE not implimented")
  }
  
  func SXA(mode: AddressingMode) {
    fatalError("Opcode SXA not implimented")
  }
  
  func SYA(mode: AddressingMode) {
    fatalError("Opcode SYA not implimented")
  }
  
  func TOP(mode: AddressingMode) {
    fatalError("Opcode TOP not implimented")
  }
  
  func XAA(mode: AddressingMode) {
    fatalError("Opcode XAA not implimented")
  }
  
  func XAS(mode: AddressingMode) {
    fatalError("Opcode XAS not implimented")
  }
  
}
  
