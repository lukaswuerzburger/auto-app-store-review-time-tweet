//
//  AppDelegate.m
//  AppStoreReviewTime
//
//  Created by Lukas Würzburger on 6/7/16.
//  Copyright © 2016 Truffls GmbH. All rights reserved.
//

#import "AppDelegate.h"

#import "RTMainController.h"

@interface AppDelegate () {
    
}

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    RTMainController *mainController = [[RTMainController alloc] init];
    [mainController start];
    
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
