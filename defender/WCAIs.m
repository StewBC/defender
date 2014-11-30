//
//  WCAIs.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCAIs.h"
#import "WCGlobals.h"
#import "WCSpriteManager.h"
#import "WCSoundManager.h"
#import "WCBackground.h"
#import "WCEffects.h"
#import "WCExplosionFX.h"
#import "WCImplosionFX.h"
#import "WCHuman.h"
#import "WCLander.h"
#import "WCMutant.h"
#import "WCBaiter.h"
#import "WCBomber.h"
#import "WCPod.h"
#import "WCSwarmer.h"
#import "WCBullet.h"
#import "WCPlayer.h"

/*---------------------------------------------------------------------------*/
#define LANDER_FIRST_WAVE_CREATE_TIME	GAME_SECONDS(2)
#define NEXT_WAVE_CREATE_TIME	GAME_SECONDS(8)
#define LANDERS_PER_WAVE				5
#define LANDERS_MAX_WAVES				3

enum
{
	AISTATE_LEVEL_INIT,
	AISTATE_LEVEL_FLOW,
	AISTATE_LEVEL_DONE,
};

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCAIs

@synthesize aiList;
@synthesize humansList;
@synthesize fixupList;
@synthesize aiState;
@synthesize nextWaveTime;
@synthesize madeMutants;
@synthesize numLandersToSpawn;
@synthesize numLandersSpawned;
@synthesize lastKillTimer;

/*---------------------------------------------------------------------------*/
- (id)init
{
	if(self = [super init])
	{
		aiList = [NSMutableArray array];
		humansList = [NSMutableArray array];
		fixupList = [NSMutableArray array];
		aiState = AISTATE_LEVEL_INIT;
	}
	return self;
}

/*---------------------------------------------------------------------------*/
- (void)setupEnemyNumbers
{
	UInt32 aiLevel = MIN(6,WCGlobals.globalsManager.aiLevel);
	
	WCGlobals.globalsManager.numMutants = WCGlobals.globalsManager.groundOkay ? 0 : LANDERS_PER_WAVE * LANDERS_MAX_WAVES;
	WCGlobals.globalsManager.numLanders = LANDERS_PER_WAVE * LANDERS_MAX_WAVES - WCGlobals.globalsManager.numMutants;
	WCGlobals.globalsManager.numBombers = aiLevel > 1 ? aiLevel + 1 : 0;
	WCGlobals.globalsManager.numPods = aiLevel > 1 ? aiLevel - 1 : 0;
	WCGlobals.globalsManager.numSwarmers = 0;
	WCGlobals.globalsManager.totalEnemiesTiKill = WCGlobals.globalsManager.numMutants + WCGlobals.globalsManager.numLanders + WCGlobals.globalsManager.numBombers + WCGlobals.globalsManager.numPods;
}

/*---------------------------------------------------------------------------*
 * If called with setupEnemyNumbers, call after calling setupEnemyNumbers
 *---------------------------------------------------------------------------*/
- (void)resetAi
{
	[aiList removeAllObjects];
	[humansList removeAllObjects];
	[self resetKillTimer];
	
	aiState = AISTATE_LEVEL_INIT;
	numLandersSpawned = 0;
	numLandersToSpawn = WCGlobals.globalsManager.numLanders;
	madeMutants = NO;
	WCGlobals.globalsManager.hasScored = NO;
}

/*---------------------------------------------------------------------------*/
- (void)resetKillTimer
{
	lastKillTimer = GAME_SECONDS(8.0);
}


