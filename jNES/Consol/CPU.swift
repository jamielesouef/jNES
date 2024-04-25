//
//  6502.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 8/4/2024.
//

import Foundation

final class CPU {
  
  let memory: Memory
  
  private var loop = true
  private var programCounterAtOppcodeRun: UInt16 = 0x00
  
  private var __instructionsBuffer: [UInt16] = []
  
  private (set) var registers: Registers
  private var PC: UInt16 = 0x00
  
  let callback: () -> UInt8
  
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
  
  init(memory: Memory = Memory(),
       registers: Registers = Registers(),
       callback: @escaping () -> UInt8 = { 0x00 }
  ) {
    self.registers = registers
    self.memory = memory
    self.callback = callback
  }
  
  func load(program: [UInt8]) {
    memory.load(program: program)
  }
  
  func reset() {
    memory.reset()
    setProgramCounter(memory.readMem16(at: 0xFFFC))
  }
  
  func run(callback:() -> UInt8) {
    while loop {
      
      let opcode: UInt8 = memory.readMem(at: PC)
      
      let instruction = getInstructions(forOpcode: opcode)
      
      __debug_updateInstructionsBuffer()
      
      let newProgramCounter = PC + 1
      
      setProgramCounter(newProgramCounter)
      programCounterAtOppcodeRun = newProgramCounter
      
      
      log("instruction \(instruction.name) \(String(opcode, radix: 16))")
      instruction.fn()
      
      let controllerState = callback()
      handle(controllerState: controllerState)
      
      // if the opperation does not change the program counter
      // we need to increment it by the number of bytes in the instruction
      let postOpcodePC = PC
      if programCounterAtOppcodeRun == postOpcodePC {
        setProgramCounter(postOpcodePC + UInt16(instruction.bytes) - 1)
      }
    }
  }
  
  func stop() {
    loop = false
    reset()
  }
  
  func setProgramCounter(_ value: UInt16) {
    log("value", value)
    PC = value
  }
  
  func getProgramCounter() -> UInt16 {
    return PC
  }
  
  func getOperand(for mode: AddressingMode) -> UInt16 {
    
    log("addressingMode \(mode.rawValue)")
    switch mode {
    case .accumulator:
      return UInt16(registers.A)
    case .absolute:
      return memory.readMem16(at: PC)
    case .immediate:
      return PC
    case .zeroPage:
      return UInt16(memory.readMem(at: PC))
    case .zeroPageX:
      let data: UInt8 = memory.readMem(at: PC)
      let addr = data.addingReportingOverflow(registers.X).partialValue
      return UInt16(addr)
    case .zeroPageY:
      let data: UInt8 = memory.readMem(at: PC)
      let addr = data.addingReportingOverflow(registers.Y).partialValue
      return UInt16(addr)
    case .absoluteX:
      let data = memory.readMem16(at: PC)
      let addr = data.addingReportingOverflow(UInt16(registers.X)).partialValue
      return addr
    case .absoluteY:
      let data = memory.readMem16(at: PC)
      let addr = data.addingReportingOverflow(UInt16(registers.Y)).partialValue
      return addr
    case .indirectX:
      return indirectX()
    case .indirectY:
      return indirectY()
    default: fatalError("Addressing mode: \(mode) not implemented")
    }
  }
  
  func __debug_getInstructionsBuffer() -> [String] {
    __instructionsBuffer.reversed().map {
      let hex = String($0, radix: 16)
      let op = _debug_compiledSnake[$0] ?? ""
      
      return "\(hex):\(op)"
    }
  }
  
  private func __debug_updateInstructionsBuffer() {
    
    guard _debug_compiledSnake.keys.contains(PC) else {
      return
    }
    
    if __instructionsBuffer.count == 1000 {
      let _ = __instructionsBuffer.popLast()
    }
    
    __instructionsBuffer.insert(PC, at: 0)
    
  }
}

private extension CPU {
  
  func indirectX() -> UInt16 {
    let storedAddress: UInt8 = memory.readMem(at: PC)
    let addr = storedAddress.addingReportingOverflow(registers.X).partialValue
    
    let lo = UInt16(memory.readMem(at: UInt16(addr)))
    let hi = UInt16(memory.readMem(at: UInt16(addr.addingReportingOverflow(1).partialValue)))
    let ptr = (hi << 8) | lo
    return ptr
  }
  
