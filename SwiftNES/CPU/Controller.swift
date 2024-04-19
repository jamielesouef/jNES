//
//  Controller.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 17/4/2024.
//

import Foundation


protocol Controllable {
  func didReceiveButtonUp(keyCode: UInt16)
  func didReceiveButtonDown(keyCode: UInt16)
}

final class Controller: Controllable {
  
  enum Button: UInt16 {
    case up = 0x0D
    case down = 0x01
    case left = 0x00
    case right = 0x02
    case a = 0x28
    case b = 0x25
    case start = 0x05
    case select = 0x04
  }
  
  private (set) var state: UInt8 = 0x00
  
  func didReceiveButtonUp(keyCode: UInt16) {
    guard let validButton = getButton(for: keyCode) else { return }
    setState(with: validButton, isPressed: false)
  }
  
  func didReceiveButtonDown(keyCode: UInt16) {
    guard let validButton = getButton(for: keyCode), 
            !isPressed(validButton) else {
      return
    }
    
    setState(with: validButton, isPressed: true)
  }
  
  private func getButton(for keyCode: UInt16) -> Button? {
    Button(rawValue: keyCode)
  }
  
  private func isPressed(_ button: Button) -> Bool {
    state & button.mask != 0
  }
  
  private func setState(with button: Button, isPressed: Bool) {
   if isPressed {
     state |= button.mask
   } else {
     state &= ~button.mask
   }
  }
}

extension Controller.Button {
  var mask: UInt8 {
    switch self {
    case .up: 1
    case .down: 1 << 1
    case .left: 1 << 2
    case .right: 1 << 3
    case .a: 1 << 4
    case .b: 1 << 5
    case .start: 1 << 6
    case .select: 1 << 7
    }
  }
}
