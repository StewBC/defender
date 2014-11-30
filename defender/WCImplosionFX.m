//
//  WCImplosionFX.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-14.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCImplosionFX.h"
#import "WCGlobals.h"
#import "WCSpriteManager.h"
#import "WCPlayer.h"

/*---------------------------------------------------------------------------*/
struct _tagImpTemplate
{
	UInt32	textureDBId;
	UInt32	animNameID;
	UInt32	frameIdx;
	NSPoint	slices;				// num x & y particles
	NSPoint	scale;
} imp_template[] =
{
	{DB_LOGO_PNG,		DB_COLORS,	5, 35.0,	6.0, 2.0, 2.0},
	{DB_SPRITES_PNG,	DB_PLAYER,	0, 5.0,		4.0, SPRITE_SCALE, SPRITE_SCALE},
	{DB_SPRITES_PNG,	DB_LANDER,	0, 5.0,		4.0, SPRITE_SCALE, SPRITE_SCALE},
	{DB_SPRITES_PNG,	DB_MUTANT,	0, 5.0,		4.0, SPRITE_SCALE, SPRITE_SCALE},
	{DB_SPRITES_PNG,	DB_BAITER,	0, 5.0,		4.0, SPRITE_SCALE, SPRITE_SCALE},
	{DB_SPRITES_PNG,	DB_BOMBER,	0, 5.0,		4.0, SPRITE_SCALE, SPRITE_SCALE},
	{DB_SPRITES_PNG,	DB_POD,		0, 5.0,		4.0, SPRITE_SCALE, SPRITE_SCALE},
	{DB_SPRITES_PNG,	DB_SWARMER,	0, 5.0,		4.0, SPRITE_SCALE, SPRITE_SCALE},
	{DB_SPRITES_PNG,	DB_HUMAN,	0, 5.0,		4.0, SPRITE_SCALE, SPRITE_SCALE},
};

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCImplosionFX

@synthesize particles;

/*---------------------------------------------------------------------------*/
- (id)initAt:(NSPoint)aPoint withTimeToLive:(int)ttl andTemplateIdx:(int)tIdx
{
	BOOL reverseTexture = NO;
	
	if(ttl < 0)
	{
		ttl = -ttl;
		reverseTexture = YES;
	}
	
	if(self = [super initWithTimeToLive:ttl])
	{
		NSPoint random;
		BOOL explode = NO;
		int textureX;
		
		if(tIdx < 0)
		{
			tIdx = -tIdx;
			explode = YES;
			random.x = (arc4random_uniform(11)-5.0);
			random.y = (arc4random_uniform(11)-5.0);
		}
		WCParticleSprite *impl = [WCSpriteManager makeSpriteClass:[WCParticleSprite class] fromImage:DB_STRINGS[imp_template[tIdx].textureDBId] forAnim:DB_STRINGS[imp_template[tIdx].animNameID]];
		
		[impl setFrameInCurrAnim:imp_template[tIdx].frameIdx];
		NSRect trgtRect, srcRec = impl.srcRect;
		NSPoint numParticles = imp_template[tIdx].slices;

		trgtRect.origin = NSZeroPoint;
		trgtRect.size.width = srcRec.size.width / numParticles.x;
		trgtRect.size.height = srcRec.size.height / numParticles.y;
		NSPoint midPoint = NSMakePoint(srcRec.size.width/2.0, srcRec.size.height/2.0);

		particles = [NSMutableArray arrayWithCapacity:numParticles.x * numParticles.y];
		
		NSPoint scale = imp_template[tIdx].scale;

		for(int y = numParticles.y - 1; y >= 0; --y)
		{
			for(int x = numParticles.x - 1; x >= 0; --x)
			{
				impl = [WCSpriteManager makeSpriteClass:[WCParticleSprite class] fromImage:DB_STRINGS[imp_template[tIdx].textureDBId] forAnim:DB_STRINGS[imp_template[tIdx].animNameID]];
				
				impl.scale = scale;
				impl.speed = NSMakePoint((midPoint.x - (x * trgtRect.size.width)), (midPoint.y - (y * trgtRect.size.height)));

				if(explode)
				{
					impl.speed = NSMakePoint(-impl.speed.x*3.0+random.x, -impl.speed.y*3.0+random.y);
					impl.position = NSMakePoint(((x * trgtRect.size.width * scale.x) + aPoint.x), ((y * trgtRect.size.height * scale.y) + aPoint.y));
				}
				else
				{
					impl.position = NSMakePoint(((x * trgtRect.size.width * scale.x) + aPoint.x) + (-impl.speed.x * ttl), ((y * trgtRect.size.height * scale.y) + aPoint.y) + (-impl.speed.y * ttl));
				}
				
				if(reverseTexture)
					textureX = numParticles.x - x;
				else
					textureX = x;
				trgtRect.origin = NSMakePoint(textureX * trgtRect.size.width + srcRec.origin.x, y * trgtRect.size.height + srcRec.origin.y);
				impl.srcRect = trgtRect;
				
				[particles addObject:impl];
			}
		}
	}
	return self;
}

/*---------------------------------------------------------------------------*/
- (void)fadeEffect
{
	
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
		if(aPoint.x < 0.0)
			aPoint.x += fw;
		else if(aPoint.x > fw)
			aPoint.x -= fw;
		aSprite.position = aPoint;
		
		[WCSpriteManager renderSprite:aSprite onLayer:RENDER_LAYER_TEXT withCopy:NO];
	}
}

@end
