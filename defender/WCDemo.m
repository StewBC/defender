//
//  WCDemo.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-26.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCDemo.h"
#import "WCGlobals.h"
#import "WCSpriteManager.h"
#import "WCTextout.h"
#import	"WCEffects.h"
#import "WCExplosionFX.h"
#import "WCImplosionFX.h"
#import "WCScoreFX.h"
#import "WCAIs.h"
#import "WCAISprite.h"
#import "WCPlayer.h"
#import "WCLaser.h"

/*---------------------------------------------------------------------------*/
enum
{
	DEMO_LANDER_ENTER,
	DEMO_LANDER_GET_HUMAN,
	DEMO_MUTANT_TAKEPOSITION,
	DEMO_PLAYER_CATCH_HUMAN,
	DEMO_PLAYER_LOWERS_HUMAN,
	DEMO_PLAYER_RETURNS_HOME,
	DEMO_EXPLODE_OBJECT,
	DEMO_PREP_OBJECT_FLY_IN,
	DEMO_OBJECT_FLY_IN,
	DEMO_STATE_HOLD
};

#define WORLD_OFFSET_X		720.0
#define LANDER_SPEED_Y		3.0
#define FIRE_POSITION		320.0
#define HUMAN_BASE_POSITION	68.0
#define HUMAN_X				680.0

NSPoint objPos[] =
{
	165.0, 294.0,
	330.0, 294.0,
	505.0, 294.0,
	170.0, 182.0,
	334.0, 182.0,
	505.0, 182.0,
};

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCLabel : NSObject

@property					NSPoint		position;
@property (nonatomic,copy)	NSString	*text;

- (id)initAt:(NSPoint)aPoint withText:(NSString*)aString;
- (void)render:(UInt32)font;

@end

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCLabel

@synthesize position;
@synthesize text;

/*---------------------------------------------------------------------------*/
- (id)initAt:(NSPoint)aPoint withText:(NSString*)aString
{
	if(self = [super init])
	{
		position = aPoint;
		text = aString;
	}
	return self;
}

/*---------------------------------------------------------------------------*/
- (void)render:(UInt32)font
{
	[WCTextout printAtX:position.x atY:position.y theString:text atScale:2.0f inFont:font orAttribs:nil];
}

@end

/*---------------------------------------------------------------------------*\
 * This is a wrapper for the WCAISprites so that the mini-map can draw them
\*---------------------------------------------------------------------------*/
@interface WCDAISprite : WCAISprite

@property				UInt32	type;
@property				UInt32	animFrame;
- (UInt32)isA;

@end

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCDAISprite

@synthesize type;
@synthesize animFrame;

/*---------------------------------------------------------------------------*/
- (UInt32)isA
{
	return type;
}

@end


/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCDemo

@synthesize render;
@synthesize labels;
@synthesize renderLabels;
@synthesize player;
@synthesize human;
@synthesize lander;
@synthesize object;
@synthesize laser;
@synthesize state;
@synthesize objCode;
@synthesize font;
@synthesize holdTimer;

/*---------------------------------------------------------------------------*/
- (id)init
{
	if(self = [super init])
	{
		[WCGlobals.globalsManager.theAIs.aiList removeAllObjects];

		render = WCGlobals.globalsManager.theAIs.aiList;
		labels = [NSMutableArray array];
		renderLabels = [NSMutableArray array];
	
		WCGlobals.globalsManager.drawPoint = NSMakePoint(WORLD_OFFSET_X, 0);
		WCGlobals.globalsManager.groundOkay = YES;

		player = [self makeDemoSprite:DB_PLAYER andPos:NSMakePoint(100.0,352.0)];
		human = [self makeDemoSprite:DB_HUMAN andPos:NSMakePoint(HUMAN_X,HUMAN_BASE_POSITION)];
		lander = [self makeDemoSprite:DB_LANDER andPos:NSMakePoint(HUMAN_X,360.0)];
		
		player.entryEffect = Nil;
		human.entryEffect = Nil;
		human.pivot = NSMakePoint(human.pivot.x, human.pivot.y * 3.0);
		human.scale = NSMakePoint(-SPRITE_SCALE, SPRITE_SCALE);
		
		[renderLabels addObject:[[WCLabel alloc] initAt:NSMakePoint((720.0/2.0)-12.0, 388.0) withText:@"SCANNER"]];
		
		[labels addObject:[[WCLabel alloc] initAt:NSMakePoint(170.0-30.0, 262.0) withText:@"LANDER"]];
		[labels addObject:[[WCLabel alloc] initAt:NSMakePoint(170.0-12.0, 242.0) withText:@"150"]];
		[labels addObject:[[WCLabel alloc] initAt:NSMakePoint(330.0-32.0, 262.0) withText:@"MUTANT"]];
		[labels addObject:[[WCLabel alloc] initAt:NSMakePoint(330.0-12.0, 242.0) withText:@"150"]];
		[labels addObject:[[WCLabel alloc] initAt:NSMakePoint(505.0-30.0, 262.0) withText:@"BAITER"]];
		[labels addObject:[[WCLabel alloc] initAt:NSMakePoint(505.0-10.0, 242.0) withText:@"200"]];
		[labels addObject:[[WCLabel alloc] initAt:NSMakePoint(170.0-32.0, 150.0) withText:@"BOMBER"]];
		[labels addObject:[[WCLabel alloc] initAt:NSMakePoint(170.0-12.0, 130.0) withText:@"250"]];
		[labels addObject:[[WCLabel alloc] initAt:NSMakePoint(330.0- 8.0, 150.0) withText:@"POD"]];
		[labels addObject:[[WCLabel alloc] initAt:NSMakePoint(330.0-16.0, 130.0) withText:@"1000"]];
		[labels addObject:[[WCLabel alloc] initAt:NSMakePoint(505.0-36.0, 150.0) withText:@"SWARMER"]];
		[labels addObject:[[WCLabel alloc] initAt:NSMakePoint(505.0-10.0, 130.0) withText:@"150"]];

		[self useSprite:player];
		[self useSprite:human];
		[self useSprite:lander];

		state = DEMO_LANDER_ENTER;
	}
	return self;
}