/*---------------------------------------------------------------------------*/
- (void)createHumans:(UInt32)number
{
	while(number--)
	{
		WCHuman *aHuman = [WCSpriteManager makeSpriteClass:[WCHuman class] fromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[DB_HUMAN]];
		if(aHuman)
		{
			UInt32 x = arc4random_uniform(WCGlobals.globalsManager.fieldSize.width - aHuman.srcRect.size.width*SPRITE_SCALE);
			UInt32 y = [WCGlobals.globalsManager.theBackground getGroundHeightAtX:x] - 2.0*aHuman.srcRect.size.height;
			aHuman.worldRect = NSMakeRect(x, y, aHuman.srcRect.size.width, aHuman.srcRect.size.height);
			aHuman.scale = NSMakePoint(arc4random_uniform(2) ? SPRITE_SCALE : -SPRITE_SCALE, SPRITE_SCALE);
			[aiList addObject:aHuman];
			[humansList addObject:aHuman];
		}
	}
}

/*---------------------------------------------------------------------------*/
- (BOOL)create:(UInt32)number ofClass:(Class)aClass forAnimIdx:(UInt32)animIdx
{
	BOOL needsAudio = NO;
	NSSize fieldSize = WCGlobals.globalsManager.fieldSize;
	NSRect playerRect = WCGlobals.globalsManager.thePlayer.colRect;
	playerRect.origin.x -= 2.0*playerRect.size.width;
	playerRect.size.width *= 5.0;
	if(WCGlobals.globalsManager.thePlayer.scale.x < 0.0)
		playerRect.origin.x -= fabs(WCGlobals.globalsManager.velocity) * 16.0;
	playerRect.size.width += fabs(WCGlobals.globalsManager.velocity) * 16.0;
	playerRect.origin.y -= 2.0*playerRect.size.height;
	playerRect.size.height *= 5.0;
	
	while(number--)
	{
		WCAISprite *anAi = [WCSpriteManager makeSpriteClass:aClass fromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[animIdx]];
		if(anAi)
		{
			do
			{
				UInt32 x = arc4random_uniform(fieldSize.width - anAi.srcRect.size.width*SPRITE_SCALE);
				UInt32 y = fieldSize.height - 2.0 * anAi.srcRect.size.height*SPRITE_SCALE;
				NSRect worldRect = NSMakeRect(x, y, anAi.srcRect.size.width, anAi.srcRect.size.height);
				if(!NSIntersectsRect(worldRect, playerRect))
				{
					BOOL inOther = NO;
					for(WCAISprite *aiSprite in WCGlobals.globalsManager.theAIs.aiList)
					{
						if(NSIntersectsRect(worldRect, aiSprite.colRect))
						{
							inOther = YES;
							break;
						}
					}
					if(!inOther)
					{
						anAi.worldRect = worldRect;
						break;
					}
				}
			} while(1);
			if([WCGlobals WCPointInView:anAi.worldPosition])
				needsAudio = YES;
			anAi.scale = NSMakePoint(SPRITE_SCALE, SPRITE_SCALE);
			NSPoint effectPoint = anAi.worldRect.origin;
			effectPoint.x -= WCGlobals.globalsManager.drawPoint.x;
			WCEffect *effect = [[WCImplosionFX alloc] initAt:effectPoint withTimeToLive:GAME_SECONDS(0.75) andTemplateIdx:animIdx];
			[WCGlobals.globalsManager.theEffects addEffect:effect];
			anAi.entryEffect = effect;

			[aiList addObject:anAi];
		}
	}
	return needsAudio;
}

