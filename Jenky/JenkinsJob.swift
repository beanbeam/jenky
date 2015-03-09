import Foundation

class JenkinsJob {
    private var jobUrl: NSURL
    
    private var fullStatus: NSDictionary?
    private var timestamp: NSTimeInterval?
    private var estimatedTime: NSTimeInterval?
    
    init(url: NSURL) {
        jobUrl = url
        refresh()
    }
    
    func refresh() {
        println("Loading...")
        let rawData = NSData(contentsOfURL: jobUrl)
        
        fullStatus =  NSJSONSerialization.JSONObjectWithData(
            rawData!,
            options: NSJSONReadingOptions.allZeros,
            error: nil) as? NSDictionary
        
        timestamp = fullStatus!["timestamp"] as NSTimeInterval / 1000
        estimatedTime = fullStatus!["estimatedDuration"] as NSTimeInterval / 1000
    }

    func estimatedProgress() -> Double {
        let runTime = NSDate(timeIntervalSince1970: timestamp!).timeIntervalSinceNow * -1
        return runTime / estimatedTime!
    }
    
    func getTime() -> NSTimeInterval {
        return estimatedTime!
    }
    
    func getStatus() -> JobStatus {
        let status = fullStatus!["result"] as String
        switch status {
        case "ABORTED":
            return JobStatus.ABORTED
        case "FAILURE":
            return JobStatus.FAILURE
        case "SUCCESS":
            return JobStatus.SUCCESS
        case "UNSTABLE":
            return JobStatus.UNSTABLE
        default:
            return JobStatus.UNKNOWN
        }
    }
    
    func isBuilding() -> Bool {
        return fullStatus!["building"] as Bool
    }
}

enum JobStatus {
    case ABORTED
    case FAILURE
    case SUCCESS
    case UNSTABLE
    case UNKNOWN
}