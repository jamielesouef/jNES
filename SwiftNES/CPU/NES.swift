//
//  NES.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 17/4/2024.
//

import Foundation

struct NES {
  let cpu: CPU
  let controller: Controller
  
  init() {
    let cpu = CPU()
    self.controller = Controller { buttonPressed in
      cpu.receivedButtonPress(code: buttonPressed)
    }
    self.cpu = CPU()
  }
}


