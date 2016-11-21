//
//  RTWatchService.swift
//  AppStoreReviewTime
//
//  Created by Lukas on 11/16/16.
//  Copyright © 2016 Truffls GmbH. All rights reserved.
//

import Cocoa

class RTWatchService {

    // MARK: - Variables
    
    var currentMailSession: MCOIMAPSession?

    let mailSubjectStartString = "Waiting for Review"
    let mailSubjectEndStrings = [
        "Pending developer release",
        "Ready for Sale"
    ]
    var mailBoxFolder: String = "INBOX"
    
    var startMessage: MCOIMAPMessage?
    
    // MARK: - Initializers
    
    init() {
        let filePath = "\(NSHomeDirectory())/asrt-watcher-rc.plist"
        if let config = RTConfig.from(file: filePath) {
            
            if let customMailBoxFolder = config["mailBoxFolder"] {
                mailBoxFolder = customMailBoxFolder
            }
            
            currentMailSession = MCOIMAPSession(config: config)
            currentMailSession?.connectionType = .TLS
        }
    }
    
    // MARK: - Search mails
    
    func fetchLastResult(block: @escaping (_ start: MCOIMAPMessage?, _ end: MCOIMAPMessage?) -> Void) {
        searchMessages(by: mailSubjectStartString) { (message) in
            self.startMessage = message
            self.searchReleaseMail(index: 0, block: { (message) in
                block(self.startMessage, message)
            })
        }
    }
    
    @discardableResult
    func searchReleaseMail(index: Int, block: @escaping (_ message: MCOIMAPMessage?) -> Void) -> Bool {
        if index < mailSubjectEndStrings.count {
            let string = mailSubjectEndStrings[index]
            self.searchMessages(by: string) { (message) in
                if let message = message {
                    if self.startMessage?.header.receivedDate.compare(message.header.receivedDate) == .orderedAscending {
                        block(message)
                    }
                }
                if self.searchReleaseMail(index: index + 1, block: block) == false {
                    block(nil)
                }
            }
            return true
        }
        return false
    }
    
    func searchMessages(by string: String, block: @escaping (_ message: MCOIMAPMessage?) -> Void) {
        let requestKind: MCOIMAPSearchKind = .kindSubject
        let searchOperation = currentMailSession?.searchOperation(withFolder: mailBoxFolder, kind: requestKind, search: string)
        searchOperation?.start() { (error, searchResult) in
            if let result = searchResult {
                self.searchHeaders(with: result, block: { (message) in
                    block(message)
                })
            } else {
                block(nil)
            }
        }
    }
    
    func searchHeaders(with indexSet: MCOIndexSet, block: @escaping (_ message: MCOIMAPMessage?) -> Void) {
        let requestKind: MCOIMAPMessagesRequestKind = .headers
        let messagesOperation = currentMailSession?.fetchMessagesOperation(withFolder: mailBoxFolder, requestKind: requestKind, uids: indexSet)
        messagesOperation?.start() { (error, messages, vanishedMessages) in
            var m: MCOIMAPMessage?
            if let messages = messages as? [MCOIMAPMessage] {
                if let message = messages.last {
                    m = message
                }
            }
            block(m)
        }
    }
    
    func extractAppContent(messageID: UInt32, block: @escaping (_ appName: String, _ appVersion: String, _ appID: String) -> Void) {
        currentMailSession?.fetchMessageAttachmentOperation(withFolder: mailBoxFolder, uid: messageID, partID: "message part", encoding: .encodingOther).start() { (error, data) in
            if let data = data {
                if let str = String(data: data, encoding: .utf8) {

                    let name = self.extractAppMetaDataPart(from: str, prefix: "App Name")
                    let version = self.extractAppMetaDataPart(from: str, prefix: "App Version Number")
                    let id = self.extractAppMetaDataPart(from: str, prefix: "App Apple ID")
                    
                    block(name, version, id)
                }
            }
        }
    }
    
    func extractAppMetaDataPart(from string: String, prefix: String) -> String {
        let completePrefix = "\(prefix):"
        let line = matchingLine(of: string, pattern: "\(completePrefix).+") as NSString
        return line.substring(from: completePrefix.characters.count).trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func matchingLine(of str: String, pattern: String) -> String {
        var line: String!
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .init(rawValue: 0))
            let result = regex.matches(in: str, options: .init(rawValue: 0), range: NSRange(location: 0, length: str.characters.count))
            let mappedResults = result.map({ (str as NSString).substring(with: $0.range)})
            line = mappedResults.first
        } catch {
            print("error regexing")
        }
        return line
    }
}


