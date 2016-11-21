//
//  RTConfig.swift
//  AppStoreReviewTime
//
//  Created by Lukas on 11/16/16.
//  Copyright © 2016 Truffls GmbH. All rights reserved.
//

import Cocoa

class RTConfig: NSObject {

    class func from(file: String) -> [String : String]? {
        let url = URL(fileURLWithPath: file)
        let obj = NSDictionary(contentsOf: url)
        if let obj = obj as? [String : String] {
            return obj
        }
        return nil
    }
}
