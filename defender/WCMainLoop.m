//
//  WCMainLoop.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCMainLoop.h"
#import "WCGlobals.h"
#import "WCSpriteManager.h"
#import "WCInputManager.h"
#import "WCSoundManager.h"
#import "WCView.h"
#import "WCFrontEnd.h"
#import "WCPrefs.h"
#import "WCBackground.h"
#import "WCEffects.h"
#import "WCExplosionFX.h"
#import "WCScoreFX.h"
#import "WCTextFX.h"
#import "WCAIs.h"
#import	"WCAISprite.h"
#import "WCLander.h"
#import "WCMutant.h"
#import "WCBomber.h"
#import "WCHuman.h"
#import "WCBullet.h"
#import "WCPlayer.h"
#import "WCLaser.h"

/*---------------------------------------------------------------------------*/
enum
{
	GAMESTATE_PREFRONTEND,
	GAMESTATE_FRONTEND,
	GAMESTATE_INIT_NEW_LEVEL,
	GAMESTATE_INIT_LEVEL,
	GAMESTATE_PLAYING,
	GAMESTATE_LEVEL_CLEAR_HOLD,
	GAMESTATE_LEVEL_STATS,
	GAMESTATE_PLAYER_DIE,
	GAMESTATE_NEXT_PLAYER,
	GAMESTATE_GAME_OVER,
	GAMESTATE_ENTER_INITIALS,
};

#define PLAYER_HYPER_SURVIVE		66

#define NUMBER_OF_HUMANS			10

#define STATS_REVEAL_HUMANS_SPEED	GAME_SECONDS(1.0/8)
#define STATS_REVEAL_HOLD_STATS		GAME_SECONDS(2.5)

#define INITIALS_HOLD_INACTIVE		GAME_SECONDS(10.0)
#define INITIALS_BLINK_RATE			GAME_SECONDS(0.5)
#define INITIALS_KEY_REPEAT_RATE	GAME_SECONDS(0.15)

#define FONT_LETTER_A				17

const char fontChars[] = " !.\'0123456789:=?ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const UInt32 numFontChars = sizeof(fontChars) / sizeof(fontChars[0]) - 1; // Trailing zero

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCMainLoop

@synthesize theView;
@synthesize viewSize;
@synthesize frameCounter;
@synthesize gameState;
@synthesize theFrontEnd;
@synthesize thePrefs;
@synthesize goTimer;
@synthesize showHumans;
@synthesize cursorPos;
@synthesize fontPos;
@synthesize keyHeld;
@synthesize repeatRate;
@synthesize blinkTimer;
@synthesize blinkOff;
@synthesize prePrefsHudState;

/*---------------------------------------------------------------------------*/
- (id)init:(WCView *)aView
{
	if (self = [super init])
	{
		theView = aView;
		viewSize = [theView frame].size;
		gameState = GAMESTATE_PREFRONTEND;
		frameCounter = 0;
	}
	return self;
}

