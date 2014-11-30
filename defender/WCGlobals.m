//
//  WCGlobals.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCGlobals.h"
#import "WCAIs.h"
#import "WCBackground.h"
#import "WCEffects.h"
#import "WCPlayer.h"

/*---------------------------------------------------------------------------*/

NSString *DB_STRINGS[] =
{
	@"logo.png",
	@"player",
	@"lander",
	@"mutant",
	@"baiter",
	@"bomber",
	@"pod",
	@"swarmer",
	@"human",
	@"bomb",
	@"bomb",		// DB_BULLET is the same
	@"thrust",
	@"idle",
	@"lasers",
	@"colors",
	@"smartbomb",
	@"sprites.png",
	@"font.png",
	@"wessels.png",
	@"wessels",
	@"start",
	@"inbound",
	@"laser",
	@"landerdie",
	@"bomberdie",
	@"playerdie",
	@"humanfall",
	@"humancatch",
	@"humanpickup",
	@"landershoot",
	@"mutantshoot",
	@"swarmershoot",
	@"worldexplode",
	@"scoretable",
	@"inputconfig",
};

const UInt32 DB_SCORES[] =
{
	0,
	0,
	150,
	150,
	250,
	200,
	1000,
	150,
};

WCHighScore	g_ths[NUM_HIGH_SCORES] =
{
	{21270, "DRJ"},
	{18315, "SAM"},
	{15920, "LED"},
	{14285, "PGD"},
	{12520, "CRB"},
	{11035, "MRS"},
	{ 8265, "SSR"},
	{ 6010, "TMH"}
};

WCHighScore	g_bhs[NUM_HIGH_SCORES] =
{
	{21270, "DRJ"},
	{18315, "SAM"},
	{15920, "LED"},
	{14285, "PGD"},
	{12520, "CRB"},
	{11035, "MRS"},
	{ 8265, "SSR"},
	{ 6010, "TMH"}
};

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCGlobals

@synthesize theBackground;
@synthesize theAIs;
@synthesize thePlayer;
@synthesize theEffects;
@synthesize fieldSize;
@synthesize velocity;
@synthesize renderHUD;
@synthesize renderVitals;
@synthesize numActivePlayers;
@synthesize activePlayer;
@synthesize hasScored;
@synthesize todaysHighScores;
@synthesize allTimeHighScores;
@synthesize viewRect;
@synthesize prefsActive;
@synthesize joystickScreen;

/*---------------------------------------------------------------------------*/
+ (WCGlobals*)globalsManager
{
	static WCGlobals *globalsManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{ globalsManager = [[self alloc] init]; });
	return globalsManager;
}

/*---------------------------------------------------------------------------*/
- (id)init
{
	if(self = [super init])
	{
		todaysHighScores = g_ths;
		allTimeHighScores = g_bhs;
	}
	return self;
}

/*---------------------------------------------------------------------------*/
- (void)makeObjects
{
	theAIs = [WCAIs new];
	theBackground = [WCBackground new];
	thePlayer = [WCSpriteManager makeSpriteClass:[WCPlayer class] fromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[DB_PLAYER]];
	theEffects = [WCEffects new];
}

/*---------------------------------------------------------------------------*/
- (NSPoint)drawPoint
{
	return viewRect.origin;
}

/*---------------------------------------------------------------------------*/
- (void)setDrawPoint:(NSPoint)aPoint
{
	viewRect.origin = aPoint;
}

/*---------------------------------------------------------------------------*/
- (NSSize)viewSize
{
	return viewRect.size;
}

/*---------------------------------------------------------------------------*/
- (void)setViewSize:(NSSize)aSize
{
	viewRect.size = aSize;
}

/*---------------------------------------------------------------------------*/
+ (BOOL)WCPointInView:(NSPoint)aPoint
{
	NSRect viewRect = WCGlobals.globalsManager.viewRect;
	
	if(NSPointInRect(aPoint, viewRect))
	{
		return YES;
	}
	else
	{
		CGFloat fw = WCGlobals.globalsManager.fieldSize.width;
		
		if(viewRect.origin.x < 0.0)
			viewRect.origin.x += fw;
		else if(NSMaxX(viewRect) > fw)
			viewRect.origin.x -= fw;
		else
			return NO;

		if(NSPointInRect(aPoint, viewRect))
			return YES;
	}
	
	return NO;
}

/*---------------------------------------------------------------------------*/
+ (void)evalCubicCurrPos:(CGFloat*)y0 currSpeed:(CGFloat*)m0 destPos:(CGFloat)y1 timeStep:(CGFloat)t
{
	CGFloat a, b, c, d, e;
	
	c = *m0;
	d = *y0;
	
	e = y1 - d;
	a = c - e - e;
	b = e + e + e - c - c;
	
	*y0 = ((((a * t + b) * t) + c) * t) + d;
	*m0 = ((((a + a + a) * t) + (b + b)) * t) + c;
}


/*---------------------------------------------------------------------------*/
- (UInt32)nextActivePlayer
{
	if(++activePlayer >= numActivePlayers)
		activePlayer = 0;
	
	return activePlayer;
}

/*---------------------------------------------------------------------------*/
- (UInt32)score
{
	return score[activePlayer];
}

