//
//  RadialProgressBar.swift
//  Jenky
//
//  Created by Colin Clark on 3/10/15.
//  Copyright (c) 2015 Colin Clark. All rights reserved.
//

import Cocoa

@IBDesignable
class RadialProgressBar: NSView {

    @IBInspectable var outerRadius: CGFloat = 25
    @IBInspectable var width: CGFloat = 10

    private let LAYERS = [
        NSColor(calibratedHue: 0,    saturation: 0,   brightness: 0.9, alpha: 1),
        NSColor(calibratedHue: 1/6,  saturation: 0.8, brightness: 0.8, alpha: 1),
        NSColor(calibratedHue: 1/12, saturation: 0.8, brightness: 0.8, alpha: 1),
        NSColor(calibratedHue: 0,    saturation: 0.8, brightness: 0.8, alpha: 1),
        NSColor(calibratedHue: 0,    saturation: 1,   brightness: 1,   alpha: 1)]
    
    private var progress: Double = 0

    override func prepareForInterfaceBuilder() {
        progress = 0.85
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        let center = NSPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        let radius = outerRadius - width/2
        let layer = min(Int(progress), LAYERS.count)

        if layer > 0 {
            let basePath = NSBezierPath()
            basePath.appendBezierPathWithArcWithCenter(center,
                radius: radius, startAngle: 0, endAngle: 360)
            
            basePath.lineWidth = width
            LAYERS[layer-1].set()
            basePath.stroke()
        }
        
        if layer < LAYERS.count {
            let angle = 360 * CGFloat(progress % 1.0)
            
            let barPath = NSBezierPath()
            barPath.appendBezierPathWithArcWithCenter(center,
                radius: radius, startAngle: 90, endAngle: 90-angle, clockwise: true)
            
            barPath.lineWidth = width
            LAYERS[layer].set()
            barPath.stroke()
        }
    }
    
    func setProgress(progress: Double) {
        self.progress = progress
        needsDisplay = true
    }
}