/*---------------------------------------------------------------------------*/
- (BOOL)runPlay
{
	BOOL playerAlive = YES;
	
	if(!WCGlobals.globalsManager.numHumans && WCGlobals.globalsManager.groundOkay)
	{
		[WCGlobals.globalsManager.theBackground blowupGround];
		[WCGlobals.globalsManager.theAIs landersToMutants];
		[WCGlobals.globalsManager.theAIs processFixupList];
	}
	
	// Run the player
	[WCGlobals.globalsManager.thePlayer run:frameCounter];

	// Based on player movement, update the "background" positions
	CGFloat fw = WCGlobals.globalsManager.fieldSize.width;
	NSPoint drawPoint = WCGlobals.globalsManager.drawPoint;
	drawPoint.x += WCGlobals.globalsManager.velocity;
	if(drawPoint.x < 0.0)
		drawPoint.x += fw;
	else if(drawPoint.x >= fw)
		drawPoint.x -= fw;
	WCGlobals.globalsManager.drawPoint = drawPoint;
	
	// Now run the AI
	[WCGlobals.globalsManager.theAIs run:frameCounter];
	
	// Resolve collisions
	NSRect playerRect = WCGlobals.globalsManager.thePlayer.colRect;
	BOOL laserHit = NO;
	for(WCAISprite *anAi in WCGlobals.globalsManager.theAIs.aiList)
	{
		if(anAi.entryEffect)
			continue;
		
		UInt32 AiisA = [anAi isA];
		NSRect aiRect = anAi.colRect;
		if(NSIntersectsRect(playerRect, aiRect))
		{
			if(AiisA == DB_HUMAN)
			{
				if(HUMAN_STATE_FALLING == anAi.state)
				{
					[(WCHuman*)anAi addHost:WCGlobals.globalsManager.thePlayer];
					[WCGlobals.globalsManager.thePlayer addCargo:anAi];

					WCGlobals.globalsManager.score += GAME_SCORE_SAVE_HUMAN;
					[WCSoundManager playSound:DB_STRINGS[DB_HUMANCATCH]];

					aiRect.origin.x -= 48.0 + WCGlobals.globalsManager.drawPoint.x;
					[WCGlobals.globalsManager.theEffects addEffect:[[WCScoreFX alloc] initAt:aiRect.origin withTimeToLive:GAME_SECONDS(1.5) andScore:GAME_SCORE_SAVE_HUMAN]];
				}
			}
			else
			{
				playerAlive = NO;
				WCGlobals.globalsManager.velocity = 0.0;
				[WCGlobals.globalsManager.theEffects addEffect:[[WCExplosionFX alloc] initAt:WCGlobals.globalsManager.thePlayer.position withTimeToLive:GAME_SECONDS(1.5) andTemplateIdx:DB_PLAYER]];

				anAi.dead = YES;
				if([WCGlobals.globalsManager.thePlayer.theCargo count])
				{
					for(WCAISprite *cargo in WCGlobals.globalsManager.thePlayer.theCargo)
					{
						cargo.dead = YES;
					}
				}
			}
		}
		
		if(AiisA == DB_BULLET || AiisA == DB_BOMB)
			continue;
		
		for(WCLaser *aLaser in WCGlobals.globalsManager.thePlayer.lasers)
		{
			if(NSIntersectsRect(aiRect, aLaser.worldRect) || (aLaser.wrapsField && NSIntersectsRect(aiRect, aLaser.wrapRect)))
			{
				if(!aLaser.target || fabs(playerRect.origin.x - anAi.worldPosition.x) < fabs(playerRect.origin.x - aLaser.target.worldPosition.x))
				{
					aLaser.target = anAi;
					laserHit = YES;
				}
			}
		}
	}

	if(laserHit)
	{
		NSMutableArray *deadLasers = [NSMutableArray array];
		for(WCLaser *aLaser in WCGlobals.globalsManager.thePlayer.lasers)
		{
			if(aLaser.target)
			{
				aLaser.target.dead = YES;
				[WCGlobals.globalsManager.theAIs explodeAi:aLaser.target];
				[deadLasers addObject:aLaser];
			}
		}
		
		for(WCLaser *aLaser in deadLasers)
		{
			[WCGlobals.globalsManager.thePlayer.lasers removeObject:aLaser];
		}
		
		[deadLasers removeAllObjects];
	}

	[WCGlobals.globalsManager.theEffects run:frameCounter];
	
	return playerAlive;
}

