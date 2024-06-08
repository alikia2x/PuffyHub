//
//  ResizeCGImage.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/9.
//

import Foundation
import UIKit

func resizeCGImage(_ image: CGImage?, toHeight height: CGFloat) -> CGImage? {
    guard let image = image else { return nil }
    
    let aspectRatio = CGFloat(image.width) / CGFloat(image.height)
    let width = height * aspectRatio
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: image.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
    
    context?.interpolationQuality = .high
    context?.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    return context?.makeImage()
}
