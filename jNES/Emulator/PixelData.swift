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
  var red: UInt8
  var green: UInt8
  var blue: UInt8
  var alpha: UInt8 = 255
}

extension PixelData {
  static var black: PixelData {
    return PixelData(red: 0, green: 0, blue: 0)
  }

  func toHexString() -> String {
    let combined = UInt16(red) + UInt16(blue) + UInt16(green)
    return String(combined, radix: 16)
  }
}
