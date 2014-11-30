//
//  WCBomber.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-10.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCBomber.h"
#import "WCGlobals.h"
#import "WCAIs.h"
#import "WCBomb.h"

/*---------------------------------------------------------------------------*/
#define	BOMBER_ANIM_FRAME_DELAY			1
#define BOMBER_NUM_COLORS				3
#define	BOMBER_NUM_FRAMES				4
#define BOMBER_BOMB_WINDOW				100
#define BOMBER_BOMB_CHANCE				96

struct _tagWCBomberAnimSeq
{
	UInt32		frameIdx;
	NSPoint		scale;
	CGFloat		rotation;
	NSPoint		colAdj;
} bomberAnimSeq[] =
{
	0, { SPRITE_SCALE,  SPRITE_SCALE}, 0.0,  { 0.0,				   0.0},					// 0
	1, { SPRITE_SCALE,  SPRITE_SCALE}, 0.0,  { 0.0,				  -1.0*SPRITE_SCALE},		// 1
	2, { SPRITE_SCALE,  SPRITE_SCALE}, 0.0,  { 0.0,				  -2.0*SPRITE_SCALE},		// 2
	1, { SPRITE_SCALE, -SPRITE_SCALE}, 0.0,  { 0.0,				  -2.0*SPRITE_SCALE},		// 3
	0, { SPRITE_SCALE, -SPRITE_SCALE}, 0.0,  { 0.0,				  -2.0*SPRITE_SCALE},		// 4
	3, { SPRITE_SCALE, -SPRITE_SCALE}, 0.0,  { -1.0*SPRITE_SCALE, -2.0*SPRITE_SCALE},		// 5
	2, { SPRITE_SCALE,  SPRITE_SCALE}, 270.0,{ -2.0*SPRITE_SCALE, -2.0*SPRITE_SCALE},		// 6
	3, {-SPRITE_SCALE, -SPRITE_SCALE}, 0.0,  { -2.0*SPRITE_SCALE, -2.0*SPRITE_SCALE},		// 7
	0, {-SPRITE_SCALE, -SPRITE_SCALE}, 0.0,  { -2.0*SPRITE_SCALE, -2.0*SPRITE_SCALE},		// 8
	1, {-SPRITE_SCALE, -SPRITE_SCALE}, 0.0,  { -2.0*SPRITE_SCALE, -2.0*SPRITE_SCALE},		// 9
	2, {-SPRITE_SCALE,  SPRITE_SCALE}, 0.0,  { -2.0*SPRITE_SCALE, -1.0*SPRITE_SCALE},		// 10
	1, {-SPRITE_SCALE,  SPRITE_SCALE}, 0.0,  { -2.0*SPRITE_SCALE,  0.0},					// 11
	0, {-SPRITE_SCALE,  SPRITE_SCALE}, 0.0,  { -2.0*SPRITE_SCALE,  0.0},					// 12
	3, {-SPRITE_SCALE,  SPRITE_SCALE}, 0.0,  { -2.0*SPRITE_SCALE,  0.0},					// 13
	2, { SPRITE_SCALE,  SPRITE_SCALE}, 90.0, { -1.0*SPRITE_SCALE,  0.0},					// 14
	3, { SPRITE_SCALE,  SPRITE_SCALE}, 0.0,  { 0.0,				   0.0},					// 15
};
const int numBomberFrames = sizeof(bomberAnimSeq) / sizeof(bomberAnimSeq[0]);

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCBomber

@synthesize frame;
@synthesize color;
@synthesize timeTillAnim;
@synthesize func;
@synthesize waves;
@synthesize amplitude;
@synthesize yOffset;

/*---------------------------------------------------------------------------*/
- (UInt32)isA
{
	return DB_BOMBER;
}

/*---------------------------------------------------------------------------*/
- (NSRect)colRect
{
	NSRect aRect = [super colRect];
	aRect.origin.x += bomberAnimSeq[frame].colAdj.x;
	aRect.origin.y += bomberAnimSeq[frame].colAdj.y;
	return aRect;
}

/*---------------------------------------------------------------------------*/
- (void)setupWithFunc:(BOOL)sinCos waves:(CGFloat)numWaves andAmplitude:(CGFloat)ampl
{
	func = sinCos;
	waves = numWaves;
	amplitude = ampl;
	self.pivot = NSMakePoint(2.5, 2.5);
}

/*---------------------------------------------------------------------------*/
- (void)move
{
	NSPoint worldPoint = self.worldPosition;
	NSSize fieldSize = WCGlobals.globalsManager.fieldSize;
	CGFloat selfHeight = self.srcRect.size.height;
	
	worldPoint.x += self.speed.x;
	CGFloat funcVal = ((RADS(360.0)/fieldSize.width)*waves)*worldPoint.x;
	
	if(func)
		funcVal = sin(funcVal) * amplitude;
	else
		funcVal = cos(funcVal) * amplitude;

	CGFloat delta = funcVal - yOffset;
	worldPoint.y += self.speed.y + delta;
	yOffset = funcVal;
	
	if(worldPoint.y > fieldSize.height - selfHeight)
		worldPoint.y = selfHeight;
	else if(worldPoint.y < selfHeight)
		worldPoint.y = fieldSize.height - selfHeight;

	self.worldPosition = worldPoint;
}

/*---------------------------------------------------------------------------*/
- (void)run:(UInt32)frameCounter
{
	[self move];
	
	if(arc4random_uniform(BOMBER_BOMB_WINDOW) > BOMBER_BOMB_CHANCE)
	{
		WCBomb *aBomb = [WCSpriteManager makeSpriteClass:[WCBomb class] fromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[DB_BOMB]];
		aBomb.worldRect = aBomb.srcRect;
		aBomb.worldPosition = self.worldPosition;
		aBomb.scale = NSMakePoint(SPRITE_SCALE, SPRITE_SCALE);
		[WCGlobals.globalsManager.theAIs.fixupList addObject:aBomb];
	}
	
	if(!timeTillAnim--)
	{
		if(++frame >= numBomberFrames)
			frame = 0;
		
		if(++color >= BOMBER_NUM_COLORS)
			color = 0;
		
		[self setFrameInCurrAnim:bomberAnimSeq[frame].frameIdx+color*BOMBER_NUM_FRAMES];
		self.scale = bomberAnimSeq[frame].scale;
		self.rotation = bomberAnimSeq[frame].rotation;
		
		timeTillAnim = BOMBER_ANIM_FRAME_DELAY;
	}
}
@end
