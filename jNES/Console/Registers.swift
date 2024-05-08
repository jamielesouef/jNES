import Foundation

class Registers {
  
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
    case b
    case b2
    case overflow
    case negative
  }
  
  enum Accumulator: String {
    case A,X,Y
  }
  
  private (set) var A: UInt8
  private (set) var X: UInt8
  private (set) var Y: UInt8
  private (set) var p: UInt8 //NV-BDIZC
  
  init(A: UInt8 = 0, X: UInt8 = 0, Y: UInt8 = 0, p: UInt8 = 0xfd) {
    self.A = A
    self.X = X
    self.Y = Y
    self.p = p
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
    case .A: self.A = param
    case .X: self.X = param
    case .Y: self.Y = param
    }
  }
  
  func reset() {
    A = 0
    X = 0
    p = 0b0010_0100
  }
}

extension Registers.StatusFlag {
  var mask: UInt8 {
    switch self {
    case .carry: 1 << 0
    case .zero: 1 << 1
    case .interrupt: 1 << 2
    case .decimal: 1 << 3
    case .b: 1 << 4
    case .b2: 1 << 5
    case .overflow: 1 << 6
    case .negative: 1 << 7
    }
  }
}
