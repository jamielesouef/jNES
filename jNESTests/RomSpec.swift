////
////  RomSpec.swift
////  jNESTests
////
////  Created by Jamie Le Souef on 29/4/2024.
////
//
// import XCTest
// @testable import jNES
//
// final class RomSpec: XCTestCase {
//
//  var rom: Rom!
//  var header: [UInt8]!
//  var buffer: [UInt8]!
//
//
//  override func setUpWithError() throws {
//    buffer = Array(repeating: UInt8(0), count: 256 * 8 * 8 * 2)
//    header = [
//      0x4E, 0x45, 0x53, 0x1A, // nes
//      0x01, //rom banks
//      0x01, //vrom banks
//      0b0000_1011, //Control 1
//      0b0000_0000, //Control 2
//      0x00, //size of program ram
//      0x00,
//      0x00,
//      0x00,
//      0x00,
//      0x00,
//      0x00,
//      0x00
//    ]
//  }
//
//  func testMapperVersion() throws {
//    var _h = header!
//    _h[6] = 0b1110_0000
//    _h[7] = 0b1011_0000
//
//    XCTAssertEqual(try Rom(data: _h + buffer).mapper, 0b1011_1110)
//  }
//
//  func testINESVersion() throws {
//    var _h = header!
//    _h[7] = 0b0000_1000
//
//    XCTAssertThrowsError(try Rom(data: _h + buffer)) { error in
//      XCTAssertEqual(error as! Rom.RomError, .invalidNESVersion)
//    }
//  }
//
//  func testINESVersion_alt() throws {
//    var _h = header!
//    _h[7] = 0b0000_0100
//
//    XCTAssertThrowsError(try Rom(data: _h + buffer)) { error in
//      XCTAssertEqual(error as! Rom.RomError, .invalidNESVersion)
//    }
//  }
//
//  func testNESTag() throws {
//    XCTAssertThrowsError(try Rom(data: buffer)) { error in
//      XCTAssertEqual(error as! Rom.RomError, .invalidNESFile)
//    }
//
//    XCTAssertNoThrow(try Rom(data: header + buffer))
//  }
//
//  func testFourScreenMirroring() throws {
//    rom = try Rom(data: header + buffer)
//    XCTAssertEqual(rom.mirroring, .fourScreen)
//  }
//
//  func testHorizontalMirroring() throws {
//    var _h = header!
//    _h[6] = 0b0000_0001
//    rom = try Rom(data: _h + buffer)
//    XCTAssertEqual(rom.mirroring, .horizontal)
//  }
//
//  func testVerticalMirroring() throws {
//    var _h = header!
//    _h[6] = 0b0000_0000
//    rom = try Rom(data: _h + buffer)
//    XCTAssertEqual(rom.mirroring, .vertical)
//  }
//
//  func testPrgRomBankSize() throws {
//    rom = try Rom(data: header + buffer)
//    XCTAssertEqual(rom.prgRom.count, 16384)
//  }
//
//  func testChrRomBankSize() throws {
//    rom = try Rom(data: header + buffer)
//    XCTAssertEqual(rom.chrRom.count, 8192)
//  }
// }
