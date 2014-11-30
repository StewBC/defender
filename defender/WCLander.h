//
//  WCLander.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCAISprite.h"

/*---------------------------------------------------------------------------*/
enum
{
	LANDER_STATE_NEEDS_INIT,
	LANDER_STATE_INITIAL_SEEK,
	LANDER_STATE_HUMAN_SEEK,
	LANDER_STATE_HUMAN_SELECTED,
	LANDER_STATE_HUMAN_CAPTURED,
};

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCLander : WCAISprite

@property (nonatomic, retain, setter=addCargo:)	WCAISprite		*theCargo;
@property						UInt32			timerCounter;
@property						UInt32			waitCounter;
@property						UInt32			animTimer;
@property						UInt32			animFrame;
@property						UInt32			shootTime;
@property						NSPoint			destination;

- (UInt32)isA;
- (void)run:(UInt32)frameCounter;

@end
