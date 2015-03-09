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
    var jobs:[JenkinsJob] = [
        JenkinsJob(url: NSURL(string: "http://some.jenkins.server/job/jobname/lastBuild/api/json?pretty=false")!)]
       
    func numberOfRowsInTableView(aTableView: NSTableView!) -> Int {
        return jobs.count
    }
    
    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        var cellView: JobView = tableView.makeViewWithIdentifier(
            tableColumn.identifier,
            owner: self) as JobView
        
        println("Getting view!")

        cellView.setJob(jobs[row])
        return cellView
    }
}
