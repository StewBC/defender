//
//  WCBomb.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-18.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCBomb.h"
#import "WCGlobals.h"
#import "WCAIs.h"

/*---------------------------------------------------------------------------*/
#define BOMB_ANIM_FRAME_DELAY	GAME_SECONDS(0.25)

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCBomb

@synthesize frame;
@synthesize timeTillAnim;
@synthesize timeTillDie;

/*---------------------------------------------------------------------------*/
- (id)init
{
	if(self = [super init])
	{
		timeTillDie = GAME_SECONDS(2.0);
	}
	return self;
}

/*---------------------------------------------------------------------------*/
- (UInt32)isA
{
	return DB_BOMB;
}

/*---------------------------------------------------------------------------*/
- (void)run:(UInt32)frameCounter
{
	NSPoint worldPoint = self.worldPosition;
	if(!timeTillDie || ![WCGlobals WCPointInView:worldPoint])
	{
		self.dead = YES;
	}
	else
	{
		--timeTillDie;

		if(!timeTillAnim)
		{
			if(++frame >= self.currAnim.numFrames)
				frame = 0;
			
			[self setFrameInCurrAnim:frame];
			
			timeTillAnim = BOMB_ANIM_FRAME_DELAY;
		}
		else
		{
			--timeTillAnim;
		}
	}
	self.worldPosition = worldPoint;
}

@end
