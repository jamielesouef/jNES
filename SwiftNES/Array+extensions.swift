//
//  Array+extensions.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 9/4/2024.
//

import Foundation

extension Array where Element == UInt8 {
  subscript(index: UInt16) -> UInt8 {
    self[Int(index)]
  }
}
