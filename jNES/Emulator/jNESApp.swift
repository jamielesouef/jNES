//
//  jNESApp.swift
//  jNES
//
//  Created by Jamie Le Souef on 25/4/2024.
//

import SwiftUI

@main
struct JNESApp: App {
  let console = try? NES()
  var body: some Scene {
    WindowGroup {
      EmptyView()
    }
  }
}
