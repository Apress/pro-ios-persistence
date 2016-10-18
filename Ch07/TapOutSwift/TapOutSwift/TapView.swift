//
//  TapView.swift
//  TapOutSwift
//
//  Created by Michael Privat on 10/8/14.
//  Copyright (c) 2014 Pro iOS Persistence. All rights reserved.
//

import Foundation
import UIKit

class TapView : UIView {
    override func drawRect(rect: CGRect) {
        let DIAMETER = CGFloat(10.0)
        
        let context = UIGraphicsGetCurrentContext()
        
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        let taps = appDelegate?.persistence?.taps()
        if let taps = taps {
            for tap : Tap in taps {
                let rgb = CGColorGetComponents(tap.color.CGColor)
                CGContextSetRGBFillColor(context, rgb[0], rgb[1], rgb[2], 1.0)
                CGContextFillEllipseInRect(context, CGRectMake(CGFloat(tap.x - Float(DIAMETER/2)), CGFloat(tap.y - Float(DIAMETER/2)), DIAMETER, DIAMETER))
            }
        }
    }
}
