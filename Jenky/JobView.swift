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

    private let RENDER_FPS_CAP: Double = 30
    private let ANGLE_PER_FRAME: Double = 0.7
    private let RING_RADIUS: CGFloat = 25
    private let RING_WIDTH: CGFloat = 10
    
    private let RING_LAYERS = [
        NSColor(calibratedHue: 0,    saturation: 0,   brightness: 1, alpha: 0.75),
        NSColor(calibratedHue: 1/6,  saturation: 0.8, brightness: 1, alpha: 0.75),
        NSColor(calibratedHue: 1/12, saturation: 0.8, brightness: 1, alpha: 0.75),
        NSColor(calibratedHue: 0,    saturation: 0.8, brightness: 1, alpha: 0.75),
        NSColor(calibratedHue: 0,    saturation: 1,   brightness: 1, alpha: 0.75)]

    private var myJob: JenkinsJob?
    
    private var timer: NSTimer?;

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func mouseDown(event: NSEvent) {
        myJob!.refresh()
        update()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        if (myJob!.isBuilding()) {
            drawProgressRing(myJob!.estimatedProgress())
            let text = NSString(format: "%.0f%%", myJob!.estimatedProgress()*100)
            var attributes: NSDictionary = [
                NSForegroundColorAttributeName: NSColor(calibratedHue: 0, saturation: 0, brightness: 1, alpha: 0.75),
                NSFontAttributeName: NSFont(name: "Arial", size: 17)!]
            text.drawInRect(self.bounds, withAttributes: attributes)
        } else {
            let statusOffset = (dirtyRect.height - 2*RING_RADIUS)/2
            
            let statusPath = NSBezierPath(ovalInRect: NSRect(
                x: statusOffset, y: statusOffset,
                width: 2*RING_RADIUS, height: 2*RING_RADIUS))
            switch myJob!.getStatus() {
            case .SUCCESS:
                NSColor(calibratedHue: 1/3, saturation: 0.8, brightness: 0.7, alpha: 0.75).set()
            case .ABORTED:
                NSColor(calibratedHue: 0, saturation: 0, brightness: 0.7, alpha: 0.75).set()
            default:
                NSColor(calibratedHue: 5/6, saturation: 0.5, brightness: 0.7, alpha: 0.75).set()
            }
            statusPath.fill()
        }
    }
    
    func drawProgressRing(progress: Double) {
        let ringOffset = self.bounds.height / 2
        let ringLayer = min(Int(progress / 1.0), RING_LAYERS.count)
        
        if ringLayer > 0 {
            let basePath = NSBezierPath()
            basePath.appendBezierPathWithArcWithCenter(
                NSPoint(x: ringOffset, y: ringOffset),
                radius: RING_RADIUS,
                startAngle: 0,
                endAngle: 360)
            
            basePath.lineWidth = RING_WIDTH
            RING_LAYERS[ringLayer-1].set()
            basePath.stroke()
        }
        
        if ringLayer < RING_LAYERS.count {
            let ringAngle = 360 * CGFloat(progress % 1.0)
            
            let ringPath = NSBezierPath()
            ringPath.appendBezierPathWithArcWithCenter(
                NSPoint(x: ringOffset, y: ringOffset),
                radius: RING_RADIUS,
                startAngle: 90,
                endAngle: 90-ringAngle,
                clockwise: true)
            
            ringPath.lineWidth = RING_WIDTH
            RING_LAYERS[ringLayer].set()
            ringPath.stroke()
        }
    }
    
    func setJob(job: JenkinsJob) {
        myJob = job
        let renderDelay = min(1.0, max(1/RENDER_FPS_CAP, job.getTime() * ANGLE_PER_FRAME / 360))
        println(NSString(format: "Updating at %.1ffps", 1/renderDelay))
        timer = NSTimer.scheduledTimerWithTimeInterval(renderDelay, target: self, selector: "update", userInfo: nil, repeats: true)
        update()
    }
    
    func update() {
        self.needsDisplay = true
    }
}
