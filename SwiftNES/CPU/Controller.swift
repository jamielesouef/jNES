//
//  Controller.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 17/4/2024.
//

import Foundation

final class Controller {
  
  private let callback: (UInt8) -> Void
  
  enum Button: UInt8 {
    case up, down, left, right
    case a, b
    case start, select
  }
  
  init(_ callback: @escaping (UInt8) -> Void) {
    self.callback = callback
  }
  
  func didReceiveButtonPress(with button: Button) {
    callback(button.rawValue)
  }
}
