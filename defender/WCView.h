//
//  WCView.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WCSpriteManager.h"
#import "WCMainLoop.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCView : NSView

@property						NSRect			sceneRect;
@property (nonatomic, retain)	WCMainLoop		*theMainLoop;
@property (nonatomic, copy)		NSMutableArray	*spriteCmdStack;

- (void)awakeFromNib;
- (IBAction)showPrefs:(id)sender;
-(NSURL*)appSupportURL;
- (void)loadScores;
- (void)saveScores;
- (void)windowWillClose:(NSNotification *)notification;
- (BOOL)acceptsFirstResponder;
- (void)keyDown:(NSEvent *)theEvent;
- (void)drawRect:(NSRect)dirtyRect;

@end
