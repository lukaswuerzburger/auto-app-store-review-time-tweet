//
//  RTWatchService.m
//  AppStoreReviewTime
//
//  Created by Lukas Würzburger on 6/7/16.
//  Copyright © 2016 Truffls GmbH. All rights reserved.
//

#import "RTWatchService.h"

#import "RTConfig.h"

#import <MailCore/MailCore.h>

@interface RTWatchService () {

    NSString *waitingForReviewSearchString;
    NSString *pendingDeveloperReleaseSearchString;
    NSString *readyForSaleSearchString;
    
    NSString *folder;
    
    NSDate *lastDateWaitingForReview;
    
    MCOIMAPSession *currentSession;
}

@end

@implementation RTWatchService

+ (instancetype)sharedService {

    static RTWatchService *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[RTWatchService alloc] init];
    });
    return service;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        RTConfig *config = [[RTConfig alloc] init];
        
        waitingForReviewSearchString = config.searchWaitingForReview;
        pendingDeveloperReleaseSearchString = config.searchPendingDeveloperRelease;
        readyForSaleSearchString = config.searchReadyForSale;
        folder = config.mailFolder;
        
        currentSession = [self sessionFromConfig:config];
    }
    return self;
}

- (NSDictionary *)defaultConfigFile {
    
    NSString *fileName = @"asrt-watcher-rc.plist";
    NSString *homeDirectory = NSHomeDirectory();
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", homeDirectory, fileName];
    return [NSDictionary dictionaryWithContentsOfFile:filePath];
}

- (MCOIMAPSession *)sessionFromConfig:(RTConfig *)config {
    
    MCOIMAPSession *session = [[MCOIMAPSession alloc] init];
    [session setHostname:config.mailHost];
    [session setPort:config.mailPort];
    [session setUsername:config.mailUsername];
    [session setPassword:config.mailPassword];
    [session setConnectionType:MCOConnectionTypeTLS];
    
    return session;
}

- (void)fetchLastResultWithBlock:(void (^)(NSDate *waitingForReviewDate, NSDate *readyForSaleDate))block {
    
    [self searchMessagesByString:waitingForReviewSearchString block:^(NSDate *date) {
        lastDateWaitingForReview = date;
        
        [self searchMessagesByString:pendingDeveloperReleaseSearchString block:^(NSDate *date) {
            if (date) {
                if (block) {
                    block(lastDateWaitingForReview, date);
                }
            } else {
                [self searchMessagesByString:readyForSaleSearchString block:^(NSDate *date) {
                    if (block) {
                        block(lastDateWaitingForReview, date);
                    }
                }];
            }
        }];
        
    }];
}

- (void)searchMessagesByString:(NSString *)string block:(void (^)(NSDate *date))block {

    MCOIMAPSearchKind requestKind = MCOIMAPSearchKindSubject;
    MCOIMAPSearchOperation *searchOperation = [currentSession searchOperationWithFolder:folder kind:requestKind searchString:string];
    [searchOperation start:^(NSError * _Nullable error, MCOIndexSet * _Nullable searchResult) {
        
        if (error) {
            if (block) {
                block(nil);
            }
        } else {
            
            MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKindHeaders);
            MCOIMAPFetchMessagesOperation *messagesOperation = [currentSession fetchMessagesOperationWithFolder:folder requestKind:requestKind uids:searchResult];
            [messagesOperation start:^(NSError * _Nullable error, NSArray * _Nullable messages, MCOIndexSet * _Nullable vanishedMessages) {
                
                NSDate *date;
                if (messages.count > 0) {
                    MCOIMAPMessage *message = messages.lastObject;
                    date = message.header.receivedDate;
                }
                if (block) {
                    block(date);
                }
            }];
        }
    }];
}

@end