  func indirectY() -> UInt16 {
    let storedAddress = UInt16(memory.readMem(at: PC))
    let lo: UInt8 = memory.readMem(at: storedAddress)
    let hi: UInt8 = memory.readMem(at: storedAddress.addingReportingOverflow(1).partialValue)
    let pointer = UInt16(hi) << 8 | UInt16(lo)
    return pointer.addingReportingOverflow(UInt16(registers.Y)).partialValue
  }
  // MARK: - Addressing mode
  
  func handle(controllerState state: UInt8) {
    print("state", state)
    if state & ControllerButton.left.mask != 0 {
      memory.writeMem(at: 0xFF, value: 0x61)
      return
    }
    
    if state & ControllerButton.right.mask != 0 {
      memory.writeMem(at: 0xFF, value: 0x64)
      return
    }
    
    if state & ControllerButton.up.mask != 0 {
      memory.writeMem(at: 0xFF, value: 0x77)
      return
    }
    
    if state & ControllerButton.down.mask != 0 {
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
      
      let pc = PC
      let data = memory.readMem(at: pc)
      let signedOffset = Int8(bitPattern: data)
      
      var targetAddress: UInt16
      
      if signedOffset >= 0 {
        targetAddress = pc &+ UInt16(signedOffset) + 1
      } else {
        targetAddress = pc &- UInt16(abs(signedOffset)) + 1
      }
      
      setProgramCounter(targetAddress)
      log("signedOffset", Int(signedOffset))
      log("pc, data, targetAddress", UInt16(data), pc, targetAddress)
      
    }
  }
  
  func compare(against value: UInt8, mode: AddressingMode) {
    compare(against: Int(value), mode: mode)
  }
  
  func compare(against value: Int, mode: AddressingMode) {
    let addr = getOperand(for: mode)
    let data = Int(memory.readMem(at: addr))
    
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
}

// MARK: Opcode functions
extension CPU {
  
  func ADC(mode: AddressingMode) {
    
    let addr = getOperand(for: mode)
    let data = UInt16(memory.readMem(at: addr))
    
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
    log("param, result", UInt16(data), result)
  }
  
  func AND(mode: AddressingMode) {
    //A,Z,N = A&M
    let addr = getOperand(for: mode)
    let data = memory.readMem(at: addr)
    let result = data & registers.A
    
    setRegisterA(result)
    
    log("data, result", data, result)
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
    var data = memory.readMem(at: addr)
    
    ASL_Logic(&data)
    
    memory.writeMem(at: addr, value: data)
  }
  
  func ASL(mode: AddressingMode) {
    
    if mode == .accumulator {
      ASL_accumulator()
      return
    }
    
    ASL_memory(mode: mode)
    
//    var data: UInt8!
//    let addr = getOperand(for: mode)
//    
//    if mode == .accumulator {
//      data = registers.A
//    } else {
//      data = memory.readMem(at: addr)
//    }
//    
//    setCarryFlag(data >> 7 == 1)
//    
//    data = (data << 1) & 0xFE
//    
//    if mode == .accumulator {
//      registers.set(.A, to: data)
//    } else {
//      memory.writeMem(at: addr, value: data)
//    }
//    
//    setZeroFlag(data == 0)
//    setNegativeFlag(data >> 7 == 1)
    
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
    let data = memory.readMem(at: addr)
    let a = registers.A
    
    let result = data & a
    
    setNegativeFlag(result)
    setOverflowFlag(result)
    setZeroFlag(result)
    
    log("data, a, result", data, a, result)
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
    //    let vector = memory.readMem16(at: 0xFFFE)
    //
    //    memory.stackPush16(pc)
    //    memory.stackPush(registers.p)
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
    log("carry flag", registers.isSet(.carry) ? 1 : 0)
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
    log("CMP")
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
    let data = memory.readMem(at: addr)

    let result = decrement(data)
    memory.writeMem(at: addr, value: result)
    
  }
  
  // Decrement X Register
  func DEX() {
    let x = decrement(registers.X)
    registers.set(.X, to: x)
  }
  
  // Decrement Y Register
  func DEY() {
    registers.set(.Y, to: decrement(registers.Y))
  }
  
