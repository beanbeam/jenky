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

    private var lastRefresh: NSDate?

    private var myJob: JenkinsJob?

    private var timer: NSTimer?;

    func setJob(job: JenkinsJob, name: String) {
        myJob = job
        nameLabel.stringValue = name
        refresh()
        let renderDelay = min(1.0, max(1/RENDER_FPS_CAP, job.getTime() * ANGLE_PER_FRAME / 360))
        println(NSString(format: "Updating at %.1ffps", 1/renderDelay))
        timer = NSTimer.scheduledTimerWithTimeInterval(renderDelay, target: self, selector: "tick", userInfo: nil, repeats: true)
    }

    func refresh() {
        println("Refreshing " + nameLabel.stringValue + "...")

        myJob!.refresh()
        lastRefresh = NSDate()
        update()
    }

    func update() {
        progressBar.setState(myJob!.estimatedProgress(),
            status: myJob!.getStatus(),
            running: myJob!.isBuilding())
    }

    func tick() {
        let timeSinceRefresh = lastRefresh!.timeIntervalSinceNow * -1

        if !myJob!.isBuilding() ||
            myJob!.estimatedProgress() > 5 {
            if timeSinceRefresh > 30 {
                refresh()
            } else {
                update()
            }
        } else {
            if timeSinceRefresh > 10 ||
            (abs(myJob!.estimatedProgress() - 1) < 0.03 && timeSinceRefresh > 2) {
                refresh()
            } else {
                update()
            }
        }
    }

    override func mouseDown(event: NSEvent) {
        refresh()
    }
}
