//
//  Controller.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 17/4/2024.
//

import Foundation

final class Controller {
  
    
  enum Button: UInt16 {
    case up = 13
    case down = 1
    case left = 0
    case righ = 2
    case a = 40
    case b = 37
    case start = 5
    case select = 4
  }
  
  private (set) var state: UInt8 = 0x00 {
    didSet {
      log("state",state, r: 2)
    }
  }
  
  func didReceiveButtonUp(button: Button) {
    setState(with: button, isPressed: false)
  }
  
  func didReceiveButtonDown(button: Button) {
    if isPressed(button) { return }
    setState(with: button, isPressed: true)
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
    case .up: 1 << 0
    case .down: 1 << 1
    case .left: 1 << 2
    case .righ: 1 << 3
    case .a: 1 << 4
    case .b: 1 << 5
    case .start: 1 << 6
    case .select: 1 << 7
    }
  }
}