/*---------------------------------------------------------------------------*/
- (BOOL)showStats
{
	[WCTextout printAtX:viewSize.width/2.0-(8.0*6.5*2.0) atY:viewSize.height*(4.0/6.0) theString:[NSString stringWithFormat:@"ATTACK WAVE %d",WCGlobals.globalsManager.aiLevel] atScale:3.0 inFont:WCCOLOR_CYAN orAttribs:Nil];
	[WCTextout printAtX:viewSize.width/2.0-(8.0*4.5*2.0) atY:viewSize.height*(4.0/6.0)-32.0 theString:@"COMPLETED" atScale:3.0 inFont:WCCOLOR_CYAN orAttribs:Nil];
	[WCTextout printAtX:viewSize.width/2.0-(8.0*5.5*2.0) atY:viewSize.height*(2.5/6.0) theString:@"BONUS X 100" atScale:3.0 inFont:WCCOLOR_CYAN orAttribs:Nil];

	if(WCGlobals.globalsManager.numHumans)
	{
		for(int i = 0; i < showHumans; ++i)
		{
			WCSprite *aSprite = [WCSpriteManager makeSpriteFromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[DB_HUMAN]];
			aSprite.position = NSMakePoint(viewSize.width/2.0-(8.0*5.5*2.0)+i*8.0*SPRITE_SCALE, viewSize.height*(2.5/6.0)-32.0);
			aSprite.scale = NSMakePoint(SPRITE_SCALE, SPRITE_SCALE);
			[WCSpriteManager renderSprite:aSprite onLayer:RENDER_LAYER_TEXT withCopy:YES];
		}
	}
	
	if(!goTimer--)
	{
		if(WCGlobals.globalsManager.numHumans)
		{
			if(++showHumans > WCGlobals.globalsManager.numHumans)
			{
				showHumans = 0;
				return NO;
			}
			else
			{
				[WCGlobals.globalsManager addToScore:GAME_SCORE_HUMAN_SURVIVED];
				if(showHumans == WCGlobals.globalsManager.numHumans)
					goTimer = STATS_REVEAL_HOLD_STATS;
				else
					goTimer = STATS_REVEAL_HUMANS_SPEED;
			}
		}
		else
		{
			if(++showHumans > 1)
			{
				showHumans = 0;
				return NO;
			}
			goTimer = STATS_REVEAL_HOLD_STATS;
		}
	}

	return YES;
}

/*---------------------------------------------------------------------------*/
- (BOOL)getInitials
{
	UInt32 keyState = [WCInputManager inputManager].keyState;
	
	if(keyState)
		goTimer = INITIALS_HOLD_INACTIVE;

	if(keyState & keyHeld)
	{
		if(repeatRate)
		{
			keyState &= ~keyHeld;
			--repeatRate;
		}
		else
		{
			repeatRate = INITIALS_KEY_REPEAT_RATE;
		}
	}
	else
	{
		keyHeld = 0;
		repeatRate = INITIALS_KEY_REPEAT_RATE;
	}
	
	if(keyState & INPUT_UP)
	{
		keyHeld |= INPUT_UP;
		if(++fontPos >= numFontChars)
			fontPos = 0;
		else if(1 == fontPos)
			fontPos = FONT_LETTER_A;
		initials[cursorPos] = fontChars[fontPos];
	}
	else if(keyState & INPUT_DOWN)
	{
		keyHeld |= INPUT_DOWN;
		if(--fontPos < 0)
			fontPos = numFontChars-1;
		else if(fontPos < FONT_LETTER_A)
			fontPos = 0;
		
		initials[cursorPos] = fontChars[fontPos];
	}
	else if(keyState & INPUT_FIRE)
	{
		keyHeld |= INPUT_FIRE;
		fontPos = 0;

		if(++cursorPos > 2)
			return NO;
		
		initials[cursorPos] = fontChars[fontPos];
	}
	
	if(!blinkTimer--)
	{
		blinkOff = 1 - blinkOff;
		blinkTimer = INITIALS_BLINK_RATE;
	}

	UInt32 activePlayer = WCGlobals.globalsManager.activePlayer;

	[WCTextout printAtX:106 atY:viewSize.height/2.0+(5.0*8.0*SPRITE_SCALE) theString:[NSString stringWithFormat:@"PLAYER %s",activePlayer ? "TWO" : "ONE"] atScale:3.0 inFont:WCCOLOR_PURPLE+activePlayer orAttribs:Nil];
	[WCTextout printAtX:106.0 atY:viewSize.height/2.0+(3.0*8.0*SPRITE_SCALE) theString:@"YOU HAVE QUALIFIED FOR" atScale:3.0 inFont:WCCOLOR_PURPLE+activePlayer orAttribs:Nil];
	[WCTextout printAtX:106.0 atY:viewSize.height/2.0+(2.0*8.0*SPRITE_SCALE) theString:@"THE DEFENDER HALL OF FAME" atScale:3.0 inFont:WCCOLOR_PURPLE+activePlayer orAttribs:Nil];
	[WCTextout printAtX:106.0 atY:viewSize.height/2.0 theString:@"SELECT INITIALS WITH UP OR DOWN" atScale:3.0 inFont:WCCOLOR_PURPLE+activePlayer orAttribs:Nil];
	[WCTextout printAtX:106.0 atY:viewSize.height/2.0-(2.0*8.0*SPRITE_SCALE) theString:@"PRESS FIRE TO ENTER INITIAL" atScale:3.0 inFont:WCCOLOR_PURPLE+activePlayer orAttribs:Nil];
	for(int i=0; i < 3; ++i)
	{
		[WCTextout printAtX:360.0+i*10.0*3.0 atY:viewSize.height/2.0-(4.0*8.0*SPRITE_SCALE) theString:[NSString stringWithFormat:@"%c",initials[i]] atScale:3.0 inFont:WCCOLOR_PURPLE+activePlayer orAttribs:Nil];
	}
	
	WCSprite *aLine = [WCSpriteManager makeSpriteFromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[DB_COLORS]];
	aLine.scale = NSMakePoint(6.0*SPRITE_SCALE, 2.0*SPRITE_SCALE);
	[aLine setFrameInCurrAnim:WCCOLOR_PURPLE+activePlayer];
	
	for(int i=cursorPos+1;i<3;++i)
	{
		aLine.position = NSMakePoint(360.0+i*10.0*3.0, viewSize.height/2.0-(4.0*8.0*SPRITE_SCALE)-(8.0*3.0));
		[WCSpriteManager renderSprite:aLine onLayer:RENDER_LAYER_TEXT withCopy:YES];
	}
	
	if(blinkOff)
	{
		aLine.position = NSMakePoint(360.0+cursorPos*10.0*3.0, viewSize.height/2.0-(4.0*8.0*SPRITE_SCALE)-(8.0*3.0));
		[WCSpriteManager renderSprite:aLine onLayer:RENDER_LAYER_TEXT withCopy:YES];
	}
	
	return YES;
}

