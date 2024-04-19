//
//  Instruction.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 10/4/2024.
//

import Foundation

struct Instruction {
  let name: String
  let mode: AddressingMode
  let cycles: UInt8
  let bytes: UInt8
  let fn: () -> Void
}

//enum InstructionSet {
//  case ADC
//  case AND
//  case ASL
//  case BCC
//  case BCS
//  case BEQ
//  case BIT
//  case BMI
//  case BNE
//  case BPL
//  case BRK
//  case BVC
//  case BVS
//  case CLC
//  case CLD
//  case CLI
//  case CLV
//  case CMP
//  case CPX
//  case CPY
//  case DEC
//  case DEY
//  case EOR
//  case INC
//  case INX
//  case INY
//  case JMP
//  case JSR
//  case LDA
//  case LDX
//  case LDY
//  case LSR
//  case NOP
//  case ORA
//  case PHA
//  case PHP
//  case PLA
//  case PLP
//  case ROL
//  case ROR
//  case RTI
//  case RTS
//  case SBC
//  case SEC
//  case SED
//  case SEI
//  case STA
//  case STX
//  case STY
//  case TAX
//  case TAY
//  case TSX
//  case TXA
//  case TXS
//  case TYA
//  case DEX
//}

extension CPU {
  func getInstructions(forOpcode opcode: UInt8) ->Instruction {
    
    let table: [UInt8: Instruction] = [
      0x61: Instruction(name: "ADC", mode: .indirectX, cycles: 6, bytes: 2, fn: self.ADC),
      0x65: Instruction(name: "ADC", mode: .zeroPage, cycles: 3, bytes: 2, fn: self.ADC),
      0x69: Instruction(name: "ADC", mode: .immediate, cycles: 2, bytes: 2, fn: self.ADC),
      0x6D: Instruction(name: "ADC", mode: .absolute, cycles: 4, bytes: 3, fn: self.ADC),
      0x71: Instruction(name: "ADC", mode: .indirectY, cycles: 5, bytes: 2, fn: self.ADC),
      0x75: Instruction(name: "ADC", mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.ADC),
      0x79: Instruction(name: "ADC", mode: .absoluteY, cycles: 4, bytes: 3, fn: self.ADC),
      0x7D: Instruction(name: "ADC", mode: .absoluteX, cycles: 4, bytes: 3, fn: self.ADC),
      
      0x21: Instruction(name: "AND", mode: .indirectX, cycles: 6, bytes: 2, fn: self.AND),
      0x25: Instruction(name: "AND", mode: .zeroPage, cycles: 3, bytes: 2, fn: self.AND),
      0x29: Instruction(name: "AND", mode: .immediate, cycles: 2, bytes: 2, fn: self.AND),
      0x2D: Instruction(name: "AND", mode: .absolute, cycles: 4, bytes: 3, fn: self.AND),
      0x31: Instruction(name: "AND", mode: .indirectY, cycles: 5, bytes: 2, fn: self.AND),
      0x35: Instruction(name: "AND", mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.AND),
      0x39: Instruction(name: "AND", mode: .absoluteY, cycles: 4, bytes: 3, fn: self.AND),
      0x3D: Instruction(name: "AND", mode: .absoluteX, cycles: 4, bytes: 3, fn: self.AND),
      
      0x06: Instruction(name: "ASL", mode: .zeroPage, cycles: 5, bytes: 2, fn: self.ASL),
      0x0A: Instruction(name: "ASL_accumulator", mode: .accumulator, cycles: 2, bytes: 1, fn: self.ASL_accumulator),
      0x0E: Instruction(name: "ASL", mode: .absolute, cycles: 6, bytes: 3, fn: self.ASL),
      0x16: Instruction(name: "ASL", mode: .zeroPageX, cycles: 6, bytes: 2, fn: self.ASL),
      0x1E: Instruction(name: "ASL", mode: .absoluteX, cycles: 7, bytes: 3, fn: self.ASL),
      
      0x90: Instruction(name: "BCC", mode: .relative, cycles: 2, bytes: 2, fn: self.BCC),
      
      0xB0: Instruction(name: "BCS", mode: .relative, cycles: 2, bytes: 2, fn: self.BCS),
      
      0xF0: Instruction(name: "BEQ", mode: .relative, cycles: 2, bytes: 2, fn: self.BEQ),
      
      0x24: Instruction(name: "BIT", mode: .zeroPage, cycles: 3, bytes: 2, fn: self.BIT),
      0x2C: Instruction(name: "BIT", mode: .absolute, cycles: 4, bytes: 3, fn: self.BIT),
      
      0x30: Instruction(name: "BMI", mode: .relative, cycles: 2, bytes: 2, fn: self.BMI),
      
      0xD0: Instruction(name: "BNE", mode: .relative, cycles: 2, bytes: 2, fn: self.BNE),
      
      0x10: Instruction(name: "BPL", mode: .relative, cycles: 2, bytes: 2, fn: self.BPL),
      
      0x00: Instruction(name: "BRK", mode: .implied, cycles: 7, bytes: 1, fn: self.BRK),
      
      0x50: Instruction(name: "BVC", mode: .relative, cycles: 2, bytes: 2, fn: self.BVC),
      
      0x70: Instruction(name: "BVS", mode: .relative, cycles: 2, bytes: 2, fn: self.BVS),
      
      0x18: Instruction(name: "CLC", mode: .implied, cycles: 2, bytes: 1, fn: self.CLC),
      
      0xD8: Instruction(name: "CLD", mode: .implied, cycles: 2, bytes: 1, fn: self.CLD),
      
      0x58: Instruction(name: "CLI", mode: .implied, cycles: 2, bytes: 1, fn: self.CLI),
      
      0xB8: Instruction(name: "CLV", mode: .implied, cycles: 2, bytes: 1, fn: self.CLV),
      
      0xC1: Instruction(name: "CMP", mode: .indirectX, cycles: 6, bytes: 2, fn: self.CMP),
      0xC5: Instruction(name: "CMP", mode: .zeroPage, cycles: 3, bytes: 2, fn: self.CMP),
      0xC9: Instruction(name: "CMP", mode: .immediate, cycles: 2, bytes: 2, fn: self.CMP),
      0xCD: Instruction(name: "CMP", mode: .absolute, cycles: 4, bytes: 3, fn: self.CMP),
      0xD1: Instruction(name: "CMP", mode: .indirectY, cycles: 5, bytes: 2, fn: self.CMP),
      0xD5: Instruction(name: "CMP", mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.CMP),
      0xD9: Instruction(name: "CMP", mode: .absoluteY, cycles: 4, bytes: 3, fn: self.CMP),
      0xDD: Instruction(name: "CMP", mode: .absoluteX, cycles: 4, bytes: 3, fn: self.CMP),
      
      0xE0: Instruction(name: "CPX", mode: .immediate, cycles: 2, bytes: 2, fn: self.CPX),
      0xE4: Instruction(name: "CPX", mode: .zeroPage, cycles: 3, bytes: 2, fn: self.CPX),
      0xEC: Instruction(name: "CPX", mode: .absolute, cycles: 4, bytes: 3, fn: self.CPX),
      0xC0: Instruction(name: "CPY", mode: .immediate, cycles: 2, bytes: 2, fn: self.CPY),
      0xC4: Instruction(name: "CPY", mode: .zeroPage, cycles: 3, bytes: 2, fn: self.CPY),
      0xCC: Instruction(name: "CPY", mode: .absolute, cycles: 4, bytes: 3, fn: self.CPY),
      
      0xC6: Instruction(name: "DEC", mode: .zeroPage, cycles: 5, bytes: 2, fn: self.DEC),
      0xCE: Instruction(name: "DEC", mode: .absolute, cycles: 6, bytes: 3, fn: self.DEC),
      0xD6: Instruction(name: "DEC", mode: .zeroPageX, cycles: 6, bytes: 2, fn: self.DEC),
      0xDE: Instruction(name: "DEC", mode: .absoluteX, cycles: 7, bytes: 3, fn: self.DEC),
      
      0xCA: Instruction(name: "DEX", mode: .implied, cycles: 2, bytes: 1, fn: self.DEX),
      0x88: Instruction(name: "DEY", mode: .implied, cycles: 2, bytes: 1, fn: self.DEY),
      
      0x41: Instruction(name: "EOR", mode: .indirectX, cycles: 6, bytes: 2, fn: self.EOR),
      0x45: Instruction(name: "EOR", mode: .zeroPage, cycles: 3, bytes: 2, fn: self.EOR),
      0x49: Instruction(name: "EOR", mode: .immediate, cycles: 2, bytes: 2, fn: self.EOR),
      0x4D: Instruction(name: "EOR", mode: .absolute, cycles: 4, bytes: 3, fn: self.EOR),
      0x51: Instruction(name: "EOR", mode: .indirectY, cycles: 5, bytes: 2, fn: self.EOR),
      0x55: Instruction(name: "EOR", mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.EOR),
      0x59: Instruction(name: "EOR", mode: .absoluteY, cycles: 4, bytes: 3, fn: self.EOR),
      0x5D: Instruction(name: "EOR", mode: .absoluteX, cycles: 4, bytes: 3, fn: self.EOR),
      
      0xE6: Instruction(name: "INC", mode: .zeroPage, cycles: 5, bytes: 2, fn: self.INC),
      0xEE: Instruction(name: "INC", mode: .absolute, cycles: 6, bytes: 3, fn: self.INC),
      0xF6: Instruction(name: "INC", mode: .zeroPageX, cycles: 6, bytes: 2, fn: self.INC),
      0xFE: Instruction(name: "INC", mode: .absoluteX, cycles: 7, bytes: 3, fn: self.INC),
      
      0xE8: Instruction(name: "INX", mode: .implied, cycles: 2, bytes: 1, fn: self.INX),
      0xC8: Instruction(name: "INY", mode: .implied, cycles: 2, bytes: 1, fn: self.INY),
      
      0x4C: Instruction(name: "JMP", mode: .absolute, cycles: 3, bytes: 3, fn: self.JMP),
      0x6C: Instruction(name: "JMP", mode: .indirect, cycles: 5, bytes: 3, fn: self.JMP),
      
      0x20: Instruction(name: "JSR", mode: .absolute, cycles: 6, bytes: 3, fn: self.JSR),
      
      0xA1: Instruction(name: "LDA", mode: .indirectX, cycles: 6, bytes: 2, fn: self.LDA),
      0xA5: Instruction(name: "LDA", mode: .zeroPage, cycles: 3, bytes: 2, fn: self.LDA),
      0xA9: Instruction(name: "LDA", mode: .immediate, cycles: 2, bytes: 2, fn: self.LDA),
      0xAD: Instruction(name: "LDA", mode: .absolute, cycles: 4, bytes: 3, fn: self.LDA),
      0xB1: Instruction(name: "LDA", mode: .indirectY, cycles: 5, bytes: 2, fn: self.LDA),
      0xB5: Instruction(name: "LDA", mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.LDA),
      0xB9: Instruction(name: "LDA", mode: .absoluteY, cycles: 4, bytes: 3, fn: self.LDA),
      0xBD: Instruction(name: "LDA", mode: .absoluteX, cycles: 4, bytes: 3, fn: self.LDA),
      
      0xA2: Instruction(name: "LDX", mode: .immediate, cycles: 2, bytes: 2, fn: self.LDX),
      0xA6: Instruction(name: "LDX", mode: .zeroPage, cycles: 3, bytes: 2, fn: self.LDX),
      0xAE: Instruction(name: "LDX", mode: .absolute, cycles: 4, bytes: 3, fn: self.LDX),
      0xB6: Instruction(name: "LDX", mode: .zeroPageY, cycles: 4, bytes: 2, fn: self.LDX),
      0xBE: Instruction(name: "LDX", mode: .absoluteY, cycles: 4, bytes: 3, fn: self.LDX),
      
      0xA0: Instruction(name: "LDY", mode: .immediate, cycles: 2, bytes: 2, fn: self.LDY),
      0xA4: Instruction(name: "LDY", mode: .zeroPage, cycles: 3, bytes: 2, fn: self.LDY),
      0xAC: Instruction(name: "LDY", mode: .absolute, cycles: 4, bytes: 3, fn: self.LDY),
      0xB4: Instruction(name: "LDY", mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.LDY),
      0xBC: Instruction(name: "LDY", mode: .absoluteX, cycles: 4, bytes: 3, fn: self.LDY),
      
      0x46: Instruction(name: "LSR", mode: .zeroPage, cycles: 5, bytes: 2, fn: self.LSR),
      0x4A: Instruction(name: "LSR_accumulator", mode: .accumulator, cycles: 2, bytes: 1, fn: self.LSR_accumulator),
      0x4E: Instruction(name: "LSR", mode: .absolute, cycles: 6, bytes: 3, fn: self.LSR),
      0x56: Instruction(name: "LSR", mode: .zeroPageX, cycles: 6, bytes: 2, fn: self.LSR),
      0x5E: Instruction(name: "LSR", mode: .absoluteX, cycles: 7, bytes: 3, fn: self.LSR),
      
      0xEA: Instruction(name: "NOP", mode: .implied, cycles: 2, bytes: 1, fn: self.NOP),
      
      0x01: Instruction(name: "ORA", mode: .indirectX, cycles: 6, bytes: 2, fn: self.ORA),
      0x05: Instruction(name: "ORA", mode: .zeroPage, cycles: 3, bytes: 2, fn: self.ORA),
      0x09: Instruction(name: "ORA", mode: .immediate, cycles: 2, bytes: 2, fn: self.ORA),
      0x0D: Instruction(name: "ORA", mode: .absolute, cycles: 4, bytes: 3, fn: self.ORA),
      0x11: Instruction(name: "ORA", mode: .indirectY, cycles: 5, bytes: 2, fn: self.ORA),
      0x15: Instruction(name: "ORA", mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.ORA),
      0x19: Instruction(name: "ORA", mode: .absoluteY, cycles: 4, bytes: 3, fn: self.ORA),
      0x1D: Instruction(name: "ORA", mode: .absoluteX, cycles: 4, bytes: 3, fn: self.ORA),
      
      0x48: Instruction(name: "PHA", mode: .implied, cycles: 3, bytes: 1, fn: self.PHA),
      0x08: Instruction(name: "PHP", mode: .implied, cycles: 3, bytes: 1, fn: self.PHP),
      
      0x68: Instruction(name: "PLA", mode: .implied, cycles: 4, bytes: 1, fn: self.PLA),
      
      0x28: Instruction(name: "PLP", mode: .implied, cycles: 4, bytes: 1, fn: self.PLP),
      
      0x26: Instruction(name: "ROL", mode: .zeroPage, cycles: 5, bytes: 2, fn: self.ROL),
      
      0x2A: Instruction(name: "ROL_accumulator", mode: .accumulator, cycles: 2, bytes: 1, fn: self.ROL_accumulator),
      0x2E: Instruction(name: "ROL", mode: .absolute, cycles: 6, bytes: 3, fn: self.ROL),
      0x36: Instruction(name: "ROL", mode: .zeroPageX, cycles: 6, bytes: 2, fn: self.ROL),
      0x3E: Instruction(name: "ROL", mode: .absoluteX, cycles: 7, bytes: 3, fn: self.ROL),
      
      0x66: Instruction(name: "ROR", mode: .zeroPage, cycles: 5, bytes: 2, fn: self.ROR),
      0x6A: Instruction(name: "ROR_accumulator", mode: .accumulator, cycles: 2, bytes: 1, fn: self.ROR_accumulator),
      0x6E: Instruction(name: "ROR", mode: .absolute, cycles: 6, bytes: 3, fn: self.ROR),
      0x76: Instruction(name: "ROR", mode: .zeroPageX, cycles: 6, bytes: 2, fn: self.ROR),
      0x7E: Instruction(name: "ROR", mode: .absoluteX, cycles: 7, bytes: 3, fn: self.ROR),
      
      0x40: Instruction(name: "RTI", mode: .implied, cycles: 6, bytes: 1, fn: self.RTI),
      
      0x60: Instruction(name: "RTS", mode: .implied, cycles: 6, bytes: 1, fn: self.RTS),
      
      0xE1: Instruction(name: "SBC", mode: .indirectX, cycles: 6, bytes: 2, fn: self.SBC),
      0xE5: Instruction(name: "SBC", mode: .zeroPage, cycles: 3, bytes: 2, fn: self.SBC),
      0xE9: Instruction(name: "SBC", mode: .immediate, cycles: 2, bytes: 2, fn: self.SBC),
      0xED: Instruction(name: "SBC", mode: .absolute, cycles: 4, bytes: 3, fn: self.SBC),
      0xF1: Instruction(name: "SBC", mode: .indirectY, cycles: 5, bytes: 2, fn: self.SBC),
      0xF5: Instruction(name: "SBC", mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.SBC),
      0xF9: Instruction(name: "SBC", mode: .absoluteY, cycles: 4, bytes: 3, fn: self.SBC),
      0xFD: Instruction(name: "SBC", mode: .absoluteX, cycles: 4, bytes: 3, fn: self.SBC),
      0x38: Instruction(name: "SEC", mode: .implied, cycles: 2, bytes: 1, fn: self.SEC),
      
      0xF8: Instruction(name: "SED", mode: .implied, cycles: 2, bytes: 1, fn: self.SED),
      
      0x78: Instruction(name: "SEI", mode: .implied, cycles: 2, bytes: 1, fn: self.SEI),
      
      0x81: Instruction(name: "STA", mode: .indirectX, cycles: 6, bytes: 2, fn: self.STA),
      0x85: Instruction(name: "STA", mode: .zeroPage, cycles: 3, bytes: 2, fn: self.STA),
      0x8D: Instruction(name: "STA", mode: .absolute, cycles: 4, bytes: 3, fn: self.STA),
      0x91: Instruction(name: "STA", mode: .indirectY, cycles: 6, bytes: 2, fn: self.STA),
      0x95: Instruction(name: "STA", mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.STA),
      0x99: Instruction(name: "STA", mode: .absoluteY, cycles: 5, bytes: 3, fn: self.STA),
      0x9D: Instruction(name: "STA", mode: .absoluteX, cycles: 5, bytes: 3, fn: self.STA),
      
      0x86: Instruction(name: "STX", mode: .zeroPage, cycles: 3, bytes: 2, fn: self.STX),
      0x8E: Instruction(name: "STX", mode: .absolute, cycles: 4, bytes: 3, fn: self.STX),
      0x96: Instruction(name: "STX", mode: .zeroPageY, cycles: 4, bytes: 2, fn: self.STX),
      0x84: Instruction(name: "STY", mode: .zeroPage, cycles: 3, bytes: 2, fn: self.STY),
      0x8C: Instruction(name: "STY", mode: .absolute, cycles: 4, bytes: 3, fn: self.STY),
      0x94: Instruction(name: "STY", mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.STY),
      0xAA: Instruction(name: "TAX", mode: .implied, cycles: 2, bytes: 1, fn: self.TAX),
      0xA8: Instruction(name: "TAY", mode: .implied, cycles: 2, bytes: 1, fn: self.TAY),
      0xBA: Instruction(name: "TSX", mode: .implied, cycles: 2, bytes: 1, fn: self.TSX),
      0x8A: Instruction(name: "TXA", mode: .implied, cycles: 2, bytes: 1, fn: self.TXA),
      0x9A: Instruction(name: "TXS", mode: .implied, cycles: 2, bytes: 1, fn: self.TXS),
      0x98: Instruction(name: "TY", mode: .implied, cycles: 2, bytes: 1, fn: self.TYA)
    ]
    
    guard let instruction = table[opcode] else {
      fatalError("Unknown opcode: \(opcode)")
    }
    
    return instruction
  }
}
