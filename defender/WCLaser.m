//
//  WCLaser.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCLaser.h"
#import "WCGlobals.h"
#import "WCSpriteManager.h"

/*---------------------------------------------------------------------------*/
#define LASER_STATES				10
#define LASER_FADE_STATE			7
#define LASER_FADE_AMOUNT			0.15
#define LASER_HOLD					1
#define LASER_SPEED					14
#define LASER_COLOR_CYCLE			7
#define	PLAYER_SHIP_PIVOT_TO_NOSEW	7
#define	PLAYER_SHIP_PIVOT_TO_NOSEH	-5.5

CGFloat scale[LASER_STATES][LASER_COMPONENTS] =
{
	{0.10, 0.10,  1.0, 2.0},
	{0.25, 0.20,  4.0, 2.0},
	{0.50, 0.35,  8.0, 2.0},
	{1.50, 0.50, 12.0, 2.0},
	{0.75, 0.65, 16.0, 2.0},
	{1.25, 0.80, 20.0, 2.0},
	{1.50, 0.95, 24.0, 2.0},
	{1.75, 1.05, 28.0, 2.0},
	{1.75, 1.05, 28.0, 2.0},
	{1.75, 1.05, 28.0, 2.0},
};

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCLaser

@synthesize state;
@synthesize direction;
@synthesize colorIndex;
@synthesize worldRect;
@synthesize wrapRect;
@synthesize wrapsField;
@synthesize target;

/*---------------------------------------------------------------------------*/
- (id)initWithPosition:(NSPoint)aPoint direction:(CGFloat)aDirection andColorIndex:(UInt32)aColorIndex
{
	if(self = [super init])
	{
		state = 0;
		colorIndex = aColorIndex;
		
		direction = aDirection;
		beam[3] = [WCSpriteManager makeSpriteFromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[DB_COLORS]];
		// Compensate for 1st loop so laser starts at ship, not in front
		aPoint.x -= (LASER_SPEED*direction);
		// Align laser with tip of the nose
		aPoint.x += PLAYER_SHIP_PIVOT_TO_NOSEW * direction;
		aPoint.y += PLAYER_SHIP_PIVOT_TO_NOSEH;
		
		beam[3].position = aPoint;
		beam[3].pivot = NSMakePoint(0.0, 0.0);
		beam[2] = [beam[3] copy];
		beam[1] = [beam[3] copy];
		beam[0] = [beam[3] copy];

		[beam[3] setFrameInCurrAnim:WCCOLOR_WHITE];
		[beam[2] setFrameInCurrAnim:colorIndex];

		beam[0].currAnim = beam[1].currAnim = [beam[0].spriteData findAnimByName:DB_STRINGS[DB_LASERS]];
		[beam[1] setFrameInCurrAnim:colorIndex];
		[beam[0] setFrameInCurrAnim:colorIndex];
		
		beam[0].scale = NSMakePoint(direction*scale[0][0], SPRITE_SCALE);
		beam[1].scale = NSMakePoint(direction*scale[0][1], SPRITE_SCALE);
		beam[2].scale = NSMakePoint(direction*scale[0][2], SPRITE_SCALE);
		beam[3].scale = NSMakePoint(direction*scale[0][3]*2.0, SPRITE_SCALE);
		
		worldRect = NSMakeRect(0.0, beam[3].position.y, 0.0, beam[3].srcRect.size.height);
	}
	return self;
}

/*---------------------------------------------------------------------------*/
- (BOOL)run
{
	if(++state < LASER_HOLD*LASER_STATES)
	{
		for(int32_t i=0; i<LASER_COMPONENTS;++i)
		{
			beam[i].scale = NSMakePoint(direction*scale[state/LASER_HOLD][i], beam[i].scale.y);
			width[i] = beam[i].srcRect.size.width * beam[i].scale.x;
			if(state > LASER_FADE_STATE * LASER_HOLD)
				beam[i].transparency -= LASER_FADE_AMOUNT;
		}

		if(!(state % LASER_COLOR_CYCLE))
		{
			if(++colorIndex >= (WCCOLOR_NUM_COLORS-1))
				colorIndex = WCCOLOR_0;
			[beam[0] setFrameInCurrAnim:colorIndex];
			[beam[1] setFrameInCurrAnim:colorIndex];
			[beam[2] setFrameInCurrAnim:colorIndex];
		}
	
		beam[0].position = NSMakePoint(beam[0].position.x+(LASER_SPEED*direction), beam[0].position.y);
		for(int32_t i=1; i<LASER_COMPONENTS;++i)
		{
			beam[i].position = NSMakePoint(beam[i-1].position.x + width[i-1], beam[i].position.y);
		}
		
		[WCSpriteManager renderSprite:beam[0] onLayer:RENDER_LAYER_AI withCopy:NO];
		[WCSpriteManager renderSprite:beam[1] onLayer:RENDER_LAYER_AI withCopy:NO];
		[WCSpriteManager renderSprite:beam[2] onLayer:RENDER_LAYER_AI withCopy:NO];
		[WCSpriteManager renderSprite:beam[3] onLayer:RENDER_LAYER_AI withCopy:NO];

		NSSize fs = WCGlobals.globalsManager.fieldSize;
		worldRect.origin.x = WCGlobals.globalsManager.drawPoint.x + beam[0].position.x;
		worldRect.size.width = (beam[3].position.x + width[3]) - beam[0].position.x;
		
		// Normalize the worldRect
		if(direction<0.0)
		{
			worldRect.origin.x += worldRect.size.width;
			worldRect.size.width = -worldRect.size.width;
		}
		
		if(worldRect.origin.x > fs.width)
			worldRect.origin.x -= fs.width;
		
		if(NSMaxX(worldRect) > fs.width)
		{
			wrapRect = NSMakeRect(fs.width, 0.0, fs.width, fs.height);
			wrapRect = NSIntersectionRect(wrapRect, worldRect);
			wrapRect.origin.x = 0.0;
			wrapsField = YES;
		}
		else
		{
			wrapsField = NO;
		}
		
		return YES;
	}
	else
		return NO;
}

@end