/*---------------------------------------------------------------------------*/
- (void)create:(UInt32)number bombersForAnimIdx:(UInt32)animIdx
{
	NSSize fieldSize = WCGlobals.globalsManager.fieldSize;
	NSRect playerRect = WCGlobals.globalsManager.thePlayer.colRect;
	playerRect.origin.x -= 2.0*playerRect.size.width;
	playerRect.size.width *= 5.0;
	if(WCGlobals.globalsManager.thePlayer.scale.x < 0.0)
		playerRect.origin.x -= fabs(WCGlobals.globalsManager.velocity) * 16.0;
	playerRect.size.width += fabs(WCGlobals.globalsManager.velocity) * 16.0;
	playerRect.origin.y -= 2.0*playerRect.size.height;
	playerRect.size.height *= 5.0;

	CGFloat fsHalf = fieldSize.height/2.0;
	BOOL func = 1;
	CGFloat ampl = arc4random_uniform(fsHalf/3.0) + fsHalf/3.0;
	CGFloat wLength = arc4random_uniform(15)+2;
	NSPoint speed = NSMakePoint((arc4random_uniform(7) + 7.0) * (arc4random_uniform(2) ? -1.0 : 1.0), (arc4random_uniform(15) - 7.0)/ 10.0);
	UInt32 i = 1;
	NSPoint worldPoint;

	worldPoint.x = arc4random_uniform(fieldSize.width);
	worldPoint.y = arc4random_uniform(fsHalf) + fsHalf/2.0;
	
	while(number--)
	{
		WCBomber *aBomber = [WCSpriteManager makeSpriteClass:[WCBomber class] fromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[animIdx]];
		aBomber.worldRect = aBomber.srcRect;
		if(aBomber)
		{
			do
			{
				aBomber.worldPosition = worldPoint;
				worldPoint.y += aBomber.srcRect.size.height * 1.5 * i;
				worldPoint.x += aBomber.srcRect.size.width * 1.5 * i;
				[aBomber setupWithFunc:func waves:wLength andAmplitude:ampl];
				[aBomber move];
				if([WCGlobals WCPointInView:aBomber.worldPosition])
					worldPoint.x = arc4random_uniform(fieldSize.width);
				else
					break;
			}
			while(1);
			++i;
			func = 1 - func;
			
			aBomber.speed = speed;
			aBomber.scale = NSMakePoint(SPRITE_SCALE, SPRITE_SCALE);
			NSPoint effectPoint = aBomber.worldRect.origin;
			effectPoint.x -= WCGlobals.globalsManager.drawPoint.x;
			WCEffect *effect = [[WCImplosionFX alloc] initAt:effectPoint withTimeToLive:GAME_SECONDS(0.75) andTemplateIdx:animIdx];
			[WCGlobals.globalsManager.theEffects addEffect:effect];
			aBomber.entryEffect = effect;
			[aiList addObject:aBomber];
			
			if(!(number % 3))
			{
				speed = NSMakePoint((arc4random_uniform(7) + 7.0) * (arc4random_uniform(2) ? -1.0 : 1.0), (arc4random_uniform(15) - 7.0)/ 10.0);
				i = 1;
				
				worldPoint.x = arc4random_uniform(fieldSize.width);
				worldPoint.y = arc4random_uniform(fsHalf) + fsHalf/2.0;
			}
		}
	}
}


/*---------------------------------------------------------------------------*/
- (void)landersToMutants
{
	for(WCAISprite *anAi in WCGlobals.globalsManager.theAIs.aiList)
	{
		if([anAi isA] == DB_LANDER)
			[fixupList addObject:anAi];
	}
	
	if(numLandersSpawned < numLandersToSpawn)
	{
		UInt32 landersToSpawn = numLandersToSpawn - numLandersSpawned;
		[self create:landersToSpawn ofClass:[WCMutant class] forAnimIdx:DB_MUTANT];
		numLandersSpawned += landersToSpawn;
		WCGlobals.globalsManager.numMutants += landersToSpawn;
		WCGlobals.globalsManager.numLanders -= landersToSpawn;
	}

}

