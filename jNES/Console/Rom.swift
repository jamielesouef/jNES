//
//  rom.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 19/4/2024.
//

import Foundation


/*
 
    Byte 0x00 - 0x03
    String "NES^Z" used to recognize .NES files.
 
    Byte 0x04
    Number of 16 KB PRG ROM banks.
 
    Byte 0x05
    Number of 8 KB CHR ROM banks.
    
    Byte 0x06
 
    7 6 5 4 3 2 1 0
    | | | | | | | |
    | | | | | | | +- Mirroring: 0: horizontal (vertical arrangement) 1: vertical (horizontal arrangement)
    | | | | | | + -- 1: Cartridge contains battery-backed PRG RAM ($6000-7FFF) or other persistent memory
    | | | | | +----- 1: 512-byte trainer at $7000-$71FF (stored before PRG data)
    | | | | +------- 1: Ignore mirroring control or above mirroring bit; instead provide four-screen mirroring
    | | | |
    | | | |
    + + + +--------- Lower nybble of mapper number
 
 
    Byte 0x07
 
    7 6 5 4 3 2 1 0
    | | | | | | | |
    | | | | | | | +- 0 for iNES 1.0 format
    | | | | | | + -- 0 for iNES 1.0 format
    | | | | | |
    | | | | + +----- If (3,2) == 1,0, NES 2.0 format, if (3,2) == 0,0, NES 1.0 format
    | | | |
    | | | |
    + + + +--------- Upper nybble of mapper number
   
    Byte 0x08
    Size of PRG RAM in 8 KB units (Value 0 infers 8 KB for compatibility; see PRG RAM circuit)
 
    Byte 0x09
    NA?
 
    Byte 0x0A - 0x0F
    Reserved, must be zeroes.
 
 */

fileprivate let NES_TAG: [UInt8] = [0x4E, 0x45, 0x53, 0x1A]
fileprivate let PRG_ROM_BANK_SIZE: UInt16 = 16384
fileprivate let CHR_ROM_BANK_SIZE: UInt16 = 8192

struct Rom {
 
  enum Mirroring {
     case vertical
     case horizontal
     case fourScreen
  }
  
  let prgRom: [UInt8]
  let chrRom: [UInt8]
  let mirroring: Mirroring
  let mapper: UInt8
  
  enum RomError: Error {
    case invalidNESFile
    case invalidNESVersion
    case invalidMapper
  }
  
  init(data: [UInt8]) throws {
    let version = (data[0x07] >> 2 & 0b11)
    let trainerOffset: UInt16 = (data[0x06] & 0b100 == 0) ? 0 : 512
    
    if Array(data[0..<4]) != NES_TAG {
      throw RomError.invalidNESFile
    }
    
    if version != 0 {
      throw RomError.invalidNESVersion
    }
    
    mapper = (data[0x07] & 0b1111_0000) | (data[0x06] >> 4)
    
    if data[0x06] & 0b1000 != 0 {
      mirroring = .fourScreen
    } else {
      mirroring = data[0x06] & 0b1 == 0 ? .vertical : .horizontal
    }
    
    let prgRomSize = UInt16(data[0x04]) * PRG_ROM_BANK_SIZE
    let chrRomSize =  UInt16(data[0x05]) * CHR_ROM_BANK_SIZE
    
    let prgStart: UInt16 = 0x10 + trainerOffset
    let prgEnd: UInt16 = prgStart + prgRomSize
    
    let chrStart: UInt16 = prgStart + prgRomSize
    let chrEnd: UInt16 = chrStart + chrRomSize
    
    self.prgRom = Array(data[prgStart..<prgEnd])
    self.chrRom = Array(data[chrStart..<chrEnd])
    
  }
}
