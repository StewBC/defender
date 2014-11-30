//
//  WCSwarmer.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-25.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCSwarmer.h"
#import "WCGlobals.h"
#import "WCSoundManager.h"
#import "WCBullet.h"
#import "WCPlayer.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCSwarmer

@synthesize counter;
@synthesize shootTime;
@synthesize offset;

/*---------------------------------------------------------------------------*/
- (UInt32)isA
{
	return DB_SWARMER;
}

/*---------------------------------------------------------------------------*/
- (void)run:(UInt32)frameCounter
{
	NSPoint worldPoint = self.worldPosition;
	NSSize viewSize = WCGlobals.globalsManager.viewSize;
	CGFloat fh = WCGlobals.globalsManager.fieldSize.height;
	CGFloat selfHeight = srcRect.size.height;
	
	if(SWARMER_STATE_BORN == self.state)
	{
		NSPoint speed = self.speed;
		
		worldPoint.x += speed.x;
		worldPoint.y += speed.y;

		speed.x *= 0.98;
		speed.y *= 0.98;
		self.speed = speed;

		if(++counter >= SWARMER_SEEK_TIME)
		{
			counter = 0;
			offset = NSMakePoint(arc4random_uniform(viewSize.width/2.0), arc4random_uniform(viewSize.height/2.0));
			self.state = SWARMER_HUNTING;
		}
	}
	else
	{
		NSPoint speed = self.speed;
		NSPoint player = WCGlobals.globalsManager.thePlayer.worldPosition;
		CGFloat playerDir = WCGlobals.globalsManager.thePlayer.scale.x;
		CGFloat left, right, dx, dy, t = 0.01;

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
		
		if(!counter--)
		{
			offset = NSMakePoint(arc4random_uniform(viewSize.width/2.0), offset.y * 0.90);
			counter = GAME_SECONDS(1.0);
		}

		if(left <= right)
			dx = worldPoint.x - left - offset.x;
		else
			dx = worldPoint.x + right + offset.x;
		
		if(speed.x * playerDir < 0.0)
			t = 0.026;
		
		
		if(worldPoint.y > player.y)
			dy = player.y + offset.y;
		else
			dy = player.y - offset.y;
		
		speed.x = MIN(600.0, speed.x);
		[WCGlobals evalCubicCurrPos:&worldPoint.x currSpeed:&speed.x destPos:dx timeStep:t];
		[WCGlobals evalCubicCurrPos:&worldPoint.y currSpeed:&speed.y destPos:dy timeStep:t];
		
		self.speed = speed;
	}

	if(worldPoint.y > fh - selfHeight)
		worldPoint.y = selfHeight;
	else if(worldPoint.y < selfHeight)
		worldPoint.y = fh - selfHeight;
	
	self.worldPosition = worldPoint;

	if([WCGlobals WCPointInView:worldPoint])
	{
		if(!shootTime--)
		{
			[WCSoundManager playSound:DB_STRINGS[DB_SWARMERSHOOT]];
			[WCBullet makeBulletAt:self.worldPosition aimingAt:WCGlobals.globalsManager.thePlayer.worldPosition withVelocity:WCGlobals.globalsManager.velocity];
			shootTime = SWARMER_SHOOT_WINDOW;
		}
	}
}

@end
