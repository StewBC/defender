//
//  WCLander.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCLander.h"
#import "WCGlobals.h"
#import "WCSoundManager.h"
#import "WCAIs.h"
#import "WCHuman.h"
#import "WCMutant.h"
#import "WCBullet.h"
#import "WCPlayer.h"

/*---------------------------------------------------------------------------*/
#define LANDER_SPEED				3.0
#define LANDER_JITTER_INTERVAL		GAME_SECONDS(5.0)
#define LANDER_JITTER_AMOUNT		25
#define LANDER_MIN_FIELD			(1.0/4.0)
#define LANDER_DESCENT_SPEED		2.0
#define LANDER_ASCENT_SPEED			3.0
#define LANDER_CAPTURE_CHANCE		60
#define LANDER_ANIM_SPEED			3

struct _tagWCLanderAnimSeq
{
	UInt32	frame;
	CGFloat	scaleX;
} landerAnimSeq[] =
{
	0,  SPRITE_SCALE,
	1,  SPRITE_SCALE,
	2,  SPRITE_SCALE,
	3,  SPRITE_SCALE,
	4,  SPRITE_SCALE,
	4, -SPRITE_SCALE,
	3, -SPRITE_SCALE,
	2, -SPRITE_SCALE,
	1, -SPRITE_SCALE,
};
const int numLanderFrames = sizeof(landerAnimSeq) / sizeof(landerAnimSeq[0]);

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCLander

@synthesize theCargo;
@synthesize timerCounter;
@synthesize waitCounter;
@synthesize animTimer;
@synthesize animFrame;
@synthesize shootTime;
@synthesize destination;

/*---------------------------------------------------------------------------*/
- (UInt32)isA
{
	return DB_LANDER;
}

/*---------------------------------------------------------------------------*/
- (void)addCargo:(WCAISprite*)cargo
{
	theCargo = cargo;
}

/*---------------------------------------------------------------------------*/
- (void)removeCargo:(WCAISprite*)cargo
{
	theCargo = Nil;
	self.state = LANDER_STATE_NEEDS_INIT;
}

