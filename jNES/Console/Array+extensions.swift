//
//  Array+extensions.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 9/4/2024.
//

import Foundation

extension Array where Element == UInt8 {
  subscript(range: Range<UInt16>) -> [UInt8].SubSequence {
    let lhs = Int(range.lowerBound)
    let rhs = Int(range.upperBound)
    return self[lhs ..< rhs]
  }

  subscript(index: UInt16) -> UInt8 {
    get {
      self[Int(index)]
    }

    set {
      self[Int(index)] = newValue
    }
  }
}
