//
//  RTMainViewController.m
//  AppStoreReviewTime
//
//  Created by Lukas Würzburger on 6/7/16.
//  Copyright © 2016 Truffls GmbH. All rights reserved.
//

#import "RTMainController.h"

#import "RTWatchService.h"
#import "RTTwitterService.h"

@interface RTMainController () {
    NSTimer *timer;
}

@end

@implementation RTMainController

- (void)start {
    
    timer = [NSTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(reload) userInfo:nil repeats:YES];
    [self reload];
}

- (void)reload {

    [[RTWatchService sharedService] fetchLastResultWithBlock:^(NSDate *waitingForReviewDate, NSDate *readyForSaleDate) {
        
        NSTimeInterval reviewTimeInterval = waitingForReviewDate.timeIntervalSince1970;
        NSTimeInterval readyForSaleTimeInterval = readyForSaleDate.timeIntervalSince1970;
        NSTimeInterval duration = readyForSaleTimeInterval - reviewTimeInterval;
        NSTimeInterval days = duration / 60 / 60 / 24;
        
        NSString *tweetMessage = [NSString stringWithFormat:@"%.2f days #iosreviewtime (Automatic tweet)", days];
        NSDate *dateOfLastTweet = [[RTTwitterService sharedService] dateOfLastTweet];
        if (dateOfLastTweet == nil || [dateOfLastTweet compare:readyForSaleDate] == NSOrderedAscending) {
            
            [[RTTwitterService sharedService] post:tweetMessage block:^(BOOL success) {
                if (success) {
                    [self reload];
                }
            }];
        }
    }];
}

@end
