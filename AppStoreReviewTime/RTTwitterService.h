//
//  RTTwitterService.h
//  AppStoreReviewTime
//
//  Created by Lukas Würzburger on 6/7/16.
//  Copyright © 2016 Truffls GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTTwitterService : NSObject

+ (instancetype)sharedService;

- (NSDate *)dateOfLastTweet;

- (BOOL)isAccountConnected;

- (void)post:(NSString *)tweet block:(void (^)(BOOL success))block;

@end
