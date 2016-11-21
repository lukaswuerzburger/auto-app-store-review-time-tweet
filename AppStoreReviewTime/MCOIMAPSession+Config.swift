//
//  MCOIMAPSession+Config.swift
//  AppStoreReviewTime
//
//  Created by Lukas on 11/17/16.
//  Copyright © 2016 Truffls GmbH. All rights reserved.
//

import Foundation

extension MCOIMAPSession {
    
    convenience init(config: [String : String]) {
        self.init()
        
        hostname    = config["mailHost"]
        port        = UInt32(config["mailPort"]!)!
        username    = config["mailUsername"]
        password    = config["mailPassword"]
    }
}
