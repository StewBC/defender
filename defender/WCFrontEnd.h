//
//  WCFrontEnd.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-10.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*---------------------------------------------------------------------------*/
@class WCSprite;
@class WCWessels;
@class WCEffect;
@class WCDemo;

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCFrontEnd : NSObject

@property							UInt32		state;
@property (nonatomic, retain)		WCSprite	*logoSprite;
@property (nonatomic, retain)		WCWessels	*wessels;
@property (nonatomic, retain)		WCDemo		*theDemo;
@property (nonatomic, retain)		WCEffect	*logoEffect;
@property							UInt32		logoFrame;
@property							UInt32		nextState;
@property							UInt32		font;

- (BOOL)run:(UInt32)frameCounter;

@end