/*---------------------------------------------------------------------------*/
- (void)processFixupList
{
	for(WCAISprite *anAi in WCGlobals.globalsManager.theAIs.fixupList)
	{

		UInt32 AiisA = [anAi isA];
		if(anAi.dead)
		{
			[aiList removeObject:anAi];
			switch(AiisA)
			{
				case DB_BAITER:
				case DB_HUMAN:
				case DB_BOMB:
				case DB_BULLET:
					break;
					
				default:
					[self resetKillTimer];
					[WCGlobals.globalsManager addToScore:DB_SCORES[AiisA]];
					WCGlobals.globalsManager.totalEnemiesTiKill--;
					break;
					
			}
		}

		switch(AiisA)
		{
			case DB_HUMAN:
				[humansList removeObject:anAi];
				WCGlobals.globalsManager.numHumans--;
				break;
				
			case DB_LANDER:
				{
					if(!anAi.dead)
					{
						WCMutant *aMutant = [WCSpriteManager makeSpriteClass:[WCMutant class] fromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[DB_MUTANT]];
						aMutant.scale = anAi.scale;
						aMutant.worldRect = anAi.worldRect;
						aMutant.worldPosition = anAi.worldPosition;
						aMutant.shootTime = MUTANT_SHOOT_WINDOW;
						[WCGlobals.globalsManager.theAIs.aiList addObject:aMutant];
						[aiList removeObject:anAi];
						WCGlobals.globalsManager.numMutants++;
					}
					WCGlobals.globalsManager.numLanders--;
				}
				break;
				
			case DB_MUTANT:
				WCGlobals.globalsManager.numMutants--;
				break;
				
			case DB_BOMBER:
				WCGlobals.globalsManager.numBombers--;
				break;
				
			case DB_POD:
				{
					WCGlobals.globalsManager.numPods--;
					
					// in two-thirds of cases the smart bomb also kills the swarmers
					BOOL b = arc4random_uniform(100) < 67;
					if(WCGlobals.globalsManager.thePlayer.smartBombActive && b)
						break;
					
					for(int i=0; i< 8; ++i)
					{
						WCSwarmer *aSwarmer = [WCSpriteManager makeSpriteClass:[WCSwarmer class] fromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[DB_SWARMER]];
						aSwarmer.worldRect = aSwarmer.srcRect;
						aSwarmer.worldPosition = anAi.worldPosition;
						aSwarmer.scale = NSMakePoint(SPRITE_SCALE, SPRITE_SCALE);
						aSwarmer.speed = NSMakePoint(arc4random_uniform(20) - 10.0,arc4random_uniform(20) - 10.0);
						aSwarmer.shootTime = SWARMER_SHOOT_WINDOW;
						[aiList addObject:aSwarmer];
					}
					WCGlobals.globalsManager.numSwarmers += 8;
					WCGlobals.globalsManager.totalEnemiesTiKill += 8;
				}
				break;
				
			case DB_SWARMER:
				WCGlobals.globalsManager.numSwarmers--;
				break;
				
			case DB_BULLET:
				if(!anAi.dead)
					[aiList addObject:anAi];
				break;
				
			case DB_BOMB:
				if(!anAi.dead)
					[aiList addObject:anAi];
				break;
				
		}
	}
	[WCGlobals.globalsManager.theAIs.fixupList removeAllObjects];
}

/*---------------------------------------------------------------------------*/
- (void)explodeAi:(WCAISprite*)anAi
{
	int sdx = DB_LANDERDIE;
	UInt32 AiisA = [anAi isA];
	
	switch(AiisA)
	{
		case DB_HUMAN:
			{
				WCHuman *aHuman = (WCHuman *)anAi;
				[aHuman.theHost removeCargo:aHuman];
				[aHuman removeHost];
			}
			break;
			
		case DB_LANDER:
			{
				WCLander *aLander = (WCLander*)anAi;
				if(aLander.theCargo)
				{
					WCHuman *aHuman = (WCHuman*)aLander.theCargo;
					[aHuman removeHost];

					if(LANDER_STATE_HUMAN_CAPTURED == aLander.state)
						sdx = DB_HUMANFALL;
					[aLander removeCargo:aHuman];
				}
			}
			break;
			
		case DB_BOMBER:
			sdx = DB_BOMBERDIE;
			break;
	}
	
	if(!WCGlobals.globalsManager.thePlayer.smartBombActive)
		[WCSoundManager playSound:DB_STRINGS[sdx]];

	//	[WCGlobals.globalsManager.theEffects addEffect:[[WCExplosionFX alloc] initAt:anAi.position withTimeToLive:GAME_SECONDS(0.5) andTemplateIdx:AiisA]];
	[WCGlobals.globalsManager.theEffects addEffect:[[WCImplosionFX alloc] initAt:anAi.position withTimeToLive:GAME_SECONDS(0.3) andTemplateIdx:0-AiisA]];
}