/*---------------------------------------------------------------------------*/
- (void)initialsToScores:(WCHighScore*)scoreTable
{
	int i;
	
	for(i=NUM_HIGH_SCORES-2; i>=0 ; --i)
	{
		if(scoreTable[i].score > WCGlobals.globalsManager.score)
			break;
	}
	
	for(int j=NUM_HIGH_SCORES-1; j>i; --j)
	{
		memcpy(&scoreTable[j], &scoreTable[j-1], sizeof(scoreTable[0]));
	}

	scoreTable[i+1].score = WCGlobals.globalsManager.score;
	memcpy(scoreTable[i+1].initials, initials, 3);
}
/*---------------------------------------------------------------------------*/
- (void)runPrefs
{
	if(!thePrefs)
	{
		prePrefsHudState = WCGlobals.globalsManager.renderHUD;
		WCGlobals.globalsManager.renderHUD = NO;
		thePrefs = [WCPrefs new];
	}
	
	if(![thePrefs run])
	{
		thePrefs = Nil;
		WCGlobals.globalsManager.prefsActive = NO;
		WCGlobals.globalsManager.renderHUD = prePrefsHudState;
	}
}

/*---------------------------------------------------------------------------*/
- (void)handleHyper
{
	// Draw the Ais
	for(WCAISprite *aSprite in WCGlobals.globalsManager.theAIs.aiList)
	{
		if(!aSprite.entryEffect)
		{
			if([WCGlobals WCPointInView:aSprite.worldPosition])
				[WCSpriteManager renderSprite:aSprite onLayer:RENDER_LAYER_AI withCopy:NO];
		}
		else
		{
			if(1 == aSprite.entryEffect.timeToLive)
				aSprite.entryEffect = Nil;
		}
	}

	// Draw effects
	[WCGlobals.globalsManager.theEffects run:frameCounter];
	
	// Wait for the entry effect to stop before play continues
	if(![WCGlobals.globalsManager.theEffects.effectsList count])
	{
		// See if player survives the warp
		if(arc4random_uniform(100) > PLAYER_HYPER_SURVIVE)
		{
			NSPoint worldPoint = WCGlobals.globalsManager.thePlayer.worldPosition;
			[WCBullet makeBulletAt:worldPoint aimingAt:worldPoint withVelocity:0.0];
		}
		
		WCGlobals.globalsManager.thePlayer.hyperActive = NO;
	}
}

