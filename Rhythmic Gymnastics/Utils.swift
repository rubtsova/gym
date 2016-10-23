//
//  Utils.swift
//  rhythmic gymnastics
//
//  Created by Sergey Pronin on 6/4/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit

enum DeviceType: NSInteger {
    case Unknown, iPad, iPhone4, iPhone5, iPhone6, iPhone6Plus
    
    var isIPad: Bool { return self == .iPad }
    
    func ifIPad(closure: () -> ()) {
        if self == .iPad {
            closure()
        }
    }
}

extension UIDevice {
    class func dim<T>(large: T, _ medium: T, _ small: T) -> T {
        switch type {
        case .iPhone4:
            return small
        case .iPhone5:
            return medium
        default:
            return large
        }
    }
    
    class var type: DeviceType {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            return .iPad
        } else {
            switch UIScreen.screenMaxDim {
            case 0..<568: return .iPhone4
            case 568: return .iPhone5
            case 667: return .iPhone6
            case 736: return .iPhone6Plus
            default: return .Unknown
            }
        }
    }
}

extension UIScreen {
    class var screenSize: CGSize {
        return UIScreen.mainScreen().bounds.size
    }
    
    class var screenHeight: CGFloat {
        return UIScreen.screenSize.height
    }
    
    class var screenWidth: CGFloat {
        return UIScreen.screenSize.width
    }
    
    class var screenMaxDim: CGFloat {
        return max(UIScreen.screenHeight, UIScreen.screenWidth)
    }
}

extension UIScrollView {
    func scrollToTextViewCursor(textView: UITextInput, inset: CGFloat = 0) {
        if textView.selectedTextRange == nil {
            return
        }
        
        var cursorRect = textView.caretRectForPosition(textView.selectedTextRange!.start)
        guard let view = textView as? UIView else { print("wat"); return }
        cursorRect = self.convertRect(cursorRect, fromView: view)
        cursorRect.size.height += 8 + inset
        
        if !self.rectVisible(cursorRect) {
            self.scrollRectToVisible(cursorRect, animated: true)
        }
    }
    
    func rectVisible(rect: CGRect) -> Bool {
        var visibleRect = CGRectZero
        visibleRect.origin = self.contentOffset
        visibleRect.origin.y += self.contentInset.top
        visibleRect.size = self.bounds.size
        visibleRect.size.height = self.contentInset.top + self.contentInset.bottom
        return CGRectContainsRect(visibleRect, rect)
    }
}
