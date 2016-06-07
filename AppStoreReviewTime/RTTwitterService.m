//
//  RTTwitterService.m
//  AppStoreReviewTime
//
//  Created by Lukas Würzburger on 6/7/16.
//  Copyright © 2016 Truffls GmbH. All rights reserved.
//

#import "RTTwitterService.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface RTTwitterService () {
    NSMutableDictionary *stateDictionary;
}

@property (nonatomic, strong) ACAccountStore *accountStore;

@end

@implementation RTTwitterService

+ (instancetype)sharedService {
    
    static RTTwitterService *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[RTTwitterService alloc] init];
    });
    return service;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        stateDictionary = [self currentStateFile];
        
        self.accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [self.accountStore requestAccessToAccountsWithType:accountType
                                         options:nil
                                      completion:^(BOOL granted, NSError *error) {
            if (granted == YES) {
                NSLog(@"Yes");
            } else {
                NSLog(@"No %@", error);
            }
        }];
    }
    return self;
}

- (NSMutableDictionary *)currentStateFile {
    
    NSString *homeDirectory = NSHomeDirectory();
    NSString *fileName = @".asrt-watcher";
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", homeDirectory, fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    } else {
        return [NSMutableDictionary dictionary];
    }
}

- (NSArray *)accounts {

    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    return [self.accountStore accountsWithAccountType:accountType];
}

- (NSDate *)dateOfLastTweet {
    
    return [stateDictionary objectForKey:@"lastTweetDate"];
}

- (void)saveState {
    
    NSString *homeDirectory = NSHomeDirectory();
    NSString *fileName = @".asrt-watcher";
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", homeDirectory, fileName];
    BOOL s = [stateDictionary writeToFile:filePath atomically:NO];
    NSLog(@"%i", s);
}

- (BOOL)isAccountConnected {
    
    NSArray *accounts = [self accounts];
    NSLog(@"%@", accounts);
    if (accounts.count > 0) {
        
        return YES;
    }
    return NO;
}

- (void)post:(NSString *)tweet block:(void (^)(BOOL success))block {
    
    NSDictionary *message = @{ @"status" : tweet };
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    
    ACAccount *twitterAccount = [self accounts].lastObject;
    
    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:requestURL parameters:message];
    postRequest.account = twitterAccount;
    
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"Twitter HTTP response: %li", (long)[urlResponse statusCode]);
        
        BOOL success = (error == nil);
        if (success) {
        
            [stateDictionary setObject:[NSDate date] forKey:@"lastTweetDate"];
            [self saveState];
        }
        
        if (block) {
            block(success);
        }
    }];
}

@end
