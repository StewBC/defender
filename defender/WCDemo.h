//
//  WCDemo.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-26.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCAISprite;
@class WCDAISprite;
@class WCPlayer;
@class WCLaser;

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCDemo : NSObject

@property (nonatomic, copy)		NSMutableArray	*render;
@property (nonatomic, copy)		NSMutableArray	*labels;
@property (nonatomic, copy)		NSMutableArray	*renderLabels;
@property (nonatomic, retain)	WCDAISprite		*player;
@property (nonatomic, retain)	WCDAISprite		*human;
@property (nonatomic, retain)	WCDAISprite		*lander;
@property (nonatomic, retain)	WCDAISprite		*object;
@property (nonatomic, retain)	WCLaser			*laser;
@property						UInt32			state;
@property						UInt32			objCode;
@property						UInt32			font;
@property						UInt32			holdTimer;

- (id)init;
- (WCDAISprite*)makeDemoSprite:(UInt32)spriteID andPos:(NSPoint)aPoint;
- (BOOL)run:(UInt32)frameCounter;

@end
