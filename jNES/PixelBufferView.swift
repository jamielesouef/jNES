//
//  PixelBufferView.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 25/4/2024.
//

import SwiftUI
import UIKit

struct PixelData {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8 = 255
}

struct PixelBufferView: UIViewRepresentable {
    typealias UIViewType = UIImageView
    
    let buffer: [[PixelData]]
    let pixelSize: CGFloat
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        let image = imageFromBuffer()
        uiView.image = image
    }
    
    private func imageFromBuffer() -> UIImage {
        let width = buffer.count
        let height = buffer[0].count
        let imageSize = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContext(imageSize)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        for y in 0..<height {
            for x in 0..<width {
                let pixel = buffer[x][y]
                let color = UIColor(red: CGFloat(pixel.r) / 255.0,
                                    green: CGFloat(pixel.g) / 255.0,
                                    blue: CGFloat(pixel.b) / 255.0,
                                    alpha: CGFloat(pixel.a) / 255.0)
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }
        
        return image
    }
}
