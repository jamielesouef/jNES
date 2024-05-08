//
//  log.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 13/4/2024.
//

import Foundation

func log<T: BinaryInteger>(_ thing: T..., radix: Int = 2) {
  #if DEBUG
    for item in thing {
      log(String(item, radix: radix))
    }
  #endif
}

func log<T: BinaryInteger>(_ message: String, _ thing: T..., radix: Int = 16, fn: String = #function) {
  #if DEBUG
    log("\(fn): \(message) : " + thing.map { String($0, radix: radix) }.joined(separator: " "))
  #endif
}

func log(_ message: String) {
  #if DEBUG
    print("Debug: \t \(message)")
  #endif
}
