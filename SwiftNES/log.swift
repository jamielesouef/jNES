//
//  l.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 13/4/2024.
//

import Foundation


func log<T: BinaryInteger>(_ thing: T..., r: Int = 2){
  #if DEBUG
  thing.forEach {
    log(String($0, radix: r))
  }
  #endif
}

func log<T: BinaryInteger>(_ message: String, _ thing: T..., r: Int = 16, fn: String = #function){
  #if DEBUG
  log("\(fn): \(message) : " + thing.map { String($0, radix: r) }.joined(separator: " ") )
  #endif
}

func log(_ message: String){
  #if DEBUG
  print("Debug: \t \(message)")
  #endif
}
