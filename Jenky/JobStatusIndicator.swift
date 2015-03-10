//
//  JobStatusIndicator.swift
//  Jenky
//
//  Created by Colin Clark on 3/10/15.
//  Copyright (c) 2015 Colin Clark. All rights reserved.
//

import Cocoa

@IBDesignable
class JobStatusIndicator: NSView {

    private var status = JobStatus.UNKNOWN

    override func prepareForInterfaceBuilder() {
        status = JobStatus.SUCCESS
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        let lesserDim = min(dirtyRect.width, dirtyRect.height)
        let statusPath = NSBezierPath(ovalInRect: NSRect(
            x: (dirtyRect.width - lesserDim) / 2,
            y: (dirtyRect.height - lesserDim) / 2,
            width: lesserDim,
            height: lesserDim))

        switch status {
        case .SUCCESS:
            NSColor(calibratedHue: 1/3, saturation: 0.8, brightness: 0.7, alpha: 0.75).set()
        case .FAILURE:
            NSColor(calibratedHue: 0, saturation: 0.8, brightness: 0.7, alpha: 0.75).set()
        case .ABORTED:
            NSColor(calibratedHue: 0, saturation: 0, brightness: 0.7, alpha: 0.75).set()
        default:
            NSColor(calibratedHue: 5/6, saturation: 0.5, brightness: 0.7, alpha: 0.75).set()
        }
        statusPath.fill()
    }

    func setStatus(status: JobStatus) {
        self.status = status
        needsDisplay = true
    }
}
