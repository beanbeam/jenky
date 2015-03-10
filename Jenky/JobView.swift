//
//  JobView.swift
//  Jenky
//
//  Created by Colin Clark on 2/20/15.
//  Copyright (c) 2015 Colin Clark. All rights reserved.
//

import Cocoa

class JobView: NSTableCellView {

    private let RENDER_FPS_CAP: Double = 30
    private let ANGLE_PER_FRAME: Double = 0.7
    private let RING_RADIUS: CGFloat = 25
    private let RING_WIDTH: CGFloat = 10

    @IBOutlet var progressBar: RadialProgressBar!
    @IBOutlet var nameLabel: NSTextField!

    private var myJob: JenkinsJob?

    private var timer: NSTimer?;

    override func mouseDown(event: NSEvent) {
        myJob!.refresh()
        update()
    }

    func setJob(job: JenkinsJob, name: String) {
        myJob = job
        nameLabel.stringValue = name
        let renderDelay = min(1.0, max(1/RENDER_FPS_CAP, job.getTime() * ANGLE_PER_FRAME / 360))
        println(NSString(format: "Updating at %.1ffps", 1/renderDelay))
        timer = NSTimer.scheduledTimerWithTimeInterval(renderDelay, target: self, selector: "update", userInfo: nil, repeats: true)
        update()
    }

    func update() {
        progressBar.setState(myJob!.estimatedProgress(),
            status: myJob!.getStatus(),
            running: myJob!.isBuilding())
    }
}
