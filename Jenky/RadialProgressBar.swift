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
    @IBInspectable var statusOffset: CGFloat = 5

    private let LAYERS = [
        NSColor(calibratedHue: 0,    saturation: 0,   brightness: 0.9, alpha: 1),
        NSColor(calibratedHue: 1/6,  saturation: 0.8, brightness: 0.8, alpha: 1),
        NSColor(calibratedHue: 1/12, saturation: 0.8, brightness: 0.7, alpha: 1),
        NSColor(calibratedHue: 0,    saturation: 0.8, brightness: 0.7, alpha: 1),
        NSColor(calibratedHue: 0,    saturation: 1,   brightness: 1,   alpha: 1)]

    private let SUCCESS_COLOR = NSColor(
        calibratedHue: 1/3, saturation: 0.8, brightness: 0.7, alpha: 1)
    private let FAILURE_COLOR = NSColor(
        calibratedHue: 0, saturation: 0.8, brightness: 0.7, alpha: 1)
    private let UNSTABLE_COLOR = NSColor(
        calibratedHue: 1/6, saturation: 0.8, brightness: 0.7, alpha: 1)
    private let ABORTED_COLOR = NSColor(
        calibratedHue: 0, saturation: 0, brightness: 0.7, alpha: 1)
    private let UNKNOWN_COLOR = NSColor(
        calibratedHue: 5/6, saturation: 0.5, brightness: 0.7, alpha: 1)

    private var progress: Double = 0
    private var status: JobStatus = JobStatus.UNKNOWN
    private var running: Bool = false

    override func prepareForInterfaceBuilder() {
        running = true
        progress = 0.6
        status = JobStatus.SUCCESS
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        let center = NSPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        if status == JobStatus.LOADING {
            let dotRadius = (outerRadius - 10)/3

            var leftRect = NSRect(
                x: center.x - (outerRadius-5), y: center.y - dotRadius,
                width: 2 * dotRadius, height: 2 * dotRadius)

            let offset = 5+2*dotRadius

            let loadingPath = NSBezierPath()
            loadingPath.appendBezierPathWithOvalInRect(leftRect)
            leftRect.offset(dx: offset, dy: 0)
            loadingPath.appendBezierPathWithOvalInRect(leftRect)
            leftRect.offset(dx: offset, dy: 0)
            loadingPath.appendBezierPathWithOvalInRect(leftRect)
            ABORTED_COLOR.set()
            loadingPath.fill()
            return
        }

        if running {
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

            let dividerPath = NSBezierPath()
            dividerPath.moveToPoint(center);
            dividerPath.lineToPoint(CGPoint(
                x: center.x, y: center.y + outerRadius))
            NSColor.whiteColor().set()
            dividerPath.stroke()
        }

        var radius: CGFloat
        if running {
            radius = outerRadius - (width + statusOffset)
        } else {
            radius = outerRadius
        }
        let statusPath = NSBezierPath(ovalInRect: NSRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2))

        switch status {
        case .SUCCESS:
            SUCCESS_COLOR.set()
        case .FAILURE:
            FAILURE_COLOR.set()
        case .UNSTABLE:
            UNSTABLE_COLOR.set()
        case .ABORTED:
            ABORTED_COLOR.set()
        default:
            UNKNOWN_COLOR.set()
        }
        statusPath.fill()
    }
    
    func setState(progress: Double, status: JobStatus, running: Bool) {
        self.progress = progress
        self.status = status
        self.running = running
        needsDisplay = true
    }

    override func mouseDown(event: NSEvent) {
        
    }
}