/*---------------------------------------------------------------------------*/
- (void)setScore:(UInt32)aScore
{
	if(aScore)
	{
		hasScored = YES;
		UInt32 preScore = score[activePlayer] / GAME_SCORE_BONUS_SCORE;
		if(aScore/GAME_SCORE_BONUS_SCORE != preScore)
		{
			[self addToLives:1];
			[self addToSmartBombs:1];
		}
	}
	score[activePlayer] = aScore;
}

/*---------------------------------------------------------------------------*/
- (void)addToScore:(UInt32)aScore
{
	hasScored = YES;
	UInt32 preScore = score[activePlayer] / GAME_SCORE_BONUS_SCORE;
	score[activePlayer] += aScore;
	if(score[activePlayer]/GAME_SCORE_BONUS_SCORE != preScore)
	{
		[self addToLives:1];
		[self addToSmartBombs:1];
	}
}

/*---------------------------------------------------------------------------*/
- (UInt32)theScore:(UInt32)aPlayer
{
	return score[aPlayer];
}

/*---------------------------------------------------------------------------*/
- (UInt32)lives
{
	return lives[activePlayer];
}

/*---------------------------------------------------------------------------*/
- (void)setLives:(UInt32)aLives
{
	lives[activePlayer] = aLives;
}

/*---------------------------------------------------------------------------*/
- (void)addToLives:(UInt32)aLives;
{
	lives[activePlayer] += aLives;
}

/*---------------------------------------------------------------------------*/
- (UInt32)theLives:(UInt32)aPlayer
{
	return lives[aPlayer];
}

/*---------------------------------------------------------------------------*/
- (UInt32)smartBombs;
{
	return smartBombs[activePlayer];
}

/*---------------------------------------------------------------------------*/
- (void)setSmartBombs:(UInt32)aSmartBombs;
{
	smartBombs[activePlayer] = aSmartBombs;
}

/*---------------------------------------------------------------------------*/
- (void)addToSmartBombs:(UInt32)aSmartBombs;
{
	smartBombs[activePlayer] += aSmartBombs;
}

/*---------------------------------------------------------------------------*/
- (UInt32)theSmartBombs:(UInt32)aPlayer
{
	return smartBombs[aPlayer];
}

/*---------------------------------------------------------------------------*/
- (UInt32)numHumans
{
	return numHumans[activePlayer];
}

/*---------------------------------------------------------------------------*/
- (void)setNumHumans:(UInt32)aNumHumans
{
	numHumans[activePlayer] = aNumHumans;
}

/*---------------------------------------------------------------------------*/
- (UInt32)numLanders
{
	return numLanders[activePlayer];
}

/*---------------------------------------------------------------------------*/
- (void)setNumLanders:(UInt32)aNumLanders
{
	numLanders[activePlayer] = aNumLanders;
}

/*---------------------------------------------------------------------------*/
- (UInt32)numMutants
{
	return numMutants[activePlayer];
}

/*---------------------------------------------------------------------------*/
- (void)setNumMutants:(UInt32)aNumMutants
{
	numMutants[activePlayer] = aNumMutants;
}

/*---------------------------------------------------------------------------*/
- (UInt32)numBombers;
{
	return numBombers[activePlayer];
}

/*---------------------------------------------------------------------------*/
- (void)setNumBombers:(UInt32)aNumBombers;
{
	numBombers[activePlayer] = aNumBombers;
}

/*---------------------------------------------------------------------------*/
- (UInt32)numPods;
{
	return numPods[activePlayer];
}

/*---------------------------------------------------------------------------*/
- (void)setNumPods:(UInt32)aNumPods;
{
	numPods[activePlayer] = aNumPods;
}

/*---------------------------------------------------------------------------*/
- (UInt32)numSwarmers;
{
	return numSwarmers[activePlayer];
}

/*---------------------------------------------------------------------------*/
- (void)setNumSwarmers:(UInt32)aNumSwarmers;
{
	numSwarmers[activePlayer] = aNumSwarmers;
}

/*---------------------------------------------------------------------------*/
- (UInt32)totalEnemiesTiKill
{
	return totalEnemiesTiKill[activePlayer];
}

/*---------------------------------------------------------------------------*/
- (void)setTotalEnemiesTiKill:(UInt32)aNumTotalEnemiesTiKill
{
	totalEnemiesTiKill[activePlayer] = aNumTotalEnemiesTiKill;
}

/*---------------------------------------------------------------------------*/
- (UInt32)aiLevel
{
	return aiLevel[activePlayer];
}

/*---------------------------------------------------------------------------*/
- (void)setAiLevel:(UInt32)aLevel
{
	aiLevel[activePlayer] = aLevel;
}

/*---------------------------------------------------------------------------*/
- (BOOL)groundOkay
{
	return groundOkay[activePlayer];
}

/*---------------------------------------------------------------------------*/
- (void)setGroundOkay:(BOOL)aOkay
{
	groundOkay[activePlayer] = aOkay;
}

- (UInt32)prefItem:(UInt32)aScreen
{
	return prefItem[aScreen];
}

- (void)setPrefItem:(UInt32)anItem forScreen:(UInt32)aScreen
{
	prefItem[aScreen] = anItem;
}

@end