/*---------------------------------------------------------------------------*/
- (WCDAISprite*)makeDemoSprite:(UInt32)spriteID andPos:(NSPoint)aPoint;
{
	WCDAISprite *aSprite = [WCSpriteManager makeSpriteClass:[WCDAISprite class] fromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[spriteID]];
	
	aSprite.type = spriteID;
	aSprite.scale = NSMakePoint(SPRITE_SCALE, SPRITE_SCALE);
	aSprite.entryEffect = [[WCImplosionFX alloc] initAt:aPoint withTimeToLive:GAME_SECONDS(0.75) andTemplateIdx:spriteID];
	aPoint.x += WORLD_OFFSET_X;
	aSprite.worldPosition = aPoint;

	return aSprite;
}

/*---------------------------------------------------------------------------*/
- (void)useSprite:(WCAISprite*)aSprite
{
	[render addObject:aSprite];
	if(aSprite.entryEffect)
		[WCGlobals.globalsManager.theEffects.effectsList addObject:aSprite.entryEffect];
}

/*---------------------------------------------------------------------------*/
- (BOOL)run:(UInt32)frameCounter
{
	switch(state)
	{
		case DEMO_LANDER_ENTER:
			if(!lander.entryEffect)
			{
				state = DEMO_LANDER_GET_HUMAN;
				lander.speed = NSMakePoint(0,-LANDER_SPEED_Y);
			}
			break;
			
		case DEMO_LANDER_GET_HUMAN:
			lander.worldPosition = NSMakePoint(lander.worldPosition.x, lander.worldPosition.y + lander.speed.y);
			if(lander.speed.y < 0.0)
			{
				if(lander.worldPosition.y <= human.worldPosition.y)
				{
					lander.speed = NSMakePoint(0, LANDER_SPEED_Y);
				}
			}
			else
			{
				human.worldPosition = lander.worldPosition;
				if(lander.worldPosition.y >= FIRE_POSITION)
				{
					if(!laser)
						laser = [[WCLaser alloc] initWithPosition:player.position direction:SPRITE_SCALE andColorIndex:font];
					else
					{
						if(![laser run] || NSIntersectsRect(lander.colRect, laser.worldRect))
						{
//							[WCGlobals.globalsManager.theEffects addEffect:[[WCExplosionFX alloc] initAt:lander.position withTimeToLive:GAME_SECONDS(0.5) andTemplateIdx:DB_LANDER]];
							[WCGlobals.globalsManager.theEffects addEffect:[[WCImplosionFX alloc] initAt:lander.position withTimeToLive:GAME_SECONDS(0.5) andTemplateIdx:0-DB_LANDER]];
							[render removeObject:lander];
							lander = Nil;
							laser = Nil;
							
							player.speed = NSMakePoint(13.0, -3.5);
							state = DEMO_PLAYER_CATCH_HUMAN;
						}
					}
				}
			}
			break;
			
		case DEMO_PLAYER_CATCH_HUMAN:
			player.worldPosition = NSMakePoint(player.worldPosition.x + player.speed.x, player.worldPosition.y + player.speed.y);
			human.worldPosition = NSMakePoint(human.worldPosition.x, human.worldPosition.y - LANDER_SPEED_Y);
			if(player.worldPosition.x >= human.worldPosition.x)
			{
				[WCGlobals.globalsManager.theEffects addEffect:[[WCScoreFX alloc] initAt:NSMakePoint(player.position.x - 48.0, player.position.y) withTimeToLive:GAME_SECONDS(1.5) andScore:500]];
				[render removeObject:lander];
				player.speed = NSMakePoint(0.0, -3.0);
				state = DEMO_PLAYER_LOWERS_HUMAN;
			}
			break;
			
		case DEMO_PLAYER_LOWERS_HUMAN:
			player.worldPosition = NSMakePoint(player.worldPosition.x + player.speed.x, player.worldPosition.y + player.speed.y);
			human.worldPosition = player.worldPosition;
			if(human.worldPosition.y < HUMAN_BASE_POSITION)
			{
				[WCGlobals.globalsManager.theEffects addEffect:[[WCScoreFX alloc] initAt:NSMakePoint(player.position.x - 48.0, player.position.y) withTimeToLive:GAME_SECONDS(1.5) andScore:500]];
				player.speed = player.speed = NSMakePoint(-13.0, 6.5);
				player.scale = NSMakePoint(-SPRITE_SCALE, SPRITE_SCALE);
				state = DEMO_PLAYER_RETURNS_HOME;
			}
			break;
			
		case DEMO_PLAYER_RETURNS_HOME:
			player.worldPosition = NSMakePoint(player.worldPosition.x + player.speed.x, player.worldPosition.y + player.speed.y);
			if(player.worldPosition.y >= 352.0)
			{
				player.worldPosition = NSMakePoint(WORLD_OFFSET_X+100.0,352.0);
				player.speed = NSZeroPoint;
				player.scale = NSMakePoint(SPRITE_SCALE, SPRITE_SCALE);
				objCode = DB_PLAYER;
				state = DEMO_PREP_OBJECT_FLY_IN;
			}
			break;
			
		case DEMO_EXPLODE_OBJECT:
			{
				UInt32 idx = objCode-DB_LANDER;
				object = [self makeDemoSprite:objCode andPos:objPos[idx]];
				[self useSprite:object];
				
				idx *= 2;
				[renderLabels addObject:[labels objectAtIndex:idx]];
				[renderLabels addObject:[labels objectAtIndex:idx+1]];
				
				state = DEMO_PREP_OBJECT_FLY_IN;
			}
			break;
			
		case DEMO_PREP_OBJECT_FLY_IN:
			if(![WCGlobals.globalsManager.theEffects.effectsList count])
			{
				if(++objCode <= DB_SWARMER)
				{
					object = [self makeDemoSprite:objCode andPos:NSMakePoint(HUMAN_X, 240.0)];
					[self useSprite:object];
					object.speed = NSMakePoint(0.0, LANDER_SPEED_Y);
					state = DEMO_OBJECT_FLY_IN;
				}
				else
				{
					holdTimer = GAME_SECONDS(8);
					state = DEMO_STATE_HOLD;
				}
			}
			break;

		case DEMO_OBJECT_FLY_IN:
			if(![WCGlobals.globalsManager.theEffects.effectsList count])
			{
				object.worldPosition = NSMakePoint(object.worldPosition.x + object.speed.x, object.worldPosition.y + object.speed.y);
				if(object.worldPosition.y >= FIRE_POSITION)
				{
					if(!laser)
						laser = [[WCLaser alloc] initWithPosition:player.position direction:SPRITE_SCALE andColorIndex:font];
					else
					{
						if(![laser run] || NSIntersectsRect(object.colRect, laser.worldRect))
						{
							laser = Nil;
							
//							[WCGlobals.globalsManager.theEffects addEffect:[[WCExplosionFX alloc] initAt:object.position withTimeToLive:GAME_SECONDS(0.5) andTemplateIdx:objCode]];
							[WCGlobals.globalsManager.theEffects addEffect:[[WCImplosionFX alloc] initAt:object.position withTimeToLive:GAME_SECONDS(0.5) andTemplateIdx:0-objCode]];
							
							[render removeObject:object];
							
							state = DEMO_EXPLODE_OBJECT;
						}
					}
				}
			}
			break;
			
		case DEMO_STATE_HOLD:
			if(!holdTimer--)
				return NO;
			break;
	}
	
	if(!(frameCounter % 12))
	{
		if(++font >= WCCOLOR_NUM_COLORS)
			font = 0;
	}
	
	[WCGlobals.globalsManager.theEffects run:frameCounter];

	for(WCLabel *aLabel in renderLabels)
	{
		[aLabel render:font];
	}

	for(WCDAISprite *aSprite in render)
	{
		if(1 == aSprite.entryEffect.timeToLive)
			aSprite.entryEffect = Nil;
		
		if(!aSprite.entryEffect)
		{
			if(!(frameCounter % 2))
			{
				if(DB_PLAYER == [aSprite isA] || DB_MUTANT == [aSprite isA] || DB_POD == [aSprite isA])
				{
					if(++aSprite.animFrame >= aSprite.currAnim.numFrames)
						aSprite.animFrame = 0;
					[aSprite setFrameInCurrAnim:aSprite.animFrame];
				}
				else if(DB_BOMBER == [aSprite isA])
				{
					aSprite.animFrame += 4;
					if(aSprite.animFrame >= aSprite.currAnim.numFrames)
						aSprite.animFrame = 0;
					[aSprite setFrameInCurrAnim:aSprite.animFrame];
				}
			}
			
			[WCSpriteManager renderSprite:aSprite onLayer:RENDER_LAYER_AI withCopy:NO];
				
		}
	}
	
	return YES;
}

@end