/*---------------------------------------------------------------------------*/
- (void)gameTick
{
	switch(gameState)
	{
		case GAMESTATE_PREFRONTEND:
		{
			WCGlobals.globalsManager.renderHUD = NO;
			WCGlobals.globalsManager.renderVitals = NO;
			theFrontEnd = [WCFrontEnd new];
			gameState = GAMESTATE_FRONTEND;
		}
			break;
			
		case GAMESTATE_FRONTEND:
			if(![theFrontEnd run:frameCounter])
			{
				theFrontEnd = Nil;
				WCGlobals.globalsManager.renderHUD = YES;
				WCGlobals.globalsManager.renderVitals = YES;
				for(int i = 0; i < WCGlobals.globalsManager.numActivePlayers; ++i)
				{
					WCGlobals.globalsManager.activePlayer = i;
					WCGlobals.globalsManager.lives = 3;
					WCGlobals.globalsManager.smartBombs = 3;
					WCGlobals.globalsManager.score = 0;
					WCGlobals.globalsManager.aiLevel = 1;
					WCGlobals.globalsManager.groundOkay = YES;
					WCGlobals.globalsManager.numHumans = NUMBER_OF_HUMANS;
					[WCGlobals.globalsManager.theAIs setupEnemyNumbers];
				}
				[WCGlobals.globalsManager.theAIs resetAi];
				WCGlobals.globalsManager.activePlayer = 0;
				[WCSoundManager stopAllSounds];
				[WCSoundManager playSound:DB_STRINGS[DB_START]];
				gameState = GAMESTATE_INIT_LEVEL;
			}
			break;
			
		case GAMESTATE_INIT_NEW_LEVEL:
			[WCGlobals.globalsManager.thePlayer setup];
			[WCGlobals.globalsManager.theAIs setupEnemyNumbers];
			[WCGlobals.globalsManager.theAIs resetAi];
			gameState = GAMESTATE_PLAYING;
			break;
			
		case GAMESTATE_INIT_LEVEL:
			[WCGlobals.globalsManager.thePlayer setup];
			[WCGlobals.globalsManager.theAIs resetAi];
			if(WCGlobals.globalsManager.numActivePlayers > 1)
			{
				[WCGlobals.globalsManager.theEffects addEffect:[[WCTextFX alloc] initAt:NSMakePoint(WCGlobals.globalsManager.viewSize.width/2.0-5.0*(5.0*3.0)+2.0, WCGlobals.globalsManager.viewSize.height/2.0) withTimeToLive:GAME_SECONDS(2.0) string:[NSString stringWithFormat:@"PLAYER %s",WCGlobals.globalsManager.activePlayer ? "TWO" : "ONE"] andAttribs:Nil]];
			}
			gameState = GAMESTATE_PLAYING;
			break;
			
		case GAMESTATE_PLAYING:
			if([self runPlay])
			{
				if(!WCGlobals.globalsManager.totalEnemiesTiKill)
				{
					NSSound *thrustSound = [WCSoundManager findSound:DB_STRINGS[DB_THRUST]];
					[thrustSound stop];
					gameState = GAMESTATE_LEVEL_CLEAR_HOLD;
				}
			}
			else
			{
				NSSound *playerDie = [WCSoundManager findSound:DB_STRINGS[DB_PLAYERDIE]];
				[playerDie play];
				
				NSSound *thrustSound = [WCSoundManager findSound:DB_STRINGS[DB_THRUST]];
				[thrustSound stop];
				
				gameState = GAMESTATE_PLAYER_DIE;
			}
			break;
			
		case GAMESTATE_LEVEL_CLEAR_HOLD:
			[WCGlobals.globalsManager.thePlayer drawPlayerUsingEngineSprite:Nil andFrameCounter:frameCounter];
			[WCGlobals.globalsManager.theAIs run:frameCounter];
			[WCGlobals.globalsManager.theEffects run:frameCounter];
			if(![WCGlobals.globalsManager.theEffects.effectsList count])
			{
				gameState = GAMESTATE_LEVEL_STATS;
				goTimer = 0;
			}
			break;
			
		case GAMESTATE_LEVEL_STATS:
			if(![self showStats])
			{
				WCGlobals.globalsManager.aiLevel++;
				gameState = GAMESTATE_INIT_NEW_LEVEL;
			}
			break;
			
		case GAMESTATE_PLAYER_DIE:
			[WCGlobals.globalsManager.theAIs run:frameCounter];
			[WCGlobals.globalsManager.theEffects run:frameCounter];
			if(![WCGlobals.globalsManager.theEffects.effectsList count])
			{
				if(--WCGlobals.globalsManager.lives)
				{
					gameState = GAMESTATE_NEXT_PLAYER;
					// This unfortunate hack is to prevent the hud from drawing
					// one less player ship for one frame.  Just an ugly flash not
					// happening now
					goto next_player_now;
				}
				else
				{
					gameState = GAMESTATE_GAME_OVER;
					goTimer = GAME_SECONDS(3.0);
				}
			}
			break;
			
		case GAMESTATE_NEXT_PLAYER:
		next_player_now:
			for(int i = 0; i < WCGlobals.globalsManager.numActivePlayers; ++i)
			{
				[WCGlobals.globalsManager nextActivePlayer];
				if(WCGlobals.globalsManager.lives)
				{
					gameState = GAMESTATE_INIT_LEVEL;
					break;
				}
			}
			if(GAMESTATE_NEXT_PLAYER == gameState)
				gameState = GAMESTATE_PREFRONTEND;
			break;
			
		case GAMESTATE_GAME_OVER:
			if(!goTimer--)
			{
				if(WCGlobals.globalsManager.score > WCGlobals.globalsManager.todaysHighScores[NUM_HIGH_SCORES-1].score)
				{
					[WCSoundManager playSound:DB_STRINGS[DB_SCORETABLE]];
					goTimer = INITIALS_HOLD_INACTIVE;
					cursorPos = 0;
					fontPos = FONT_LETTER_A;
					initials[0] = 'A';
					initials[1] = initials[2] = ' ';
					keyHeld = 0;
					gameState = GAMESTATE_ENTER_INITIALS;
				}
				else
					gameState = GAMESTATE_NEXT_PLAYER;
			}
			else
			{
				CGFloat offset = 0.0;
				if(WCGlobals.globalsManager.numActivePlayers > 1)
				{
					offset = SPRITE_SCALE*8.0;
					[WCTextout printAtX:viewSize.width/2.0-(5.0*(5.0*3.0+2.0)) atY:viewSize.height/2.0+offset theString:[NSString stringWithFormat:@"PLAYER %s",WCGlobals.globalsManager.activePlayer ? "TWO" : "ONE"] atScale:3.0 inFont:WCCOLOR_RED orAttribs:Nil];
				}
				[WCTextout printAtX:viewSize.width/2.0-(4.5*(5.0*3.0+2.0)) atY:viewSize.height/2.0-offset theString:@"GAME OVER" atScale:3.0 inFont:WCCOLOR_RED orAttribs:Nil];
			}
			break;
			
		case GAMESTATE_ENTER_INITIALS:
			if(!goTimer--)
			{
				[self initialsToScores:WCGlobals.globalsManager.todaysHighScores];
				if(WCGlobals.globalsManager.score > WCGlobals.globalsManager.allTimeHighScores[NUM_HIGH_SCORES-1].score)
					[self initialsToScores:WCGlobals.globalsManager.allTimeHighScores];
				gameState = GAMESTATE_NEXT_PLAYER;
			}
			else
			{
				if(![self getInitials])
					goTimer = 0;
			}
			break;
	}
	
	++frameCounter;
}

/*---------------------------------------------------------------------------*/
- (void)mainLoop:(NSTimer *)timer
{
	if(WCGlobals.globalsManager.prefsActive)
		[self runPrefs];
	else if(WCGlobals.globalsManager.thePlayer.hyperActive)
		[self handleHyper];
	else
		[self gameTick];
	
	// Kick off a draw
	[theView setNeedsDisplay:YES];
}

@end
