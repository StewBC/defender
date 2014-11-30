//
//  WCExplosionFX.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCExplosionFX.h"
#import "WCGlobals.h"
#import "WCSpriteManager.h"

/*---------------------------------------------------------------------------*/
#define EXP_FADE_TIME_IN_TTL	(1.0/2.0)
#define EXP_FADE_RANGE			(1.0-0.5)
#define EXP_SLICE_SPEED			(arc4random_uniform(128)/64.0)
#define EXP_BASE_SPEED			2.5

struct _tagExpTemplate
{
	CGFloat	angle;				// a Perticle every angle degrees
	UInt32	slices;				// Like rings in the bark of a tree
	CGFloat	baseSpeed;
	CGFloat	scale;
	UInt32	color[2];			// Colour changes at end of life
} exp_template[] =
{
	{30.0, 4, 1.5, 2.0, {WCCOLOR_YELLOW, WCCOLOR_RED}},		// LOGO
	{15.0, 4, 2.5, 8.0, {WCCOLOR_WHITE, WCCOLOR_YELLOW}},	// PLAYER
	{45.0, 4, 1.5, 3.0, {WCCOLOR_GREEN, WCCOLOR_YELLOW}},	// LANDER
	{45.0, 4, 1.5, 4.0, {WCCOLOR_CYAN, WCCOLOR_PURPLE}},	// MUTANT
	{45.0, 4, 1.5, 4.0, {WCCOLOR_GREEN, WCCOLOR_YELLOW}},	// BAITER
	{45.0, 4, 1.5, 4.0, {WCCOLOR_BLUE, WCCOLOR_PURPLE}},	// BOMBER
	{45.0, 4, 1.5, 4.0, {WCCOLOR_CYAN, WCCOLOR_PURPLE}},	// POD
	{45.0, 4, 1.5, 4.0, {WCCOLOR_RED, WCCOLOR_YELLOW}},		// SWARMER
	{45.0, 4, 1.5, 2.0, {WCCOLOR_PURPLE, WCCOLOR_RED}},		// HUMAN
};

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCExplosionFX

@synthesize particles;

/*---------------------------------------------------------------------------*/
- (id)initAt:(NSPoint)aPoint withTimeToLive:(UInt32)ttl andTemplateIdx:(UInt32)tIdx
{
	if(self = [super initWithTimeToLive:ttl])
	{
		CGFloat angle = exp_template[tIdx].angle;
		CGFloat baseSpeed = exp_template[tIdx].baseSpeed;
		UInt32 slices = exp_template[tIdx].slices;
		CGFloat pScale = exp_template[tIdx].scale;
		UInt32 colorIndex = exp_template[tIdx].color[0];
		colChange[0] = exp_template[tIdx].color[1];
		UInt32 pInSlice = 360.0 / angle;
		
		self.timeToFade = EXP_FADE_TIME_IN_TTL * ttl;
		self.fadeAmount = EXP_FADE_RANGE / self.timeToFade;
		
		colChangeTimer = (ttl - self.timeToFade) / 3;
		
		particles = [NSMutableArray arrayWithCapacity:pInSlice * slices];
		
		CGFloat theta = RADS(0);
		for(int i = 0; i < pInSlice; ++i)
		{
			for(int s = 0; s < slices; ++s)
			{
				WCParticleSprite *expl = [WCSpriteManager makeSpriteClass:[WCParticleSprite class] fromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[DB_COLORS]];
				
				CGFloat x = cos(theta);
				CGFloat y = sin(theta);

				expl.scale = NSMakePoint(pScale, pScale);
				expl.position = aPoint;
				expl.speed = NSMakePoint(x*baseSpeed*(s+1)+EXP_SLICE_SPEED, y*baseSpeed*(s+1)+EXP_SLICE_SPEED);
				
				[expl setFrameInCurrAnim:colorIndex];
				[particles addObject:expl];
			}
			theta += RADS(angle);
		}

}
	return self;
}

/*---------------------------------------------------------------------------*/
- (void)fadeEffect
{
	if(!colChangeTimer--)
	{
		for(WCParticleSprite *aSprite in particles)
		{
			aSprite.transparency -= self.fadeAmount;
			[aSprite setFrameInCurrAnim:colChange[0]];
		}
	}
	
	for(WCParticleSprite *aSprite in particles)
	{
		aSprite.transparency -= self.fadeAmount;
	}
}

/*---------------------------------------------------------------------------*/
- (void)animateAndDrawEffect:(UInt32)frameCounter
{
	NSPoint worldDelta = WCGlobals.globalsManager.drawPoint;
	worldDelta.x -= self.worldPoint.x;
	CGFloat fw = WCGlobals.globalsManager.fieldSize.width;
	self.worldPoint = WCGlobals.globalsManager.drawPoint;

	for(WCParticleSprite *aSprite in particles)
	{
		NSPoint aPoint = aSprite.position;
		NSPoint aSpeed = aSprite.speed;
		
		aPoint.x += aSpeed.x - worldDelta.x;
		aPoint.y += aSpeed.y;
		aSprite.position = aPoint;
		if(aPoint.x < 0.0)
			aPoint.x += fw;
		else if(aPoint.x > fw)
			aPoint.x -= fw;

		[WCSpriteManager renderSprite:aSprite onLayer:RENDER_LAYER_AI withCopy:NO];
	}
}

@end
