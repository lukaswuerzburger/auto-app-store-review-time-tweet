//
//  RTConfig.m
//  AppStoreReviewTime
//
//  Created by Lukas Würzburger on 6/7/16.
//  Copyright © 2016 Truffls GmbH. All rights reserved.
//

#import "RTConfig.h"

@interface RTConfig () {
    NSDictionary *config;
}

@end

@implementation RTConfig

- (instancetype)init {
    self = [super init];
    if (self) {
    
        config = [self defaultConfigFile];
    }
    return self;
}

- (NSDictionary *)defaultConfigFile {
    
    NSString *fileName = @"asrt-watcher-rc.plist";
    NSString *homeDirectory = NSHomeDirectory();
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", homeDirectory, fileName];
    return [NSDictionary dictionaryWithContentsOfFile:filePath];
}

- (NSString *)mailHost {
    return [config valueForKeyPath:@"mail.host"];
}

- (u_int)mailPort {
    return [[config valueForKeyPath:@"mail.port"] unsignedIntValue];
}

- (NSString *)mailUsername {
    return [config valueForKeyPath:@"mail.username"];
}

- (NSString *)mailPassword {
    id password = [config valueForKeyPath:@"mail.password"];
    if ([password isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:password
                                     encoding:NSUTF8StringEncoding];
    } else {
        return password;
    }
}

- (NSString *)mailFolder {
    return [config valueForKeyPath:@"mail.folder"];
}

- (NSString *)twitterUsername {
    return [config valueForKeyPath:@"twitter.username"];
}

- (NSString *)twitterPassword {
    id password = [config valueForKeyPath:@"twitter.password"];
    if ([password isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:password
                                     encoding:NSUTF8StringEncoding];
    } else {
        return password;
    }
}

- (NSString *)searchWaitingForReview {
    return [config valueForKeyPath:@"search.waitingForReview"];
}

- (NSString *)searchReadyForSale {
    return [config valueForKeyPath:@"search.readyForSale"];
}

@end
