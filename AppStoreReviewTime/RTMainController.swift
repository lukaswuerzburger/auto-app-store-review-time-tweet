//
//  RTMainController.swift
//  AppStoreReviewTime
//
//  Created by Lukas on 11/16/16.
//  Copyright © 2016 Truffls GmbH. All rights reserved.
//

import Cocoa

class RTMainController: NSObject {

    // MARK: - Helper variables
    
    private var timer: Timer?
    
    // MARK: - Interface
    
    func startWatchService() {
        
        // Let time interval be 1 hour = 3600 seconds
        let timeInterval: TimeInterval = 3600
        
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(handleTimerTick), userInfo: nil, repeats: true)
        
        handleTimerTick()
    }
    
    // MARK: - Timer
    
    func handleTimerTick() {
        
        checkReviewStatus()
    }
    
    // MARK: - Watch Service
    
    func checkReviewStatus() {
        
        let watchService = RTWatchService()
        watchService.fetchLastResult() { (start, end) in
            let startDate = start?.header.receivedDate
            let endDate = end?.header.receivedDate
            if let end = end {
                watchService.extractAppContent(messageID: end.uid, block: { (name, version, id) in
                    
                    let duration = endDate!.timeIntervalSince1970 - startDate!.timeIntervalSince1970
                    let days = round((duration/60/60/24)*100)/100
                    
                    self.postToTwitter(message: "\(name) (\(version))\nis now available in the App Store\nhttps://itunes.apple.com/app/id\(id)\n\(days) days #iosreviewtime")
                })
            }
        }
    }
    
    func postToTwitter(message: String) {
        let twitterService = RTTwitterService()
        twitterService.post(message) { (success) in
            print("Success: \(success)")
        }
    }
}
