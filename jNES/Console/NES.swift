//
//  NES.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 17/4/2024.
//

import Foundation
import Combine

/*
 fn color(byte: u8) -> Color {
 match byte {
 0 => sdl2::pixels::Color::BLACK,
 1 => sdl2::pixels::Color::WHITE,
 2 | 9 => sdl2::pixels::Color::GREY,
 3 | 10 => sdl2::pixels::Color::RED,
 4 | 11 => sdl2::pixels::Color::GREEN,
 5 | 12 => sdl2::pixels::Color::BLUE,
 6 | 13 => sdl2::pixels::Color::MAGENTA,
 7 | 14 => sdl2::pixels::Color::YELLOW,
 _ => sdl2::pixels::Color::CYAN,
 }
 }
 */

struct NesScreenPixelBufferAdapter: ScreenPixelBufferAdapter {
  private let screen: [NES.Color]
  init(_ screen: [NES.Color]) {
    self.screen = screen
  }
  
  func toPixelBuffer() -> [[PixelData]] {
    var data: [[PixelData]] = []
    var index: Int = 0
    
    for _ in 0..<32 {
      var row: [PixelData] = []
      for _ in 0..<32 {
        row.append(screen[index].pixelData)
        index += 1
      }
      data.append(row)
    }
    
    return data
  }
}


final class NES {
  let bus: Bus
  let cpu: CPU
  let controller: Controller
  
  enum Color: UInt8 {
    case black
    case white
    case grey
    case red
    case green
    case blue
    case magenta
    case yellow
    case cyan
  }
  
  init() throws {
    
    let file = Bundle.main.url(forResource: "nestest", withExtension: "nes")!
    let data = try Data(contentsOf: file)
    
    let rom = try Rom(data: [UInt8](data))
    
    self.bus = Bus(rom: rom)
    self.cpu = CPU(bus: bus)
    self.controller = Controller()
  }
  
  private (set) var screen: [Color] = .init(repeating: .black, count: 32 * 3 * 32)
  
  var updateScreen: ((ScreenPixelBufferAdapter) -> Void)?
  
  func powerOn() {
    cpu.reset()
    cpu.setProgramCounter(0xC000)
    cpu.run { _ in
      self.udpateScreenIfRequired()
    }
  }
  
  func powerOff() {
    cpu.stop()
  }
  
  func reset() {
    cpu.reset()
  }
}

private extension NES {
  
  func color(from byte:  UInt8) -> Color {
    switch byte {
    case 0 : .black
    case 1 : .white
    case 2 | 9: .grey
    case 3 | 10: .red
    case 4 | 11: .green
    case 5 | 12: .blue
    case 6 | 13: .magenta
    case 7 | 14: .yellow
    default : .cyan
    }
  }
  
  func udpateScreenIfRequired() {
    var screenBuffer: [Color] = .init(repeating: .black, count: 32 * 32)
    for i in 0x0200...0x05FF {
      let byte = cpu.readMem(at: UInt16(i))
      let color = color(from: byte)
      screenBuffer[i - 0x0200] = color
    }
    
    if screenBuffer != screen {
      screen = screenBuffer
      updateScreen?(NesScreenPixelBufferAdapter(screen))
    }
  }
}

extension NES: Controllable {
  func didReceiveButtonUp(button: ControllerButton) {
    controller.didReceiveButtonUp(button: button)
  }
  
  func didReceiveButtonDown(button: ControllerButton) {
    controller.didReceiveButtonDown(button: button)
  }
  
  func didReceiveButtonUp(keyCode: UInt16) {
    controller.didReceiveButtonUp(keyCode: keyCode)
  }
  
  func didReceiveButtonDown(keyCode: UInt16) {
    controller.didReceiveButtonDown(keyCode: keyCode)
  }
}


extension NES.Color {
  var pixelData: PixelData {
    switch self {
    case .black: return PixelData(r: 0, g: 0, b: 0, a: 255)
    case .white: return PixelData(r: 255, g: 255, b: 255, a: 255)
    case .grey: return PixelData(r: 128, g: 128, b: 128, a: 255)
    case .red: return PixelData(r: 255, g: 0, b: 0, a: 255)
    case .green: return PixelData(r: 0, g: 255, b: 0, a: 255)
    case .blue: return PixelData(r: 0, g: 0, b: 255, a: 255)
    case .magenta: return PixelData(r: 255, g: 0, b: 255, a: 255)
    case .yellow: return PixelData(r: 255, g: 255, b: 0, a: 255)
    case .cyan: return PixelData(r: 0, g: 255, b: 255, a: 255)
    }
  }
}

