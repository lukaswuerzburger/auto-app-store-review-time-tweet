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
    private let watchService = RTWatchService.shared
    
    // MARK: - Interface
    
    func startWatchService() {
        
        // Let time interval be 1 hour = 3600 seconds
        let timeInterval: TimeInterval = 35
        
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(handleTimerTick), userInfo: nil, repeats: true)
        
        handleTimerTick()
    }
    
    // MARK: - Timer
    
    func handleTimerTick() {
        
        checkReviewStatus()
    }
    
    // MARK: - Watch Service
    
    func checkReviewStatus() {
        
        watchService.fetchLastResult() { (start, end) in
            let startDate = start?.header.receivedDate
            let endDate = end?.header.receivedDate
            if let end = end {
                self.watchService.extractAppContent(messageID: end.uid, block: { (name, version, id) in
                    
                    let duration = endDate!.timeIntervalSince1970 - startDate!.timeIntervalSince1970
                    let days = round((duration/60/60/24)*100)/100
                    
                    print("TWITTER POST: \n\n\(name) (\(version))\nis now available in the App Store\nhttps://itunes.apple.com/app/id\(id)\n\(days) days #iosreviewtime")
                })
            }
        }
    }
}
