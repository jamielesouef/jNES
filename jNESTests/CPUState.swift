//
//  CPUState.swift
//  jNESTests
//
//  Created by Jamie Le Souef on 3/5/2024.
//

import Foundation

struct CPUState {
  let address: String
  let hexDump: [String]
  let instruction: String
  let registerA: String
  let registerX: String
  let registerY: String
  let status: String
  let stackPointer: String
  
  init(string: String) throws {
    let components = string.split(separator: " ").map { String($0) }
    guard components.count >= 13 else {
      throw NSError(domain: "CPUState", code: 0, userInfo: ["message": "Invalid CPUState string"])
    }
    
    self.address = components[0]
    self.hexDump = Array(components[2...4])
    self.instruction = components[5..<12].joined(separator: " ")
    let registers = components[13].split(separator: ",").map { String($0) }
    self.registerA = registers[0]
    self.registerX = registers[1]
    self.registerY = registers[2]
    self.status = components[15]
    self.stackPointer = components[17]
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