/*---------------------------------------------------------------------------*/
- (void)run:(UInt32)frameCounter
{
	switch(aiState)
	{
		case AISTATE_LEVEL_INIT:
			[self createHumans:WCGlobals.globalsManager.numHumans];
			aiState = AISTATE_LEVEL_FLOW;
			nextWaveTime = LANDER_FIRST_WAVE_CREATE_TIME;
			break;
			
		case AISTATE_LEVEL_FLOW:
			{
				if(!nextWaveTime--)
				{
					BOOL needsAudio = NO;
					if(!madeMutants)
					{
						if(WCGlobals.globalsManager.numMutants)
							needsAudio |= [self create:WCGlobals.globalsManager.numMutants ofClass:[WCMutant class] forAnimIdx:DB_MUTANT];

						if(WCGlobals.globalsManager.numBombers)
							[self create:WCGlobals.globalsManager.numBombers bombersForAnimIdx:DB_BOMBER];

						if(WCGlobals.globalsManager.numPods)
							needsAudio |= [self create:WCGlobals.globalsManager.numPods ofClass:[WCPod class] forAnimIdx:DB_POD];

						if(WCGlobals.globalsManager.numSwarmers)
							needsAudio |= [self create:WCGlobals.globalsManager.numSwarmers ofClass:[WCSwarmer class] forAnimIdx:DB_SWARMER];

						madeMutants = YES;
					}

					if(numLandersSpawned < numLandersToSpawn)
					{
						UInt32 landersToSpawn = MIN(numLandersToSpawn - numLandersSpawned, LANDERS_PER_WAVE);
						needsAudio |= [self create:landersToSpawn ofClass:[WCLander class] forAnimIdx:DB_LANDER];
						numLandersSpawned += landersToSpawn;
						[self resetKillTimer];
					}

					if(needsAudio)
						[WCSoundManager playSound:DB_STRINGS[DB_INBOUND]];
					
					nextWaveTime = NEXT_WAVE_CREATE_TIME;
				}
				
				if(!lastKillTimer--)
				{
					[self create:1 ofClass:[WCBaiter class] forAnimIdx:DB_BAITER];
					WCBaiter *aBaiter = [aiList lastObject];
					NSPoint worldPos = WCGlobals.globalsManager.thePlayer.worldPosition;
					worldPos.x += WCGlobals.globalsManager.thePlayer.scale.x > 0.0 ? WCGlobals.globalsManager.viewSize.width / 2.0 : -WCGlobals.globalsManager.viewSize.width / 2.0;
					worldPos.y += WCGlobals.globalsManager.viewSize.height / 4.0;
					aBaiter.worldPosition = worldPos;
					[self resetKillTimer];
				}
			}
			break;
	}
	
	for(WCAISprite *aSprite in aiList)
	{
		if(!aSprite.entryEffect)
		{
			if(aSprite.dead)
			{
				[fixupList addObject:aSprite];
			}
			else
			{
				[aSprite run:frameCounter];
				
				if([WCGlobals WCPointInView:aSprite.worldPosition])
					[WCSpriteManager renderSprite:aSprite onLayer:RENDER_LAYER_AI withCopy:NO];
			}
		}
		else
		{
			if(1 == aSprite.entryEffect.timeToLive)
				aSprite.entryEffect = Nil;
		}
	}

	[self processFixupList];
}

@end
