import Foundation

class JenkinsJob {
    private let jobURL: NSURL

    private var timestamp: NSTimeInterval?
    private var estimatedTime: NSTimeInterval?
    private var building: Bool?
    private var status: JobStatus?
    
    init(url: NSURL) {
        jobURL = url
    }
    
    func refresh() {
        let rawData = NSData(contentsOfURL: NSURL(
            string: "lastBuild/api/json?pretty=false",
            relativeToURL: jobURL)!)

        let currentStatus =  NSJSONSerialization.JSONObjectWithData(
            rawData!,
            options: NSJSONReadingOptions.allZeros,
            error: nil) as? NSDictionary
        
        timestamp = currentStatus!["timestamp"] as NSTimeInterval / 1000
        estimatedTime = currentStatus!["estimatedDuration"] as NSTimeInterval / 1000
        building = currentStatus!["building"] as? Bool

        var rawStatus: String?;
        if building! {
            println("Loading completed build...")
            let rawData = NSData(contentsOfURL: NSURL(
                string: "lastCompletedBuild/api/json?pretty=false",
                relativeToURL: jobURL)!)

            let completedStatus =  NSJSONSerialization.JSONObjectWithData(
                rawData!,
                options: NSJSONReadingOptions.allZeros,
                error: nil) as? NSDictionary
            rawStatus = completedStatus!["result"] as? String
        } else {
            rawStatus = currentStatus!["result"] as? String
        }

        switch rawStatus {
        case .Some("ABORTED"):
            status = JobStatus.ABORTED
        case .Some("FAILURE"):
            status = JobStatus.FAILURE
        case .Some("SUCCESS"):
            status = JobStatus.SUCCESS
        case .Some("UNSTABLE"):
            status = JobStatus.UNSTABLE
        default:
            status = JobStatus.UNKNOWN
        }
    }

    func estimatedProgress() -> Double {
        let runTime = NSDate(timeIntervalSince1970: timestamp!).timeIntervalSinceNow * -1
        return runTime / estimatedTime!
    }
    
    func getTime() -> NSTimeInterval {
        return estimatedTime!
    }
    
    func getStatus() -> JobStatus {
        return status!
    }
    
    func isBuilding() -> Bool {
        return building!
    }
}

enum JobStatus {
    case ABORTED
    case FAILURE
    case SUCCESS
    case UNSTABLE
    case UNKNOWN
}