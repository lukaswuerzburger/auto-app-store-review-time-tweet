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
//    private let watchService = RTWatchService.shared
    
    // MARK: - Interface
    
    func startWatchService() {
        
        // Let time interval be 1 hour = 3600 seconds
        let timeInterval: TimeInterval = 3600
        
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(handleTimerTick), userInfo: nil, repeats: true)
    }
    
    // MARK: - Timer
    
    func handleTimerTick() {
        
        checkReviewStatus()
    }
    
    // MARK: - Watch Service
    
    func checkReviewStatus() {
        
//        watchService.fetchLastResult() { (start, end) in
//            
//        }
    }
}