  // Exclusive OR
  func EOR(mode: AddressingMode) {
    let addr = getOperand(for: mode)
    let data = memory.readMem(at: addr)
    let result = registers.A ^ data
    
    setRegisterA(result)
  }
  
  // Increment Memory
  func INC(mode: AddressingMode) {
    let addr = getOperand(for: mode)
    let data = Int(memory.readMem(at: addr)) + 1
    
    setNegativeFlag((data >> 7) == 1)
    setZeroFlag((data & 0xFF) == 0)
    
    memory.writeMem(at: addr, value: UInt8(data & 0xFF))
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
      
      let ptr: UInt16 = memory.readMem16(at: PC)
      setProgramCounter(ptr)
      
    case .indirect:
      
      
      let ptr: UInt16 = memory.readMem16(at: PC)
      
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
        let lo = memory.readMem(at: ptr)
        let hi = memory.readMem(at: ptr & 0xFF00)
        indrectPtr = UInt16(hi) << 8 | UInt16(lo)
      } else {
        indrectPtr = memory.readMem16(at: ptr)
      }
      
      setProgramCounter(indrectPtr)
      
    default:
      fatalError("Invalid addressing mode for JMP")
    }
  }
  
  
  // Jump to Subroutine
  func JSR() {
    memory.stackPush16(PC + 1)
    let addr = memory.readMem16(at: PC)
    PC = addr
  }
  
  // Load Accumulator
  func LDA(mode: AddressingMode) {
    let addr = getOperand(for: mode)
    let data = memory.readMem(at: addr)
    
    setRegisterA(data)
    
  }
  
  // Load X Register
  func LDX(mode: AddressingMode) {
    let addr = getOperand(for: mode)
    let data = memory.readMem(at: addr)
    registers.set(.X, to: data)
    setZeroFlag(data)
    setNegativeFlag(data)
  }
  
  // Load Y Register
  func LDY(mode: AddressingMode) {
    let addr = getOperand(for: mode)
    let data = memory.readMem(at: addr)
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
    var data = memory.readMem(at: addr)
    
    LSR_Logic(&data)
    
    memory.writeMem(at: addr, value: data)
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
    let data = memory.readMem(at: addr)
    let result = registers.A | data
    
    setRegisterA(result)
  }
  
  // Push Accumulator
  func PHA() {
    memory.stackPush(registers.A)
  }
  
  // Push Processor Status
  func PHP() {
    memory.stackPush(registers.p)
  }
  
  // Pull Accumulator
  func PLA() {
    let result = memory.stackPop()
    setRegisterA(result)
  }
  
  // Pull Processor Status
  func PLP() {
    registers.set(programStatus: memory.stackPop())
  }
  
  private func ROL_logic(_ data: inout UInt8) {
    let carry = (data >> 7) & 0x1
    setCarryFlag(carry == 1)
    
    data = data << 1
    data = data | (registers.isSet(.carry) ? 1 : 0)
    
    setCarryFlag(data)
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
    var data = memory.readMem(at: addr)
    
    ROL_logic(&data)
    
    memory.writeMem(at: addr, value: data)
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
    var data = memory.readMem(at: addr)
    
    ROR_Logic(&data)
    
    memory.writeMem(at: addr, value: data)
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
    let programStatus = memory.stackPop()
    let pc = memory.stackPop16()
    
    registers.set(programStatus: programStatus)
    setProgramCounter(pc)
  }
  
  // Return from Subroutine
  func RTS() {
    
    let returnAddress = memory.stackPop16() + 1
    setProgramCounter(returnAddress)
  }
  
  // Subtract with Carry
  func SBC(mode: AddressingMode) {
    let addr = getOperand(for: mode)
    let data = Int(memory.readMem(at: addr))
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
    memory.writeMem(at: address, value: registers.A)
  }
  
  // Store X Register
  func STX(mode: AddressingMode) {
    let address = getOperand(for: mode)
    memory.writeMem(at: address, value: registers.X)
  }
  
  // Store Y Register
  func STY(mode: AddressingMode) {
    let address = getOperand(for: mode)
    memory.writeMem(at: address, value: registers.Y)
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
    registers.set(.X, to: memory.getStackPointer())
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
    memory.setStackPointer(registers.X)
    setZeroFlag(registers.X)
    setNegativeFlag(registers.X)
  }
  
  //Transfer Y to Accumulator
  func TYA() {
    setRegisterA(registers.Y)
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
