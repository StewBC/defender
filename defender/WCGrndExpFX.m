//
//  WCGrndExpFX.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-18.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCGrndExpFX.h"
#import "WCGlobals.h"
#import "WCSpriteManager.h"
#import "WCBackground.h"

/*---------------------------------------------------------------------------*/
#define GROUND_PARTICLE_WIDTH		3
#define GROUND_PARTICLE_SCALE_X		3.0
#define GROUND_PARTICLE_SCALE_Y		2.0
#define GROUND_PARTICLE_SPEED_X		(arc4random_uniform(7)-3.0)
#define GROUND_PARTICLE_SPEED_Y		(arc4random_uniform(5)-2.0)
#define GROUND_FADE_TIME			(1.0/3.0)
#define GROUND_FADE_RANGE			(1.0-0.1)

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCGrndExpFX

@synthesize particles;

/*---------------------------------------------------------------------------*/
- (id)initWithTimeToLive:(UInt32)ttl
{
	if(self = [super initWithTimeToLive:ttl])
	{
		NSSize viewSize = WCGlobals.globalsManager.viewSize;
		NSPoint aPoint = NSZeroPoint;
		UInt32 length = viewSize.width / GROUND_PARTICLE_WIDTH;
		
		self.timeToFade = ttl * GROUND_FADE_TIME;
		self.fadeAmount = GROUND_FADE_RANGE / self.timeToFade;
		
		particles = [NSMutableArray arrayWithCapacity:length];

		for(int i = 0; i < length; ++i)
		{
			WCParticleSprite *aGroundSprite = [WCSpriteManager makeSpriteClass:[WCParticleSprite class] fromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[DB_COLORS]];

			aPoint.y = [WCGlobals.globalsManager.theBackground getGroundHeightAtX:aPoint.x];
			
			aGroundSprite.position = aPoint;
			aGroundSprite.scale = NSMakePoint(GROUND_PARTICLE_SCALE_X*SPRITE_SCALE, GROUND_PARTICLE_SCALE_Y*SPRITE_SCALE);
			aGroundSprite.speed = NSMakePoint(GROUND_PARTICLE_SPEED_X, GROUND_PARTICLE_SPEED_Y);
			[aGroundSprite setFrameInCurrAnim:7];
			
			[particles addObject:aGroundSprite];
			
			aPoint.x += GROUND_PARTICLE_WIDTH;
		}
	}
	return self;
}

/*---------------------------------------------------------------------------*/
- (void)fadeEffect
{
	for(WCParticleSprite *aSprite in particles)
	{
		aSprite.transparency -= self.fadeAmount;
	}
}

/*---------------------------------------------------------------------------*/
- (void)animateAndDrawEffect:(UInt32)frameCounter
{
	NSSize viewSize = WCGlobals.globalsManager.viewSize;
	NSPoint worldDelta = WCGlobals.globalsManager.drawPoint;
	worldDelta.x -= self.worldPoint.x;
	self.worldPoint = WCGlobals.globalsManager.drawPoint;
	
	for(WCParticleSprite *aSprite in particles)
	{
		NSPoint aPoint = aSprite.position;
		NSPoint aSpeed = aSprite.speed;
		
		aPoint.y += aSpeed.y;
		aPoint.x += aSpeed.x - worldDelta.x;
		if(aPoint.x < 0.0)
			aPoint.x += viewSize.width;
		else if(aPoint.x > viewSize.width)
			aPoint.x -= viewSize.width;

		aSprite.position = aPoint;
		aSprite.rotation += arc4random_uniform(100) / 10.0;

		[WCSpriteManager renderSprite:aSprite onLayer:RENDER_LAYER_AI withCopy:NO];
	}
}

@end
