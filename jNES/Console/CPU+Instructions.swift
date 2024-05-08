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
  
  func BCC() {
    branch(when: !registers.isSet(.carry))
  }
  
  func BCS() {
    branch(when: registers.isSet(.carry))
  }
  
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
  
  func BMI() {
    branch(when: registers.isSet(.negative))
  }
  
  func BNE() {
    branch(when: !registers.isSet(.zero))
  }
  
  func BPL() {
    branch(when: !registers.isSet(.negative))
  }
  
  func BRK() {
    //
    //    let vector = readMem16(at: 0xFFFE)
    //
    //    stackPush16(pc)
    //    stackPush(registers.p)
    //    setProgramCounter(vector)
    
    return
  }
  
  func BVC() {
    branch(when: !registers.isSet(.overflow))
  }
  
  func BVS() {
    branch(when: registers.isSet(.overflow))
  }
  
  func CLC() {
    setCarryFlag(false)
  }
  
  func CLD() {
    registers.clear(.decimal)
  }
  
  func CLI() {
    registers.clear(.interrupt)
  }
  
  func CLV() {
    setOverflowFlag(false)
  }
  
  func CMP(mode: AddressingMode) {
    compare(against: registers.A, mode: mode)
  }
  
  func CPX(mode: AddressingMode) {
    compare(against: registers.X, mode: mode)
  }
  
  func CPY(mode: AddressingMode) {
    compare(against: registers.Y, mode: mode)
  }
  
  
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
  
  func DEX() {
    registers.set(.X, to: decrement(registers.X))
  }
  
  func DEY() {
    registers.set(.Y, to: decrement(registers.Y))
  }
  
  func EOR(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    let data = readMem(at: addr)
    let result = registers.A ^ data
    
    setRegisterA(result)
  }
  
  func INC(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    let data = Int(readMem(at: addr)) + 1
    
    setNegativeFlag((data >> 7) == 1)
    setZeroFlag((data & 0xFF) == 0)
    
    writeMem(at: addr, value: UInt8(data & 0xFF))
  }
  
  func INX() {
    let data = Int(registers.X) + 1
    
    setNegativeFlag((data >> 7) == 1)
    setZeroFlag((data & 0xFF) == 0)
    
    registers.set(.X, to: UInt8(data & 0xFF))
  }
  
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
  
  func JSR() {
    stackPush16(PC + 1)
    let addr = getAddressForOpperate(with: .absolute, at: PC)
    setProgramCounter(addr)
  }
  
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
  
  func NOP() {
    // NOP
  }
  
  func ORA(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    let data = readMem(at: addr)
    let result = registers.A | data
    
    setRegisterA(result)
  }
  
  func PHA() {
    stackPush(registers.A)
  }
  
  func PHP() {
    let p = registers.p | 1 << 4
    
    stackPush(p)
  }
  
  func PLA() {
    let result = stackPop()
    setRegisterA(result)
  }
  
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
  
  private func ROL_memory(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    var data = readMem(at: addr)
    
    ROL_logic(&data)
    
    writeMem(at: addr, value: data)
  }
  
  
  func ROL(mode: AddressingMode) {
    if mode == .accumulator {
      ROL_accumulator()
      return
    }
    
    ROL_memory(mode: mode)
  }
  
  
  
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
  
  
  func RTI() {
    let programStatus = stackPop()
    let pc = stackPop16()
    registers.set(programStatus: programStatus)
    registers.clear(.b)
    registers.set(.b2)
    setProgramCounter(pc)
  }
  
  func RTS() {
    
    let returnAddress = stackPop16() + 1
    setProgramCounter(returnAddress)
  }
  
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
  
  func SEC() {
    registers.set(.carry)
  }
  
  
  func SED() {
    registers.set(.decimal)
  }
  
  func SEI() {
    registers.set(.interrupt)
  }
  
  func LDA(mode: AddressingMode) {
    
    let addr = getAddressForOpperate(with: mode, at: PC)
    let data = readMem(at: addr)
    
    setRegisterA(data)
    
  }
  
  func LDX(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    let data = readMem(at: addr)
    registers.set(.X, to: data)
    setZeroFlag(data)
    setNegativeFlag(data)
  }
  
  func LDY(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    let data = readMem(at: addr)
    registers.set(.Y, to: data)
    
    setFlag(.negative, condition: (data >> 7) == 1)
    setFlag(.zero, condition: (data == 0))
  }
  
  func STA(mode: AddressingMode) {
    let address = getAddressForOpperate(with: mode, at: PC)
    writeMem(at: address, value: registers.A)
  }
  
  func STX(mode: AddressingMode) {
    let address = getAddressForOpperate(with: mode, at: PC)
    writeMem(at: address, value: registers.X)
  }
  
  func STY(mode: AddressingMode) {
    let address = getAddressForOpperate(with: mode, at: PC)
    writeMem(at: address, value: registers.Y)
  }
  
  func TAX() {
    registers.set(.X, to: registers.A)
    setZeroFlag(registers.X)
    setNegativeFlag(registers.X)
  }
  
  func TAY() {
    registers.set(.Y, to: registers.A)
    setZeroFlag(registers.Y)
    setNegativeFlag(registers.Y)
  }
  
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
  
  func TXS() {
    setStackPointer(registers.X)
  }
  
  
  func TYA() {
    setRegisterA(registers.Y)
  }
  
  //MARK: - Illegal Opcodes
  
  func SAX(mode: AddressingMode) {
    let result = registers.A & registers.X
    writeMem(at: getAddressForOpperate(with: mode, at: PC), value: result)
  }
  
  func DCP(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    var data = Int(readMem(at: addr))
    data -= 1
    
    let result = Int(registers.A) - Int(data)
    
    setFlag(.negative, condition: ((result >> 7) & 0x1) == 1)
    setFlag(.zero, condition: (result & 0xFF) == 0)
    setFlag(.carry, condition: registers.A >= data)
    
    writeMem(at: addr, value: UInt8(data & 0xFF))
    
  }
  
  func ISB(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    var data = Int(readMem(at: addr))
    
    data += 1
    
    let a = Int(registers.A) &- Int(data & 0xFF) &- (registers.isSet(.carry) ? 0 : 1)
    
    
    setFlag(.carry, condition: a >= 0)
    setFlag(.zero, condition: a == 0)
    setFlag(.negative, condition: ((a >> 7) & 0xF) == 1)
    
    setFlag(.overflow, condition: ((registers.A ^ UInt8(data & 0x80)) & (registers.A ^ UInt8(a & 0xFF)) & 0x80) == 0x80)
    
    registers.set(.A, to: UInt8(a & 0xFF))
    writeMem(at: addr, value: UInt8(data & 0xFF))
    
  }
  
  func LAX(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    let data = readMem(at: addr)
    registers.set(.A, to: data)
    registers.set(.X, to: data)
    
    setZeroFlag(data)
    setNegativeFlag(data)
    
  }
  
  func RLA(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    let data = readMem(at: addr)
    
    let result = (data << 1) &+ (registers.isSet(.carry) ? 1 : 0)
    let a = registers.A & result
    
    registers.set(.A, to: a)
    writeMem(at: addr, value: result)
    
    setFlag(.carry, condition: ((data >> 7) & 0x1) == 1)
    setFlag(.zero, condition: a == 0)
    setFlag(.negative, condition: ((a >> 7) & 0x1) == 1)
  }
  
  func RRA(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    var data = readMem(at: addr)
    
    let carry = data & 0x1
    
    data = (data >> 1) & 0x7F
    data = data | (registers.isSet(.carry) ? 0x80 : 0)
    
    
    let a = UInt16(registers.A) + UInt16(data) + UInt16(carry)
    
    setFlag(.carry, condition: a > 0xFF)
    setFlag(.zero, condition: (a & 0xFF) == 0)
    setFlag(.negative, condition: ((a >> 7) & 0x1) == 1)
    setFlag(.overflow, condition: (~(registers.A ^ data) & (registers.A ^ UInt8(a & 0xFF)) & 0x80) == 0x80)
    
    registers.set(.A, to: UInt8(a & 0xFF))
    writeMem(at: addr, value: data)
    
  }
  
  func SLO(mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    let data = readMem(at: addr)
    
    let result = (data << 1)
    let a = registers.A | result
    
    registers.set(.A, to: a)
    
    setFlag(.carry, condition: ((data >> 7) & 0x1) == 1)
    setFlag(.zero, condition: a == 0)
    setFlag(.negative, condition: ((a >> 7) & 0x1) == 1)
    
    writeMem(at: addr, value: result)
    
  }
  
  func SRE(mode: AddressingMode) {
    
    let addr = getAddressForOpperate(with: mode, at: PC)
    let data = readMem(at: addr)
    
    let result = (data >> 1)
    let a = registers.A ^ result
    
    registers.set(.A, to: a)
    
    setFlag(.carry, condition: ((data & 0x1) == 1))
    setFlag(.zero, condition: a == 0)
    setFlag(.negative, condition: ((a >> 7) & 0x1) == 1)
    
    writeMem(at: addr, value: result)
  }
}

