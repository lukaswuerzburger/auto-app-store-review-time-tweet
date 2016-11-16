//
//  RTWatchService.swift
//  AppStoreReviewTime
//
//  Created by Lukas on 11/16/16.
//  Copyright © 2016 Truffls GmbH. All rights reserved.
//

import Cocoa

class RTWatchService {

    // MARK: - Singleton
    
    static let shared = RTWatchService()

    // MARK: - Variables
    
    let mailSubjectStartStrings = [
        "Waiting for Review"
    ]
    let mailSubjectEndStrings = [
        "Pending developer release",
        "Ready for Sale"
    ]
    let mailBoxFolder: String = "INBOX"
    
    var currentMailSession: MCOIMAPSession?
    
    // MARK: - Initializers
    
    init() {
        
        // TODO: Init config here
        
        // TODO: Init MCOIMAPSession here
    }
    
    // MARK: - Search mails
    
    func fetchLastResult(/* TODO: with block */) {
    
    }
}
