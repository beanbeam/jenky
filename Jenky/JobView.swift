//
//  JobView.swift
//  Jenky
//
//  Created by Colin Clark on 2/20/15.
//  Copyright (c) 2015 Colin Clark. All rights reserved.
//

import Cocoa

@IBDesignable
class JobView: NSTableCellView {

    private var angleDegrees:CGFloat = 315
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        let perimeter = NSBezierPath()
        
        perimeter.appendBezierPathWithArcWithCenter(
            NSPoint(x: 50, y: 50),
            radius: 20,
            startAngle: 90,
            endAngle: 90-angleDegrees,
            clockwise: true)
        perimeter.lineWidth = 10
        
        NSColor.whiteColor().set()
        perimeter.stroke()
    }
    
    func setProgress(amount: Float) {
        angleDegrees = 360 * CGFloat(amount)
    }
}
