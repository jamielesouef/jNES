//
//  CPUState.swift
//  jNESTests
//
//  Created by Jamie Le Souef on 3/5/2024.
//

import Foundation

enum CPUStateError: Error {
  case invalidCPUStateString
}

struct CPUState {
  let address: String
  let hexDump: String
  let instruction: String
  let registerA: String
  let registerX: String
  let registerY: String
  let status: String
  let stackPointer: String
  
  init(address: String,
       hexDump: String,
       instruction: String,
       registerA: String,
       registerX: String,
       registerY: String,
       status: String,
       stackPointer: String
  ) {
    self.address = address
    self.hexDump = hexDump
    self.instruction = instruction
    self.registerA = registerA
    self.registerX = registerX
    self.registerY = registerY
    self.status = status
    self.stackPointer = stackPointer
  }
  
  init(string: String) throws {
    var components: [String]!
    
    if string.contains("*") {
      let partial = string.split(separator: "*")
      let left = partial[0].split(separator: "  ").map { $0.trimmingCharacters(in: .whitespaces)}
      var right = partial[1].split(separator: "  ").map { $0.trimmingCharacters(in: .whitespaces)}
      
      right[0] = "*" + right[0]
      components = left + right
    } else {
      components = string.split(separator: "  ").map { $0.trimmingCharacters(in: .whitespaces)}
    }
  
    components = components.filter { !$0.isEmpty }
    
    guard components.count == 4 else {
      throw CPUStateError.invalidCPUStateString
    }
    
    self.address = components[0]
    self.hexDump = components[1]
    self.instruction = components[2]
    let registers = components[3]
      .trimmingCharacters(in: .whitespaces)
      .split(separator: " ")
      .map { String($0) }
    self.registerA = registers[0]
    self.registerX = registers[1]
    self.registerY = registers[2]
    self.status = registers[3]
    self.stackPointer = registers[4]
  }
}

extension CPUState: Equatable {
  static func == (lhs: CPUState, rhs: CPUState) -> Bool {
    return lhs.address == rhs.address &&
    lhs.hexDump == rhs.hexDump &&
    lhs.instruction == rhs.instruction &&
    lhs.registerA == rhs.registerA &&
    lhs.registerX == rhs.registerX &&
    lhs.registerY == rhs.registerY &&
    lhs.status == rhs.status &&
    lhs.stackPointer == rhs.stackPointer
  }
}
