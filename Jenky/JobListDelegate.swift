//
//  JobListDelegate.swift
//  Jenky
//
//  Created by Colin Clark on 2/20/15.
//  Copyright (c) 2015 Colin Clark. All rights reserved.
//

import Cocoa
import Foundation

class JobListDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    let jenkinsURL = NSURL(string: "http://some.jenkins.server")

    let jobs:[(String, String)] = [
        ("Job Name A", "jobPathA"),
        ("Job Name B", "jobPathB")]
       
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        return jobs.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellView: JobView = tableView.makeViewWithIdentifier(
            tableColumn!.identifier,
            owner: self) as! JobView
        
        println("Getting view!")

        let jobURL = NSURL(
            string: "job/" + jobs[row].1 + "/",
            relativeToURL: jenkinsURL)

        cellView.setJob(JenkinsJob(url: jobURL!), name: jobs[row].0)
        return cellView
    }
}
