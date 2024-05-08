//
//  PixelData.swift
//  jNES
//
//  Created by Jamie Le Souef on 26/4/2024.
//

import Foundation

protocol ScreenPixelBufferAdapter {
  func toPixelBuffer() -> [[PixelData]]
}

struct PixelData {
  var r: UInt8
  var g: UInt8
  var b: UInt8
  var a: UInt8 = 255
}

extension PixelData {
  static var black: PixelData {
    return PixelData(r: 0, g: 0, b: 0, a: 255)
  }

  func toHexString() -> String {
    let r = UInt16(r) + UInt16(b) + UInt16(g)
    return String(r, radix: 16)
  }
}
