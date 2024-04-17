//
//  Controller.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 17/4/2024.
//

import Foundation

final class Controller {
  
  private let callback: (UInt16) -> Void
  
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
  
  init(_ callback: @escaping (UInt16) -> Void) {
    self.callback = callback
  }
  
  func didReceiveButtonPress(with button: Button) {
    callback(button.rawValue)
  }
}
