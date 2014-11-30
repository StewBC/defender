//
//  WCSwarmer.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-25.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCAISprite.h"

enum
{
	SWARMER_STATE_BORN,
	SWARMER_HUNTING,
};

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCSwarmer : WCAISprite

@property				UInt32		counter;
@property				UInt32		shootTime;
@property				NSPoint		offset;

- (UInt32)isA;
- (void)run:(UInt32)frameCounter;

@end