/*---------------------------------------------------------------------------*/
- (void)run:(UInt32)frameCounter
{
	NSPoint worldPoint = self.worldPosition;
	NSPoint speed = self.speed;
	
	switch(self.state)
	{
		case LANDER_STATE_NEEDS_INIT:
			{
				NSSize fieldSize = WCGlobals.globalsManager.fieldSize;
				speed = NSMakePoint((arc4random_uniform(3) - 1.0) * LANDER_SPEED,-LANDER_SPEED);
				
				CGFloat selfHeight = self.colRect.size.height * SPRITE_SCALE;
				destination = NSMakePoint(arc4random_uniform(fieldSize.width), arc4random_uniform(fieldSize.height - 2.0 * selfHeight) + selfHeight);
				if(destination.y > worldPoint.y)
					speed.y = LANDER_SPEED;
				self.speed = speed;
				self.state = LANDER_STATE_INITIAL_SEEK;
				shootTime = LANDER_SHOOT_WINDOW;
			}
			break;
			
		case LANDER_STATE_INITIAL_SEEK:
			{
				CGFloat yd = fabs(destination.y - worldPoint.y);
				if(yd < LANDER_SPEED)
				{
					if(!speed.x)
						speed.x = destination.x > worldPoint.x ? 1.0 : -1.0;

					speed.y = 0.0;
					self.speed = speed;
					timerCounter = arc4random_uniform(LANDER_JITTER_INTERVAL) + GAME_SECONDS(1.0);
					self.state = LANDER_STATE_HUMAN_SEEK;
				}
				worldPoint.x += self.speed.x;
				worldPoint.y += self.speed.y;
			}
			break;
			
		case LANDER_STATE_HUMAN_SEEK:
			{
				if(!timerCounter--)
				{
					NSPoint d = destination;
					CGFloat oh = self.srcRect.size.height;
					CGFloat fh = WCGlobals.globalsManager.fieldSize.height - oh;
					CGFloat jitter = arc4random_uniform(LANDER_JITTER_AMOUNT) * arc4random_uniform(2) ? -1.0 : 1.0;
					if(jitter > 0.0 && d.y + jitter < fh)
					{
						d.y += jitter;
						speed.y = LANDER_SPEED;
						self.speed = speed;
					}
					else if(d.y > oh - jitter)
					{
						d.y += jitter;
						speed.y = -LANDER_SPEED;
						self.speed = speed;
					}
					destination = d;

					timerCounter = arc4random_uniform(LANDER_JITTER_INTERVAL) + GAME_SECONDS(1.0);
				}

				worldPoint.x += self.speed.x;
				CGFloat yd = fabs(destination.y - worldPoint.y);
				if(yd > LANDER_SPEED)
					worldPoint.y += self.speed.y;
				
				if(!waitCounter)
				{
					NSRect beamRect = self.colRect;
					beamRect.size.height = WCGlobals.globalsManager.fieldSize.height;
					beamRect.origin.y = 0.0;
					for(WCHuman *aHuman in WCGlobals.globalsManager.theAIs.humansList)
					{
						if(aHuman.state == HUMAN_STATE_WALKING && NSIntersectsRect(beamRect, aHuman.colRect))
						{
							if(arc4random_uniform(100) < LANDER_CAPTURE_CHANCE)
							{
								[aHuman addHost:self];
								[self addCargo:aHuman];
								self.state = LANDER_STATE_HUMAN_SELECTED;
							}
							else
								waitCounter = 2 * aHuman.colRect.size.width;
						}
					}
				}
				else
				{
					--waitCounter;
				}
			}
			break;
			
		case LANDER_STATE_HUMAN_SELECTED:
			{
				int dx = (worldPoint.x) - (theCargo.worldPosition.x);
				if(dx != 0)
					worldPoint.x += dx > 0 ? -1.0 : 1.0;

				int dy = (worldPoint.y - self.colRect.size.height) - theCargo.worldPosition.y;
				if(dy != 0)
				{
					worldPoint.y -= MIN(dy, dy > 0 ? LANDER_DESCENT_SPEED : -LANDER_DESCENT_SPEED);
				}
				else
				{
					[WCSoundManager playSound:DB_STRINGS[DB_HUMANPICKUP]];
					self.state = LANDER_STATE_HUMAN_CAPTURED;
				}
			}
			break;

		case LANDER_STATE_HUMAN_CAPTURED:
			{
				if(worldPoint.y < WCGlobals.globalsManager.fieldSize.height - self.colRect.size.height)
				{
					worldPoint.y += LANDER_ASCENT_SPEED;
					[(WCHuman*)theCargo hoistBy:LANDER_ASCENT_SPEED];
				}
				else
				{
					theCargo.dead = YES;
					[WCGlobals.globalsManager.theAIs.fixupList addObject:self];
					[(WCHuman*)theCargo removeHost];
					[self removeCargo:theCargo];
				}
			}
			break;
	}
	
	if([WCGlobals WCPointInView:worldPoint])
	{
		if(!shootTime--)
		{
			[WCSoundManager playSound:DB_STRINGS[DB_LANDERSHOOT]];
			[WCBullet makeBulletAt:self.worldPosition aimingAt:WCGlobals.globalsManager.thePlayer.worldPosition withVelocity:WCGlobals.globalsManager.velocity];
			shootTime = LANDER_SHOOT_WINDOW;
		}
	}
	
	if(!animTimer--)
	{
		if(++animFrame >= numLanderFrames)
			animFrame = 0;
		[self setFrameInCurrAnim:landerAnimSeq[animFrame].frame];
		NSPoint aScale = self.scale;
		aScale.x = landerAnimSeq[animFrame].scaleX;
		self.scale = aScale;
		animTimer = LANDER_ANIM_SPEED;
	}

	self.worldPosition = worldPoint;
}

@end
