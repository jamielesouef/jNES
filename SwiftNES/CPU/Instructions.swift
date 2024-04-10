//
//  Instruction.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 10/4/2024.
//

import Foundation

struct Instruction {
  let oppcode: InstructionSet
  let addressingMode: AddressingMode
  let cycles: UInt8
  let bytes: UInt8
}

enum InstructionSet {
  case ADC
  case AND
  case ASL
  case BCC
  case BCS
  case BEQ
  case BIT
  case BMI
  case BNE
  case BPL
  case BRK
  case BVC
  case BVS
  case CLC
  case CLD
  case CLI
  case CLV
  case CMP
  case CPX
  case CPY
  case DEC
  case DEY
  case EOR
  case INC
  case INX
  case INY
  case JMP
  case JSR
  case LDA
  case LDX
  case LDY
  case LSR
  case NOP
  case ORA
  case PHA
  case PHP
  case PLA
  case PLP
  case ROL
  case ROR
  case RTI
  case RTS
  case SBC
  case SEC
  case SED
  case SEI
  case STA
  case STX
  case STY
  case TAX
  case TAY
  case TSX
  case TXA
  case TXS
  case TYA
  case DEX
}

let InstructionTable: [UInt8: Instruction] = [
  0x61: Instruction(oppcode: .ADC, addressingMode: .indirectX, cycles: 6, bytes: 2),
  0x65: Instruction(oppcode: .ADC, addressingMode: .zeroPage, cycles: 3, bytes: 2),
  0x69: Instruction(oppcode: .ADC, addressingMode: .immediate, cycles: 2, bytes: 2),
  0x6D: Instruction(oppcode: .ADC, addressingMode: .absolute, cycles: 4, bytes: 3),
  0x71: Instruction(oppcode: .ADC, addressingMode: .indirectY, cycles: 5, bytes: 2),
  0x75: Instruction(oppcode: .ADC, addressingMode: .zeroPageX, cycles: 4, bytes: 2),
  0x79: Instruction(oppcode: .ADC, addressingMode: .absoluteY, cycles: 4, bytes: 3),
  0x7D: Instruction(oppcode: .ADC, addressingMode: .absoluteX, cycles: 4, bytes: 3),
  0x21: Instruction(oppcode: .AND, addressingMode: .indirectX, cycles: 6, bytes: 2),
  0x25: Instruction(oppcode: .AND, addressingMode: .zeroPage, cycles: 3, bytes: 2),
  0x29: Instruction(oppcode: .AND, addressingMode: .immediate, cycles: 2, bytes: 2),
  0x2D: Instruction(oppcode: .AND, addressingMode: .absolute, cycles: 4, bytes: 3),
  0x31: Instruction(oppcode: .AND, addressingMode: .indirectY, cycles: 5, bytes: 2),
  0x35: Instruction(oppcode: .AND, addressingMode: .zeroPageX, cycles: 4, bytes: 2),
  0x39: Instruction(oppcode: .AND, addressingMode: .absoluteY, cycles: 4, bytes: 3),
  0x3D: Instruction(oppcode: .AND, addressingMode: .absoluteX, cycles: 4, bytes: 3),
  0x06: Instruction(oppcode: .ASL, addressingMode: .zeroPage, cycles: 5, bytes: 2),
  0x0A: Instruction(oppcode: .ASL, addressingMode: .accumulator, cycles: 2, bytes: 1),
  0x0E: Instruction(oppcode: .ASL, addressingMode: .absolute, cycles: 6, bytes: 3),
  0x16: Instruction(oppcode: .ASL, addressingMode: .zeroPageX, cycles: 6, bytes: 2),
  0x1E: Instruction(oppcode: .ASL, addressingMode: .absoluteX, cycles: 7, bytes: 3),
  0x90: Instruction(oppcode: .BCC, addressingMode: .relative, cycles: 2, bytes: 2),
  0xB0: Instruction(oppcode: .BCS, addressingMode: .relative, cycles: 2, bytes: 2),
  0xF0: Instruction(oppcode: .BEQ, addressingMode: .relative, cycles: 2, bytes: 2),
  0x24: Instruction(oppcode: .BIT, addressingMode: .zeroPage, cycles: 3, bytes: 2),
  0x2C: Instruction(oppcode: .BIT, addressingMode: .absolute, cycles: 4, bytes: 3),
  0x30: Instruction(oppcode: .BMI, addressingMode: .relative, cycles: 2, bytes: 2),
  0xD0: Instruction(oppcode: .BNE, addressingMode: .relative, cycles: 2, bytes: 2),
  0x10: Instruction(oppcode: .BPL, addressingMode: .relative, cycles: 2, bytes: 2),
  0x00: Instruction(oppcode: .BRK, addressingMode: .implied, cycles: 7, bytes: 1),
  0x50: Instruction(oppcode: .BVC, addressingMode: .relative, cycles: 2, bytes: 2),
  0x70: Instruction(oppcode: .BVS, addressingMode: .relative, cycles: 2, bytes: 2),
  0x18: Instruction(oppcode: .CLC, addressingMode: .implied, cycles: 2, bytes: 1),
  0xD8: Instruction(oppcode: .CLD, addressingMode: .implied, cycles: 2, bytes: 1),
  0x58: Instruction(oppcode: .CLI, addressingMode: .implied, cycles: 2, bytes: 1),
  0xB8: Instruction(oppcode: .CLV, addressingMode: .implied, cycles: 2, bytes: 1),
  0xC1: Instruction(oppcode: .CMP, addressingMode: .indirectX, cycles: 6, bytes: 2),
  0xC5: Instruction(oppcode: .CMP, addressingMode: .zeroPage, cycles: 3, bytes: 2),
  0xC9: Instruction(oppcode: .CMP, addressingMode: .immediate, cycles: 2, bytes: 2),
  0xCD: Instruction(oppcode: .CMP, addressingMode: .absolute, cycles: 4, bytes: 3),
  0xD1: Instruction(oppcode: .CMP, addressingMode: .indirectY, cycles: 5, bytes: 2),
  0xD5: Instruction(oppcode: .CMP, addressingMode: .zeroPageX, cycles: 4, bytes: 2),
  0xD9: Instruction(oppcode: .CMP, addressingMode: .absoluteY, cycles: 4, bytes: 3),
  0xDD: Instruction(oppcode: .CMP, addressingMode: .absoluteX, cycles: 4, bytes: 3),
  0xE0: Instruction(oppcode: .CPX, addressingMode: .immediate, cycles: 2, bytes: 2),
  0xE4: Instruction(oppcode: .CPX, addressingMode: .zeroPage, cycles: 3, bytes: 2),
  0xEC: Instruction(oppcode: .CPX, addressingMode: .absolute, cycles: 4, bytes: 3),
  0xC0: Instruction(oppcode: .CPY, addressingMode: .immediate, cycles: 2, bytes: 2),
  0xC4: Instruction(oppcode: .CPY, addressingMode: .zeroPage, cycles: 3, bytes: 2),
  0xCC: Instruction(oppcode: .CPY, addressingMode: .absolute, cycles: 4, bytes: 3),
  0xC6: Instruction(oppcode: .DEC, addressingMode: .zeroPage, cycles: 5, bytes: 2),
  0xCE: Instruction(oppcode: .DEC, addressingMode: .absolute, cycles: 6, bytes: 3),
  0xD6: Instruction(oppcode: .DEC, addressingMode: .zeroPageX, cycles: 6, bytes: 2),
  0xDE: Instruction(oppcode: .DEC, addressingMode: .absoluteX, cycles: 7, bytes: 3),
  0xCA: Instruction(oppcode: .DEX, addressingMode: .implied, cycles: 2, bytes: 1),
  0x88: Instruction(oppcode: .DEY, addressingMode: .implied, cycles: 2, bytes: 1),
  0x41: Instruction(oppcode: .EOR, addressingMode: .indirectX, cycles: 6, bytes: 2),
  0x45: Instruction(oppcode: .EOR, addressingMode: .zeroPage, cycles: 3, bytes: 2),
  0x49: Instruction(oppcode: .EOR, addressingMode: .immediate, cycles: 2, bytes: 2),
  0x4D: Instruction(oppcode: .EOR, addressingMode: .absolute, cycles: 4, bytes: 3),
  0x51: Instruction(oppcode: .EOR, addressingMode: .indirectY, cycles: 5, bytes: 2),
  0x55: Instruction(oppcode: .EOR, addressingMode: .zeroPageX, cycles: 4, bytes: 2),
  0x59: Instruction(oppcode: .EOR, addressingMode: .absoluteY, cycles: 4, bytes: 3),
  0x5D: Instruction(oppcode: .EOR, addressingMode: .absoluteX, cycles: 4, bytes: 3),
  0xE6: Instruction(oppcode: .INC, addressingMode: .zeroPage, cycles: 5, bytes: 2),
  0xEE: Instruction(oppcode: .INC, addressingMode: .absolute, cycles: 6, bytes: 3),
  0xF6: Instruction(oppcode: .INC, addressingMode: .zeroPageX, cycles: 6, bytes: 2),
  0xFE: Instruction(oppcode: .INC, addressingMode: .absoluteX, cycles: 7, bytes: 3),
  0xE8: Instruction(oppcode: .INX, addressingMode: .implied, cycles: 2, bytes: 1),
  0xC8: Instruction(oppcode: .INY, addressingMode: .implied, cycles: 2, bytes: 1),
  0x4C: Instruction(oppcode: .JMP, addressingMode: .absolute, cycles: 3, bytes: 3),
  0x6C: Instruction(oppcode: .JMP, addressingMode: .indirect, cycles: 5, bytes: 3),
  0x20: Instruction(oppcode: .JSR, addressingMode: .absolute, cycles: 6, bytes: 3),
  0xA1: Instruction(oppcode: .LDA, addressingMode: .indirectX, cycles: 6, bytes: 2),
  0xA5: Instruction(oppcode: .LDA, addressingMode: .zeroPage, cycles: 3, bytes: 2),
  0xA9: Instruction(oppcode: .LDA, addressingMode: .immediate, cycles: 2, bytes: 2),
  0xAD: Instruction(oppcode: .LDA, addressingMode: .absolute, cycles: 4, bytes: 3),
  0xB1: Instruction(oppcode: .LDA, addressingMode: .indirectY, cycles: 5, bytes: 2),
  0xB5: Instruction(oppcode: .LDA, addressingMode: .zeroPageX, cycles: 4, bytes: 2),
  0xB9: Instruction(oppcode: .LDA, addressingMode: .absoluteY, cycles: 4, bytes: 3),
  0xBD: Instruction(oppcode: .LDA, addressingMode: .absoluteX, cycles: 4, bytes: 3),
  0xA2: Instruction(oppcode: .LDX, addressingMode: .immediate, cycles: 2, bytes: 2),
  0xA6: Instruction(oppcode: .LDX, addressingMode: .zeroPage, cycles: 3, bytes: 2),
  0xAE: Instruction(oppcode: .LDX, addressingMode: .absolute, cycles: 4, bytes: 3),
  0xB6: Instruction(oppcode: .LDX, addressingMode: .zeroPageY, cycles: 4, bytes: 2),
  0xBE: Instruction(oppcode: .LDX, addressingMode: .absoluteY, cycles: 4, bytes: 3),
  0xA0: Instruction(oppcode: .LDY, addressingMode: .immediate, cycles: 2, bytes: 2),
  0xA4: Instruction(oppcode: .LDY, addressingMode: .zeroPage, cycles: 3, bytes: 2),
  0xAC: Instruction(oppcode: .LDY, addressingMode: .absolute, cycles: 4, bytes: 3),
  0xB4: Instruction(oppcode: .LDY, addressingMode: .zeroPageX, cycles: 4, bytes: 2),
  0xBC: Instruction(oppcode: .LDY, addressingMode: .absoluteX, cycles: 4, bytes: 3),
  0x46: Instruction(oppcode: .LSR, addressingMode: .zeroPage, cycles: 5, bytes: 2),
  0x4A: Instruction(oppcode: .LSR, addressingMode: .accumulator, cycles: 2, bytes: 1),
  0x4E: Instruction(oppcode: .LSR, addressingMode: .absolute, cycles: 6, bytes: 3),
  0x56: Instruction(oppcode: .LSR, addressingMode: .zeroPageX, cycles: 6, bytes: 2),
  0x5E: Instruction(oppcode: .LSR, addressingMode: .absoluteX, cycles: 7, bytes: 3),
  0xEA: Instruction(oppcode: .NOP, addressingMode: .implied, cycles: 2, bytes: 1),
  0x01: Instruction(oppcode: .ORA, addressingMode: .indirectX, cycles: 6, bytes: 2),
  0x05: Instruction(oppcode: .ORA, addressingMode: .zeroPage, cycles: 3, bytes: 2),
  0x09: Instruction(oppcode: .ORA, addressingMode: .immediate, cycles: 2, bytes: 2),
  0x0D: Instruction(oppcode: .ORA, addressingMode: .absolute, cycles: 4, bytes: 3),
  0x11: Instruction(oppcode: .ORA, addressingMode: .indirectY, cycles: 5, bytes: 2),
  0x15: Instruction(oppcode: .ORA, addressingMode: .zeroPageX, cycles: 4, bytes: 2),
  0x19: Instruction(oppcode: .ORA, addressingMode: .absoluteY, cycles: 4, bytes: 3),
  0x1D: Instruction(oppcode: .ORA, addressingMode: .absoluteX, cycles: 4, bytes: 3),
  0x48: Instruction(oppcode: .PHA, addressingMode: .implied, cycles: 3, bytes: 1),
  0x08: Instruction(oppcode: .PHP, addressingMode: .implied, cycles: 3, bytes: 1),
  0x68: Instruction(oppcode: .PLA, addressingMode: .implied, cycles: 4, bytes: 1),
  0x28: Instruction(oppcode: .PLP, addressingMode: .implied, cycles: 4, bytes: 1),
  0x26: Instruction(oppcode: .ROL, addressingMode: .zeroPage, cycles: 5, bytes: 2),
  0x2A: Instruction(oppcode: .ROL, addressingMode: .accumulator, cycles: 2, bytes: 1),
  0x2E: Instruction(oppcode: .ROL, addressingMode: .absolute, cycles: 6, bytes: 3),
  0x36: Instruction(oppcode: .ROL, addressingMode: .zeroPageX, cycles: 6, bytes: 2),
  0x3E: Instruction(oppcode: .ROL, addressingMode: .absoluteX, cycles: 7, bytes: 3),
  0x66: Instruction(oppcode: .ROR, addressingMode: .zeroPage, cycles: 5, bytes: 2),
  0x6A: Instruction(oppcode: .ROR, addressingMode: .accumulator, cycles: 2, bytes: 1),
  0x6E: Instruction(oppcode: .ROR, addressingMode: .absolute, cycles: 6, bytes: 3),
  0x76: Instruction(oppcode: .ROR, addressingMode: .zeroPageX, cycles: 6, bytes: 2),
  0x7E: Instruction(oppcode: .ROR, addressingMode: .absoluteX, cycles: 7, bytes: 3),
  0x40: Instruction(oppcode: .RTI, addressingMode: .implied, cycles: 6, bytes: 1),
  0x60: Instruction(oppcode: .RTS, addressingMode: .implied, cycles: 6, bytes: 1),
  0xE1: Instruction(oppcode: .SBC, addressingMode: .indirectX, cycles: 6, bytes: 2),
  0xE5: Instruction(oppcode: .SBC, addressingMode: .zeroPage, cycles: 3, bytes: 2),
  0xE9: Instruction(oppcode: .SBC, addressingMode: .immediate, cycles: 2, bytes: 2),
  0xED: Instruction(oppcode: .SBC, addressingMode: .absolute, cycles: 4, bytes: 3),
  0xF1: Instruction(oppcode: .SBC, addressingMode: .indirectY, cycles: 5, bytes: 2),
  0xF5: Instruction(oppcode: .SBC, addressingMode: .zeroPageX, cycles: 4, bytes: 2),
  0xF9: Instruction(oppcode: .SBC, addressingMode: .absoluteY, cycles: 4, bytes: 3),
  0xFD: Instruction(oppcode: .SBC, addressingMode: .absoluteX, cycles: 4, bytes: 3),
  0x38: Instruction(oppcode: .SEC, addressingMode: .implied, cycles: 2, bytes: 1),
  0xF8: Instruction(oppcode: .SED, addressingMode: .implied, cycles: 2, bytes: 1),
  0x78: Instruction(oppcode: .SEI, addressingMode: .implied, cycles: 2, bytes: 1),
  0x81: Instruction(oppcode: .STA, addressingMode: .indirectX, cycles: 6, bytes: 2),
  0x85: Instruction(oppcode: .STA, addressingMode: .zeroPage, cycles: 3, bytes: 2),
  0x8D: Instruction(oppcode: .STA, addressingMode: .absolute, cycles: 4, bytes: 3),
  0x91: Instruction(oppcode: .STA, addressingMode: .indirectY, cycles: 6, bytes: 2),
  0x95: Instruction(oppcode: .STA, addressingMode: .zeroPageX, cycles: 4, bytes: 2),
  0x99: Instruction(oppcode: .STA, addressingMode: .absoluteY, cycles: 5, bytes: 3),
  0x9D: Instruction(oppcode: .STA, addressingMode: .absoluteX, cycles: 5, bytes: 3),
  0x86: Instruction(oppcode: .STX, addressingMode: .zeroPage, cycles: 3, bytes: 2),
  0x8E: Instruction(oppcode: .STX, addressingMode: .absolute, cycles: 4, bytes: 3),
  0x96: Instruction(oppcode: .STX, addressingMode: .zeroPageY, cycles: 4, bytes: 2),
  0x84: Instruction(oppcode: .STY, addressingMode: .zeroPage, cycles: 3, bytes: 2),
  0x8C: Instruction(oppcode: .STY, addressingMode: .absolute, cycles: 4, bytes: 3),
  0x94: Instruction(oppcode: .STY, addressingMode: .zeroPageX, cycles: 4, bytes: 2),
  0xAA: Instruction(oppcode: .TAX, addressingMode: .implied, cycles: 2, bytes: 1),
  0xA8: Instruction(oppcode: .TAY, addressingMode: .implied, cycles: 2, bytes: 1),
  0xBA: Instruction(oppcode: .TSX, addressingMode: .implied, cycles: 2, bytes: 1),
  0x8A: Instruction(oppcode: .TXA, addressingMode: .implied, cycles: 2, bytes: 1),
  0x9A: Instruction(oppcode: .TXS, addressingMode: .implied, cycles: 2, bytes: 1),
  0x98: Instruction(oppcode: .TYA, addressingMode: .implied, cycles: 2, bytes: 1),
]
