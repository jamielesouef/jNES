//
//  Registers.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 9/4/2024.
//

import Foundation

class Registers {
  
  // https://www.nesdev.org/wiki/Status_flags
  
//  7  bit  0
//  ---- ----
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
  
  enum StatusFlag {
    case carry
    case zero
    case interrupt
    case decimal
    case brk //break
    case overflow
    case negative
  }
  
  enum IndexRegister {
    case accumulator,X,Y
  }
  
  private (set) var A: UInt8
  private (set) var X: UInt8
  private (set) var Y: UInt8
  private (set) var sp: UInt8
  private (set) var p: UInt8 //NV-BDIZC
  
  init(A: UInt8 = 0, X: UInt8 = 0, Y: UInt8 = 0, sp: UInt8 = 0, p: UInt8 = 0x20) {
    self.A = A
    self.X = X
    self.Y = Y
    self.sp = sp
    self.p = p
  }
  
  func set(_ flag: StatusFlag) {
    p = p | flag.mask
  }
  
  
  func unset(_ flag: StatusFlag) {
    p = p & ~flag.mask
  }
  
  func isSet(_ flag: StatusFlag) -> Bool {
    p & flag.mask != 0
  }
  
  func set(_ register: IndexRegister, to param: UInt8) {
    switch register {
    case .accumulator: self.A = param
    case .X: self.X = param
    case .Y: self.Y = param
    }
  }
  
  func reset() {
    A = 0
    X = 0
    p = 0
  }
}

extension Registers.StatusFlag {
  var mask: UInt8 {
    switch self {
    case .carry: 1 << 0
    case .zero: 1 << 1
    case .interrupt: 1 << 2
    case .decimalMode: 1 << 3
    case .brk: 1 << 4
    case .overflow: 1 << 6
    case .negative: 1 << 7
    }
  }
}
