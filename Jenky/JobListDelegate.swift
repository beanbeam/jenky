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
    var jobs: NSArray?
    var jenkinsURL: NSURL?
       
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        return getOrInitJobs().count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellView: JobView = tableView.makeViewWithIdentifier(
            tableColumn!.identifier,
            owner: self) as! JobView
        
        println("Getting view!")

        let jobDic = getOrInitJobs()[row] as! NSDictionary
        let jobId = jobDic.valueForKey("id") as! String
        let jobName = jobDic.valueForKey("name") as! String

        let jobURL = NSURL(string: "job/" + jobId + "/",
            relativeToURL: getOrInitServer())

        cellView.setJob(JenkinsJob(url: jobURL!), name: jobName)
        return cellView
    }

    private func getOrInitJobs() -> NSArray {
        if let existingJobs = jobs {
            return existingJobs
        } else {
            let userJobs = NSUserDefaults.standardUserDefaults()
                .arrayForKey("jobs")

            if userJobs != nil {
                jobs = userJobs
            } else {
                jobs = NSArray()
            }
            return jobs!
        }
    }

    private func getOrInitServer() -> NSURL {
        if let existingURL = jenkinsURL {
            return existingURL
        } else {
            let userURL = NSUserDefaults.standardUserDefaults()
                .stringForKey("jenkinsServer")

            if userURL != nil {
                jenkinsURL = NSURL(string: userURL!)
            } else {
                jenkinsURL = NSURL()
            }
            return jenkinsURL!
        }
    }
}
