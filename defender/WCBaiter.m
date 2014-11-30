//
//  WCBaiter.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-11.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCBaiter.h"
#import "WCGlobals.h"
#import "WCSoundManager.h"
#import "WCBullet.h"
#import "WCPlayer.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCBaiter

@synthesize frame;
@synthesize shootTime;

/*---------------------------------------------------------------------------*/
- (id)init
{
	if(self = [super init])
	{
		shootTime = MUTANT_SHOOT_WINDOW;
	}
	return self;
}

/*---------------------------------------------------------------------------*/
- (UInt32)isA
{
	return DB_BAITER;
}


/*---------------------------------------------------------------------------*/
- (void)run:(UInt32)frameCounter
{
	NSPoint worldPoint = self.worldPosition;
	NSPoint speed = self.speed;
	NSPoint player = WCGlobals.globalsManager.thePlayer.worldPosition;
	NSSize viewSize = WCGlobals.globalsManager.viewSize;
	CGFloat playerDir = WCGlobals.globalsManager.thePlayer.scale.x;
	CGFloat left, right, dx, t = 0.048;
	
	if(!(frameCounter % 3))
	{
		if(++frame >= self.currAnim.numFrames)
			frame = 0;

		[self setFrameInCurrAnim:frame];
	}

	if(worldPoint.x > player.x)
	{
		left = worldPoint.x - player.x;
		right = (WCGlobals.globalsManager.fieldSize.width + player.x) - worldPoint.x;
	}
	else
	{
		left = (WCGlobals.globalsManager.fieldSize.width + worldPoint.x) - player.x;
		right = player.x - worldPoint.x;
	}
	
	if(left <= right)
		dx = worldPoint.x - left - viewSize.width/2.0;
	else
		dx = worldPoint.x + right + viewSize.width/2.0;

	if(speed.x * playerDir < 0.0)
		t = 0.026;

	speed.x = MIN(800.0, speed.x);
	[WCGlobals evalCubicCurrPos:&worldPoint.x currSpeed:&speed.x destPos:dx timeStep:t];
	[WCGlobals evalCubicCurrPos:&worldPoint.y currSpeed:&speed.y destPos:player.y timeStep:t];

	self.speed = speed;
	self.worldPosition = worldPoint;
	
	if([WCGlobals WCPointInView:worldPoint])
	{
		if(!shootTime--)
		{
			[WCSoundManager playSound:DB_STRINGS[DB_LANDERSHOOT]];
			[WCBullet makeBulletAt:self.worldPosition aimingAt:WCGlobals.globalsManager.thePlayer.worldPosition withVelocity:WCGlobals.globalsManager.velocity];
			shootTime = MUTANT_SHOOT_WINDOW;
		}
	}
}

@end
