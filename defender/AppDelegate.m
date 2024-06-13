//
//  AppDelegate.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "AppDelegate.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation AppDelegate

/*---------------------------------------------------------------------------*/
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
    if (@available(macOS 10.15, *)) {
        // below requests "Input Monitoring"
        IOHIDRequestAccess(kIOHIDRequestTypeListenEvent);
    }
    
	[[self window] setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
//	[[self window] toggleFullScreen:self];
}

/*---------------------------------------------------------------------------*/
- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

@end
