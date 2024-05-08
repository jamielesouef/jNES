import Foundation

//  _______________ $10000  _______________
// | PRG-ROM       |       |               |
// | Upper Bank    |       |               |
// |_ _ _ _ _ _ _ _| $C000 | PRG-ROM       |
// | PRG-ROM       |       |               |
// | Lower Bank    |       |               |
// |_______________| $8000 |_______________|
// | SRAM          |       | SRAM          |
// |_______________| $6000 |_______________|
// | Expansion ROM |       | Expansion ROM |
// |_______________| $4020 |_______________|
// | I/O Registers |       |               |
// |_ _ _ _ _ _ _ _| $4000 |               |
// | Mirrors       |       | I/O Registers |
// | $2000-$2007   |       |               |
// |_ _ _ _ _ _ _ _| $2008 |               |
// | I/O Registers |       |               |
// |_______________| $2000 |_______________|
// | Mirrors       |       |               |
// | $0000-$07FF   |       |               |
// |_ _ _ _ _ _ _ _| $0800 |               |
// | RAM           |       | RAM           |
// |_ _ _ _ _ _ _ _| $0200 |               |
// | Stack         |       |               |
// |_ _ _ _ _ _ _ _| $0100 |               |
// | Zero Page     |       |               |
// |_______________| $0000 |_______________|

final class Bus {
  private var sp: UInt8 = 0xFD
  private var cpu_vram: [UInt8]
  private var rom: Rom

  init(buffer: [UInt8] = .init(repeating: 0, count: 0xFFFF), rom: Rom) {
    cpu_vram = buffer
    self.rom = rom
  }

  func readMem(at address: UInt16) -> UInt8 {
    return switch address {
    case 0x8000 ... 0xFFFF: readProgramRom(at: address)
    default: cpu_vram[address]
    }
  }

  func writeMem(at address: UInt16, value: UInt8) {
    switch address {
    case 0x8000 ... 0xFFFF: fatalError("Cannot write to ROM")
    default: cpu_vram[address] = value
    }
  }

  func stackPush(_ value: UInt8) {
    let sp = getStackPointer()
    let stackAddress = 0x0100 | UInt16(sp)
    writeMem(at: stackAddress, value: value)
    setStackPointer(sp - 1)
  }

  func stackPop() -> UInt8 {
    let sp = getStackPointer() + 1
    setStackPointer(sp)
    let value = readMem(at: 0x100 + UInt16(sp))
    return value
  }

  func reset() {
    sp = 0xFD
  }

  func setStackPointer(_ value: UInt8) {
    sp = value
  }

  func getStackPointer() -> UInt8 {
    return sp
  }
}

private extension Bus {
  func readProgramRom(at address: UInt16) -> UInt8 {
    var addr = address - 0x8000
    if rom.prgRom.count == 0x4000 && addr >= 0x4000 {
      addr = (addr % 0x4000)
    }

    return rom.prgRom[addr]
  }
}
