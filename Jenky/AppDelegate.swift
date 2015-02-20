//
//  AppDelegate.swift
//  Jenky
//
//  Created by Colin Clark on 2/13/15.
//  Copyright (c) 2015 Colin Clark. All rights reserved.
//

import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate {

    var values = ["Foo", "Bar", "Baz"]

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func numberOfRowsInTableView(aTableView: NSTableView!) -> Int {
        return values.count
    }
    
    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        var cellView: JobView = tableView.makeViewWithIdentifier(tableColumn.identifier, owner: self) as JobView
        
        var amount = Float(row)/Float(3)
        
        cellView.setProgress(amount)
        
        return cellView
    }
}

