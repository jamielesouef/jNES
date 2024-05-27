import Combine
import Foundation

final class NES {
  let bus: Bus
  let cpu: CPU
  let controller: Controller

  init() throws {
    let file = Bundle.main.url(forResource: "nestest", withExtension: "nes")!
    let data = try Data(contentsOf: file)

    let rom = try Rom(data: [UInt8](data))

    bus = Bus(rom: rom)
    cpu = CPU(bus: bus)
    controller = Controller()
  }

  func powerOn() {
    cpu.reset()
    cpu.registers.setProgramCounter(0xC000)
    cpu.run { _ in

    }
  }

  func powerOff() {
    cpu.stop()
  }

  func reset() {
    cpu.reset()
  }
}


extension NES: Controllable {
  func didReceiveButtonUp(button: ControllerButton) {
    controller.didReceiveButtonUp(button: button)
  }

  func didReceiveButtonDown(button: ControllerButton) {
    controller.didReceiveButtonDown(button: button)
  }

  func didReceiveButtonUp(keyCode: UInt16) {
    controller.didReceiveButtonUp(keyCode: keyCode)
  }

  func didReceiveButtonDown(keyCode: UInt16) {
    controller.didReceiveButtonDown(keyCode: keyCode)
  }
}
