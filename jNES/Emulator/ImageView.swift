//
//  ImageView.swift
//  jNES
//
//  Created by Jamie Le Souef on 26/4/2024.
//

import SwiftUI

struct ImageView: View {
    var pixelData: [[PixelData]]
    
    var body: some View {
        VStack {
            Image(uiImage: createUIImageFromPixelData(pixelData: pixelData)!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                
        }
    }
    func updatedPixelData() -> [[PixelData]] {
        // Your logic to update pixel data buffer
        var pixelData: [[PixelData]] = []
        for _ in 0..<32 {
            var row: [PixelData] = []
            for _ in 0..<32 {
                // Example: random pixel data
                row.append(PixelData(r: UInt8.random(in: 0...255), g: UInt8.random(in: 0...255), b: UInt8.random(in: 0...255)))
            }
            pixelData.append(row)
        }
        return pixelData
    }
    
    func createUIImageFromPixelData(pixelData: [[PixelData]]) -> UIImage? {
        let width = 32
        let height = 32
        
        // Create a context with RGBA pixels
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width * 4,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        // Fill the context with pixel data
        guard let buffer = context.data else { return nil }
        let opaquePtr = buffer.bindMemory(to: PixelData.self, capacity: width * height)
        for y in 0..<height {
            for x in 0..<width {
                opaquePtr[y * width + x] = pixelData[y][x]
            }
        }
        
        // Create CGImage from context
        guard let cgImage = context.makeImage() else { return nil }
        
        // Create UIImage from CGImage
        return UIImage(cgImage: cgImage)
    }
}

//
//// Preview
//#if DEBUG
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//#endif
