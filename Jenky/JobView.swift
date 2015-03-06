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
    
    private let RENDER_FPS_CAP: Double = 30;
    private let ANGLE_PER_FRAME: Double = 0.7;
    private let RING_RADIUS: CGFloat = 25
    private let RING_WIDTH: CGFloat = 10

    private var myJob: JenkinsJob?
    
    private var timer: NSTimer?;

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        if (myJob!.isBuilding()) {
            let progress = myJob!.estimatedProgress()
            let ringAngle = 360 * CGFloat(min(1.0, progress))
            
            let ringOffset = self.bounds.height / 2
            let ringPath = NSBezierPath()
            ringPath.appendBezierPathWithArcWithCenter(
                NSPoint(x: ringOffset, y: ringOffset),
                radius: RING_RADIUS,
                startAngle: 90,
                endAngle: 90-ringAngle,
                clockwise: true)
            ringPath.lineWidth = RING_WIDTH
            
            if progress > 5 {
                NSColor(calibratedHue: 0, saturation: 0.8, brightness: 1, alpha: 0.75).set()
            } else if progress > 2 {
                let amt = CGFloat((1 - (progress - 2)/3) * 0.17)
                NSColor(calibratedHue: amt, saturation: 0.8, brightness: 1, alpha: 0.75).set()
            } else if progress > 1 {
                let amt = CGFloat((progress - 1) * 0.8)
                NSColor(calibratedHue: 0.17, saturation: amt, brightness: 1, alpha: 0.75).set()
            } else {
                NSColor(calibratedHue: 0, saturation: 0, brightness: 1, alpha: 0.75).set()
            }
            
            ringPath.stroke()
        } else {
            let statusOffset = (dirtyRect.height - 2*RING_RADIUS)/2
            
            let statusPath = NSBezierPath(ovalInRect: NSRect(
                x: statusOffset, y: statusOffset,
                width: 2*RING_RADIUS, height: 2*RING_RADIUS))
            let status = JobStatus.SUCCESS
            switch status {//myJob!.getStatus() {
            case .SUCCESS:
                NSColor(calibratedHue: 1/3, saturation: 0.8, brightness: 0.6, alpha: 0.75).set()
            case .ABORTED:
                NSColor(calibratedHue: 0, saturation: 0, brightness: 0.6, alpha: 0.75).set()
            default:
                NSColor(calibratedHue: 5/6, saturation: 0.5, brightness: 0.6, alpha: 0.75).set()
            }
            statusPath.fill()
        }
    }
    
    func setJob(job: JenkinsJob) {
        myJob = job
        let renderDelay = max(1/RENDER_FPS_CAP, job.getTime() * ANGLE_PER_FRAME / 360)
        println(NSString(format: "Updating at %.1ffps", 1/renderDelay))
        timer = NSTimer.scheduledTimerWithTimeInterval(renderDelay, target: self, selector: "update", userInfo: nil, repeats: true)
        update()
    }
    
    func update() {
        self.needsDisplay = true
    }
}
