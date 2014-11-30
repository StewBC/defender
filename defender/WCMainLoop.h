//
//  WCMainLoop.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WCGlobals.h"

/*---------------------------------------------------------------------------*/
@class WCView;
@class WCFrontEnd;
@class WCPrefs;

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCMainLoop : NSObject
{
	char initials[3];
}

@property (nonatomic, weak)		WCView				*theView;
@property						NSSize				viewSize;

@property						UInt32				frameCounter;
@property						UInt32				gameState;
@property						WCFrontEnd			*theFrontEnd;
@property						WCPrefs				*thePrefs;
@property						UInt32				goTimer;
@property						UInt32				showHumans;
@property						UInt32				cursorPos;
@property						int					fontPos;
@property						UInt32				keyHeld;
@property						UInt32				repeatRate;
@property						UInt32				blinkTimer;
@property						BOOL				blinkOff;
@property						BOOL				prePrefsHudState;

- (id)init:(WCView *)aView;
- (BOOL)runPlay;
- (BOOL)showStats;
- (BOOL)getInitials;
- (void)initialsToScores:(WCHighScore*)scoreTable;
- (void)runPrefs;
- (void)handleHyper;
- (void)gameTick;
- (void)mainLoop:(NSTimer *)timer;

@end
