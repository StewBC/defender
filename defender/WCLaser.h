//
//  WCLaser.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*---------------------------------------------------------------------------*/
#define LASER_COMPONENTS	4

@class WCSprite;
@class WCAISprite;

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCLaser : NSObject
{
	WCSprite			*beam[LASER_COMPONENTS];
	CGFloat				width[LASER_COMPONENTS];
}

@property						UInt32		state;
@property						CGFloat		direction;
@property						UInt32		colorIndex;
@property						NSRect		worldRect;
@property						NSRect		wrapRect;
@property						BOOL		wrapsField;
@property (nonatomic, retain)	WCAISprite	*target;

- (id)initWithPosition:(NSPoint)aPoint direction:(CGFloat)aDirection andColorIndex:(UInt32)aColorIndex;
- (BOOL)run;

@end
