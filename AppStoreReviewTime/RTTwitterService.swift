//
//  RTTwitterService.swift
//  AppStoreReviewTime
//
//  Created by Lukas on 11/16/16.
//  Copyright © 2016 Truffls GmbH. All rights reserved.
//

import Cocoa
import Accounts
import Social

class RTTwitterService {

    // MARK: - Variables
    
    var accountStore: ACAccountStore!
    
    // MARK: - Initialization
    
    init() {
        
        accountStore = ACAccountStore()
        accountStore.requestAccessToAccounts(with: twitterAccountType(), options: [:]) { (granted, error) in
            print("Granted: \(granted) Error: \(error)")
        }
    }
    
    func twitterAccountType() -> ACAccountType {
        return accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
    }
    
    func dateOfLastTweet() -> Date? {
        var date: Date?
        let filePath = "\(NSHomeDirectory())/.asrt-watcher"
        if FileManager.default.fileExists(atPath: filePath) {
            if let file = NSDictionary(contentsOfFile: filePath) as? [String : Date] {
                date = file["lastTweetDate"]
            }
        }
        return date
    }
    
    func saveDate(_ date: Date) {
        let filePath = "\(NSHomeDirectory())/.asrt-watcher"
        let dict = NSDictionary(dictionary: ["lastTweetDate" : date])
        dict.write(toFile: filePath, atomically: false)
    }
    
    func post(_ message: String, block: @escaping (_ success: Bool) -> Void) {
        let tweet = ["status" : message]
        let url = URL(string: "https://api.twitter.com/1.1/statuses/update.json")
        let account = self.accountStore.accounts(with: twitterAccountType()).last
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, url: url, parameters: tweet)
        request?.account = account as! ACAccount!
        request?.perform(handler: { (responseData, urlResponse, error) in
            
            if error == nil {
                self.saveDate(Date())
            }
            block(error == nil)
        })
    }
}
