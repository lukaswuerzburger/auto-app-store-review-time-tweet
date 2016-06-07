//
//  RTConfig.h
//  AppStoreReviewTime
//
//  Created by Lukas Würzburger on 6/7/16.
//  Copyright © 2016 Truffls GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTConfig : NSObject

@property (nonatomic, strong) NSString *mailHost;
@property (nonatomic) u_int mailPort;
@property (nonatomic, strong) NSString *mailUsername;
@property (nonatomic, strong) NSString *mailPassword;
@property (nonatomic, strong) NSString *mailFolder;
@property (nonatomic, strong) NSString *twitterUsername;
@property (nonatomic, strong) NSString *twitterPassword;
@property (nonatomic, strong) NSString *searchWaitingForReview;
@property (nonatomic, strong) NSString *searchReadyForSale;

@end
