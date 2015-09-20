//
//  UIImage+Tint.swift
//  HSEProject
//
//  Created by Sergey : on 4/15/15.
//  Copyright (c) 2015 Sergey Pronin. All rights reserved.
//

import UIKit

extension UIImage {
    func imageWithTint(color : String) -> UIImage {
        
//        let rect = CGRect(origin: CGPoint.zeroPoint, size: self.size)
//        
//        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
//        
//        let context = UIGraphicsGetCurrentContext()
//        
//        drawInRect(rect)
//        
//        CGContextSetBlendMode(context, kCGBlendModeScreen)
//        CGContextSetFillColorWithColor(context, color.CGColor)
//        CGContextFillRect(context, rect)
//        
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
        
        let inputImage: UIImage = UIImage(named: color + ".png")!
        let maskRef: CGImageRef = self.CGImage!;
        
        let mask: CGImageRef = CGImageMaskCreate( CGImageGetWidth(maskRef), CGImageGetHeight(maskRef), CGImageGetBitsPerComponent(maskRef),  CGImageGetBitsPerPixel(maskRef), CGImageGetBytesPerRow(maskRef), CGImageGetDataProvider(maskRef), nil, false)!
        
        let maskedImageRef: CGImageRef = CGImageCreateWithMask(inputImage.CGImage!, mask)!
        let maskedImage: UIImage = UIImage(CGImage: maskedImageRef)
        
        //CGImageRelease(mask);
        //CGImageRelease(maskedImageRef);
        
        // returns new image with mask applied
        return maskedImage;
    }
}
