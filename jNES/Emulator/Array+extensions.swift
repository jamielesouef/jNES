//
//  Array+extensions.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 9/4/2024.
//

import Foundation

extension Array where Element == UInt8 {
  subscript(range: Range<UInt16>) -> [UInt8].SubSequence {
    let l = Int(range.lowerBound)
    let u = Int(range.upperBound)
    return self[l ..< u]
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
