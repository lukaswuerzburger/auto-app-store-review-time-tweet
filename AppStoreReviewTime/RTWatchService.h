//
//  RTWatchService.h
//  AppStoreReviewTime
//
//  Created by Lukas Würzburger on 6/7/16.
//  Copyright © 2016 Truffls GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTWatchService : NSObject

+ (instancetype)sharedService;

- (void)fetchLastResultWithBlock:(void (^)(NSDate *waitingForReviewDate, NSDate *readyForSaleDate))block;

@end
