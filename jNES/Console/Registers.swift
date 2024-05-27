import Foundation

final class Registers {
  // https://www.nesdev.org/wiki/Status_flags

//  7  bit  0
//  7654 3210
//  NV1B DIZC
//  |||| ||||
//  |||| |||+- 0 Carry
//  |||| ||+-- 1 Zero
//  |||| |+--- 2 Interrupt Disable
//  |||| +---- 3 Decimal
//  |||+------ 4 (No CPU effect; see: the B flag)
//  ||+------- 5 (No CPU effect; always pushed as 1)
//  |+-------- 6 Overflow
//  +--------- 7 Negative

//  1110 1110
//  0010_1110

  enum StatusFlag {
    case carry
    case zero
    case interrupt
    case decimal
    case brk
    case brk2
    case overflow
    case negative
  }

  enum Accumulator: String {
    case A, X, Y
  }

  private(set) var A: UInt8
  private(set) var X: UInt8
  private(set) var Y: UInt8
  private(set) var p: UInt8 // NV-BDIZC
  private(set) var PC: UInt16
  private(set) var SP: UInt8

  init(A: UInt8 = 0, X: UInt8 = 0, Y: UInt8 = 0, p: UInt8 = 0xFD, PC: UInt16 = 0, SP: UInt8 = 0xFF) {
    self.A = A
    self.X = X
    self.Y = Y
    self.p = p
    self.PC = PC
    self.SP = SP
  }

  func set(_ flag: StatusFlag) {
    p = p | flag.mask
  }

  func clear(_ flag: StatusFlag) {
    p = p & ~flag.mask
  }

  func isSet(_ flag: StatusFlag) -> Bool {
    p & flag.mask != 0
  }

  func set(programStatus p: UInt8) {
    self.p = p
  }

  func set(_ register: Accumulator, to param: UInt8) {
    switch register {
    case .A: A = param
    case .X: X = param
    case .Y: Y = param
    }
  }

  func incrementProgramCounter(by value: UInt16 = 1) {
    PC += value
  }

  func setProgramCounter(_ value: UInt16) {
    PC = value
  }

  func getProgramCounter() -> UInt16 {
    PC
  }

  func setStackPointer(_ value: UInt8) {
    SP = value
  }

  func getStackPointer() -> UInt8 {
    SP
  }

  func incrementStackPointer() {
    SP += 1
  }

  func decrementStackPointer() {
    SP -= 1
  }

  func reset() {
    A = 0
    X = 0
    p = 0b0010_0100
    SP = 0xFD
  }
}

extension Registers.StatusFlag {
  var mask: UInt8 {
    switch self {
    case .carry: 1 << 0
    case .zero: 1 << 1
    case .interrupt: 1 << 2
    case .decimal: 1 << 3
    case .brk: 1 << 4
    case .brk2: 1 << 5
    case .overflow: 1 << 6
    case .negative: 1 << 7
    }
  }
}
