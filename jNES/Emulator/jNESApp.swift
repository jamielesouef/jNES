//
//  jNESApp.swift
//  jNES
//
//  Created by Jamie Le Souef on 25/4/2024.
//

import SwiftUI

@main
struct jNESApp: App {
  let console = try? NES()
  var body: some Scene {
    WindowGroup {
//      EmulatorView()
      Button("GO!") {
        console?.reset()
        console?.cpu.setProgramCounter(0xC000)
        console?.cpu.run {_ in
          0
        }
      }
    }
  }
}
