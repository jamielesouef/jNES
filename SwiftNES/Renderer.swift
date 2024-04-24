//
//  Scene.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 25/4/2024.
//

import Foundation
import SpriteKit
import SwiftUI

struct PixelData {
  var r: UInt8
  var g: UInt8
  var b: UInt8
  var a: UInt8
}

final class Renderer {
  
  private var frame: [PixelData]
  
  init() {
    frame = Array(repeating: 0, count: 32 * 32).map { _ in
      
      let r = UInt8.random(in: 0...255)
      let g = UInt8.random(in: 0...255)
      let b = UInt8.random(in: 0...255)
      
      return PixelData(r: r, g: g, b: b, a: 255)
    }
  }
  
  func imageFrom(data: [PixelData]) -> Image {
    let width = 32
    let height = 32
    let bitsPerComponent = 8
    let bytesPerPixel = 4
    let bytesPerRow = width * bytesPerPixel
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    let context = CGContext(data: UnsafeMutableRawPointer(mutating: data), width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
    let cgImage = context?.makeImage()
    
    return Image(cgImage!, scale: 1.0, label: Text("NES Frame"))
  }

}
