//
//  WCHuman.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCHuman.h"
#import "WCGlobals.h"
#import "WCSoundManager.h"
#import "WCTextout.h"
#import "WCBackground.h"
#import "WCEffects.h"
#import "WCExplosionFX.h"
#import "WCScoreFX.h"
#import "WCAIs.h"

/*---------------------------------------------------------------------------*/
#define HUMAN_WALKING_SPEED			1.0
#define HUMAN_FRAME_ANIM_SPEED		10
#define HUMAN_FALLING_SPEED			2.0
#define HUMAN_SURVIVE_FALL_HEIGHT	50

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCHuman

@synthesize theHost;
@synthesize desiredPosition;
@synthesize frame;
@synthesize height;

/*---------------------------------------------------------------------------*/
- (UInt32)isA
{
	return DB_HUMAN;
}

/*---------------------------------------------------------------------------*/
- (void)addHost:(WCAISprite*)aHost
{
	theHost = aHost;
	self.state = HUMAN_STATE_CAUGHT;
}

/*---------------------------------------------------------------------------*/
- (void)removeHost
{
	theHost = Nil;
	if(HUMAN_STATE_HOISTED == self.state)
		self.state = HUMAN_STATE_FALLING;
	else
		self.state = HUMAN_STATE_INIT;
}

/*---------------------------------------------------------------------------*/
- (void)hoistBy:(CGFloat)aHoistAmnt
{
	NSPoint aPoint = self.worldPosition;
	aPoint.y += aHoistAmnt;
	self.worldPosition = aPoint;
	self.state = HUMAN_STATE_HOISTED;
}

/*---------------------------------------------------------------------------*/
- (void)run:(UInt32)frameCounter
{
	NSPoint worldPoint = self.worldPosition;

	switch(self.state)
	{
		case HUMAN_STATE_INIT:
			{
				NSSize fs = WCGlobals.globalsManager.fieldSize;
				if(self.scale.x < 0.0)
					desiredPosition.x = self.worldPosition.x - WCGlobals.globalsManager.theBackground.stripWidth;
				else
					desiredPosition.x = self.worldPosition.x + WCGlobals.globalsManager.theBackground.stripWidth;

				if(desiredPosition.x > fs.width)
					desiredPosition.x -= fs.width;
				else if(desiredPosition.x < 0.0)
					desiredPosition.x += fs.width;

				desiredPosition.y = [WCGlobals.globalsManager.theBackground getGroundHeightAtX:desiredPosition.x];
				CGFloat extra = arc4random_uniform(desiredPosition.y - 2.0*self.srcRect.size.height) + self.srcRect.size.height;
				if(extra > 0.0)
					desiredPosition.y -= extra;
				
				self.state = HUMAN_STATE_WALKING;
			}
			break;
			
		case HUMAN_STATE_WALKING:
			{
				if(!(frameCounter % HUMAN_FRAME_ANIM_SPEED))
				{
					if(worldPoint.y > desiredPosition.y)
						worldPoint.y -= HUMAN_WALKING_SPEED;
					else if(worldPoint.y < desiredPosition.y)
						worldPoint.y += HUMAN_WALKING_SPEED;

					if(worldPoint.x != desiredPosition.x)
						worldPoint.x += self.scale.x * HUMAN_WALKING_SPEED;
					
					if((fabs(worldPoint.x-desiredPosition.x) < HUMAN_WALKING_SPEED))
					{
						worldPoint.x += self.scale.x;
						self.state = HUMAN_STATE_INIT;
					}
					
					CGFloat groundY = [WCGlobals.globalsManager.theBackground getGroundHeightAtX:worldPoint.x];
					if(groundY < worldPoint.y)
						worldPoint.y = groundY;
					
					frame = 1 - frame;
					[self setFrameInCurrAnim:frame];
				}
			}
			break;
			
		case HUMAN_STATE_FALLING:
			if(self.worldPosition.y > [WCGlobals.globalsManager.theBackground getGroundHeightAtX:self.worldPosition.x])
			{
				worldPoint.y -= HUMAN_FALLING_SPEED;
				++height;
			}
			else
			{
				if(height < HUMAN_SURVIVE_FALL_HEIGHT)
				{
					NSPoint aPoint = self.position;
					aPoint.x -= 48.0;
					[WCSoundManager playSound:DB_STRINGS[DB_WESSELS]];
					[WCGlobals.globalsManager.theEffects addEffect:[[WCScoreFX alloc] initAt:aPoint withTimeToLive:GAME_SECONDS(1.5) andScore:GAME_SCORE_HUMAN_FALL_SAFE]];
					WCGlobals.globalsManager.score += GAME_SCORE_HUMAN_FALL_SAFE;
				}
				else
				{
					self.dead = YES;
					[WCGlobals.globalsManager.theAIs explodeAi:self];
				}
				height = 0;
				self.state = HUMAN_STATE_WALKING;
			}
			break;
	}
	self.worldPosition = worldPoint;
}

@end
