//
//  WCMutant.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCMutant.h"
#import "WCGlobals.h"
#import "WCSoundManager.h"
#import "WCAIs.h"
#import "WCBullet.h"
#import "WCPlayer.h"

/*---------------------------------------------------------------------------*/
#define MUTANT_SPEED_X			5.0
#define MUTANT_SPEED_Y			5.0

#define ANIM_TICK_TIMER	1

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCMutant

@synthesize frame;
@synthesize animTick;
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
	return DB_MUTANT;
}


/*---------------------------------------------------------------------------*/
- (void)run:(UInt32)frameCounter
{
	if(!animTick--)
	{
		if(++frame >= self.currAnim.numFrames*2)
			frame = 0;

		[self setFrameInCurrAnim:frame & 1 ? frame / 2 : 0];
			animTick = ANIM_TICK_TIMER;
	}
	
	CGFloat playerWidth = WCGlobals.globalsManager.thePlayer.srcRect.size.width;
	NSPoint playerPoint = WCGlobals.globalsManager.thePlayer.worldPosition;
	NSPoint worldPoint = self.worldPosition;
	CGFloat selfHeight = srcRect.size.height;
	CGFloat fieldHeight = WCGlobals.globalsManager.fieldSize.height;
	UInt32 left, right;
	
	left = playerPoint.x - 2.0*playerWidth;
	right = playerPoint.x + 2.0*playerWidth;
	
	if(worldPoint.x >= left && worldPoint.x <= right)
	{
		if(playerPoint.y > worldPoint.y)
			worldPoint.y += MIN(playerPoint.y - worldPoint.y, MUTANT_SPEED_Y);
		else
			worldPoint.y -= MIN(worldPoint.y - playerPoint.y, MUTANT_SPEED_Y);
	}
	else
	{
		if(worldPoint.y < playerPoint.y)
			worldPoint.y++;
		else
			worldPoint.y--;
		int upDown = (arc4random_uniform(3)-1.0) * MUTANT_SPEED_Y;
		worldPoint.y += upDown;
		if(worldPoint.y > fieldHeight - selfHeight)
			worldPoint.y = selfHeight;
		else if(worldPoint.y < selfHeight)
			worldPoint.y = fieldHeight - selfHeight;
	}

	if(worldPoint.x > left)
	{
		left = worldPoint.x - playerPoint.x;
		right = (WCGlobals.globalsManager.fieldSize.width + playerPoint.x) - worldPoint.x;
	}
	else
	{
		left = (WCGlobals.globalsManager.fieldSize.width + worldPoint.x) - playerPoint.x;
		right = playerPoint.x - worldPoint.x;
	}
	
	if(left <= right)
		worldPoint.x -= MIN(left, MUTANT_SPEED_X);
	else
		worldPoint.x += MIN(right, MUTANT_SPEED_X);
	
	self.worldPosition = worldPoint;
	
	if([WCGlobals WCPointInView:worldPoint])
	{
		if(!shootTime--)
		{
			[WCSoundManager playSound:DB_STRINGS[DB_MUTANTSHOOT]];
			[WCBullet makeBulletAt:self.worldPosition aimingAt:WCGlobals.globalsManager.thePlayer.worldPosition withVelocity:WCGlobals.globalsManager.velocity];
			shootTime = MUTANT_SHOOT_WINDOW;
		}
	}
	
}

@end
