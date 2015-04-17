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
    @IBOutlet var leftStatus: NSTextField!
    @IBOutlet var rightStatus: NSTextField!

    private var lastRefresh: NSDate?

    private var myJob: JenkinsJob?

    private var timer: NSTimer?;

    func setJob(job: JenkinsJob, name: String) {
        myJob = job
        nameLabel.stringValue = name
        refresh()
        var renderDelay: NSTimeInterval
        if let time = job.getEstimatedTime() {
            renderDelay = min(1.0, max(1/RENDER_FPS_CAP, time * ANGLE_PER_FRAME / 360))
        } else {
            renderDelay = 1/RENDER_FPS_CAP
        }
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
        if myJob!.getStatus() == JobStatus.LOADING {
            progressBar.setState(0, status: JobStatus.LOADING, running: false)
            leftStatus.stringValue = "Loading..."
            rightStatus.stringValue = ""
        } else {
            if myJob!.isBuilding()! {
                let remainingTime = myJob!.getEstimatedTime()! - myJob!.getRunTime()

                leftStatus.stringValue = formatConciseTimeInterval(myJob!.getRunTime())
                rightStatus.stringValue = formatConciseTimeInterval(-remainingTime,
                    alwaysShowSign: true)
            } else {
                leftStatus.stringValue = formatVerboseTimeSince(
                    myJob!.getRunTime() - myJob!.getFinalDuration()!)
                rightStatus.stringValue = ""
            }

            progressBar.setState(myJob!.estimatedProgress(),
                status: myJob!.getStatus(),
                running: myJob!.isBuilding()!)
        }
    }

    func tick() {
        let timeSinceRefresh = lastRefresh!.timeIntervalSinceNow * -1

        if myJob!.getStatus() == JobStatus.LOADING {
            if timeSinceRefresh > 10 {
                refresh()
            } else {
                update()
            }
        } else if !myJob!.isBuilding()! ||
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

    @IBAction
    func openConsole(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(
            string: "lastBuild/console",
            relativeToURL: myJob!.getUrl())!)
    }

    func formatConciseTimeInterval(interval: NSTimeInterval, alwaysShowSign: Bool = false) -> String {
        let absInterval = abs(interval)

        let sign: String
        if absInterval < 1 {
            return "0s"
        } else if interval < 0 {
            sign = "-"
        } else if alwaysShowSign {
            sign = "+"
        } else {
            sign = ""
        }

        if absInterval < 60 {
            return String(format: "%@%ds", sign, Int(absInterval))
        } else if absInterval < (60*10) {
            return String(format: "%@%.1lfm", sign, truncate(absInterval/60, places: 1))
        } else if absInterval < (60*60) {
            return String(format: "%@%dm", sign, Int(absInterval/60))
        } else if absInterval < (60*60*10) {
            return String(format: "%@%.1lfh", sign, truncate(absInterval/(60*60), places: 1))
        } else if absInterval < (60*60*24) {
            return String(format: "%@%dh", sign, Int(absInterval/(60*60)))
        }else if absInterval < (60*60*24*10) {
            return String(format: "%@%.1lfd", sign, truncate(absInterval/(60*60*24), places: 1))
        } else {
            return String(format: "%@%dd", sign, Int(absInterval/(60*60*24)))
        }
    }

    func formatVerboseTimeSince(interval: NSTimeInterval) -> String {
        if interval < 0 {
            return ""
        } else if interval < 1 {
            return "just now"
        } else if interval < 2 {
            return "a second ago"
        } else if interval < 60 {
            return String(format: "%d seconds ago", Int(interval))
        } else if interval < (60*2) {
            return "a minute ago"
        } else if interval < (60*60) {
            return String(format: "%d minutes ago", Int(interval/60))
        } else if interval < (60*60*2) {
            return "an hour ago"
        } else if interval < (60*60*24) {
            return String(format: "%d hours ago", Int(interval/(60*60)))
        } else if interval < (60*60*24*2) {
            return "yesterday"
        } else {
            return String(format: "%d days ago", Int(interval/(60*60*24)))
        }
    }

    func truncate(number: Double, places: Int = 0) -> Double {
        let multiplier = pow(10, Double(places))

        return trunc(number*multiplier)/multiplier
    }
}
