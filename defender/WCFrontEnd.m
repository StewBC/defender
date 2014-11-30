//
//  WCFrontEnd.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-10.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCFrontEnd.h"
#import "WCGlobals.h"
#import "WCSpriteManager.h"
#import "WCInputManager.h"
#import "WCSoundManager.h"
#import "WCTextout.h"
#import "WCWessels.h"
#import "WCDemo.h"
#import "WCEffects.h"
#import "WCImplosionFX.h"

/*---------------------------------------------------------------------------*/
enum
{
	FE_STATE_PRE_COPYRIGHT,
	FE_STATE_COPYRIGHT,
	FE_STATE_SCORES_INIT,
	FE_STATE_SCORES,
	FE_STATE_PRE_DEMO,
	FE_STATE_DEMO,
	FE_STATE_CONFIG,
};

#define COPYRIGHT_FONT_SCALE	2.5

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCFrontEnd

@synthesize state;
@synthesize logoSprite;
@synthesize wessels;
@synthesize theDemo;
@synthesize logoEffect;
@synthesize logoFrame;
@synthesize nextState;
@synthesize font;

/*---------------------------------------------------------------------------*/
- (id)init
{
	if(self = [super init])
	{
		NSSize viewSize = WCGlobals.globalsManager.viewSize;
		
		wessels = [WCSpriteManager makeSpriteClass:[WCWessels class] fromImage:DB_STRINGS[DB_WESSELS_PNG] forAnim:DB_STRINGS[DB_WESSELS]];
		[wessels setup];
		wessels.position = NSMakePoint(viewSize.width/2.0, viewSize.height*(14.5/17.0));
		wessels.scale = NSMakePoint(WESSELS_SIZE, WESSELS_SIZE);
		
		logoSprite = [WCSpriteManager makeSpriteFromImage:DB_STRINGS[DB_LOGO_PNG] forAnim:DB_STRINGS[DB_COLORS]];
		logoSprite.position = NSMakePoint(viewSize.width/2.0, viewSize.height*(6.55/17.0));
		logoSprite.scale = NSMakePoint(2.0, 2.0);
		
		if(WCGlobals.globalsManager.numActivePlayers)
			state = FE_STATE_SCORES_INIT;
		else
			state = FE_STATE_PRE_COPYRIGHT;
	}
	return self;
}

/*---------------------------------------------------------------------------*/
- (BOOL)run:(UInt32)frameCounter
{
	UInt32 keyState = [WCInputManager inputManager].keyState;
	
	NSSize viewSize = WCGlobals.globalsManager.viewSize;
	switch(state)
	{
		case FE_STATE_PRE_COPYRIGHT:
			wessels.state = WESSELS_START;
			[WCSoundManager playSound:DB_STRINGS[DB_WESSELS]];
			nextState = GAME_SECONDS(16.0);
			logoSprite.position = NSMakePoint(viewSize.width/2.0, viewSize.height*(6.55/17.0));
			[WCGlobals.globalsManager.theEffects addEffect:[[WCImplosionFX alloc] initAt:logoSprite.position withTimeToLive:GAME_SECONDS(1.5) andTemplateIdx:DB_LOGO_PNG]];
			state = FE_STATE_COPYRIGHT;
			break;
			
		case FE_STATE_COPYRIGHT:
			[wessels run:frameCounter];
			if(WESSELS_HOLD == wessels.state)
			{
				if(!(frameCounter % (UInt32)GAME_SECONDS(0.5)))
					font = arc4random_uniform(WCCOLOR_NUM_COLORS);

				if([WCGlobals.globalsManager.theEffects.effectsList count])
					[WCGlobals.globalsManager.theEffects run:frameCounter];
				else
					[WCSpriteManager renderSprite:logoSprite onLayer:RENDER_LAYER_TEXT withCopy:NO];
				
				[logoSprite setFrameInCurrAnim:arc4random_uniform(logoSprite.currAnim.numFrames)];
				[WCTextout printAtX:viewSize.width/2.0-(7.5*7.0*2.0) atY:viewSize.height*(12.5/17.0) theString:@"CONSULTING LTD." atScale:COPYRIGHT_FONT_SCALE inFont:font orAttribs:Nil];
				[WCTextout printAtX:viewSize.width/2.0-(4.0*7.0*2.0) atY:viewSize.height*(11.0/17.0) theString:@"PRESENTS" atScale:COPYRIGHT_FONT_SCALE inFont:font orAttribs:Nil];
				[WCTextout printAtX:viewSize.width/2.0-(19.0*7.0*2.0) atY:viewSize.height*(2.5/17.0) theString:@"THE ORIGINAL GAME IS COPYRIGHT 1980" atScale:COPYRIGHT_FONT_SCALE inFont:font orAttribs:Nil];
				[WCTextout printAtX:viewSize.width/2.0-(22.25*7.0*2.0) atY:viewSize.height*(1.5/17.0) theString:@"THIS VERSION IN HOMAGE BY S. WESSELS 2014" atScale:COPYRIGHT_FONT_SCALE inFont:font orAttribs:Nil];
			}
			
			if(!nextState)
				state = FE_STATE_SCORES_INIT;
			break;
			
		case FE_STATE_SCORES_INIT:
			logoSprite.position = NSMakePoint(viewSize.width/2.0, viewSize.height*(14.5/17.0));
			[logoSprite setFrameInCurrAnim:logoSprite.currAnim.numFrames-1];
			nextState = GAME_SECONDS(10.0);
			state = FE_STATE_SCORES;
			// Fall through intentionally
			
		case FE_STATE_SCORES:
			{
				if(!(frameCounter % (UInt32)GAME_SECONDS(0.5)))
					font = arc4random_uniform(WCCOLOR_NUM_COLORS);

				if(WCGlobals.globalsManager.numActivePlayers)
				{
					[WCTextout printAtX:0 atY:WCGlobals.globalsManager.viewSize.height-64.0 theString:[NSString stringWithFormat:@"%10d",[WCGlobals.globalsManager theScore:0]] atScale:3.0 inFont:font orAttribs:Nil];
				}
				if(WCGlobals.globalsManager.numActivePlayers > 1)
				{
					[WCTextout printAtX:WCGlobals.globalsManager.viewSize.width-162.0 atY:WCGlobals.globalsManager.viewSize.height-64.0 theString:[NSString stringWithFormat:@"%d",[WCGlobals.globalsManager theScore:1]] atScale:3.0 inFont:font orAttribs:Nil];
				}

				[WCSpriteManager renderSprite:logoSprite onLayer:RENDER_LAYER_TEXT withCopy:NO];
				
				[WCTextout printAtX:viewSize.width/2.0-(8.0*5.2*2.0) atY:logoSprite.position.y-52.0 theString:@"HALL OF FAME" atScale:2.5 inFont:font orAttribs:nil];
				[WCTextout printAtX:viewSize.width/3.0-(8.0*2.5*2.0) atY:logoSprite.position.y-96.0 theString:@"TODAYS" atScale:2.5 inFont:font orAttribs:nil];
				[WCTextout printAtX:viewSize.width/3.0-(8.0*3.5*2.0) atY:logoSprite.position.y-120.0 theString:@"GREATEST" atScale:2.5 inFont:font orAttribs:nil];
				[WCTextout printAtX:viewSize.width*(2.0/3)-(8.0*3.5*2.0) atY:logoSprite.position.y-96.0 theString:@"ALL TIME" atScale:2.5 inFont:font orAttribs:nil];
				[WCTextout printAtX:viewSize.width*(2.0/3)-(8.0*3.5*2.0) atY:logoSprite.position.y-120.0 theString:@"GREATEST" atScale:2.5 inFont:font orAttribs:nil];
				WCSprite *aLine = [WCSpriteManager makeSpriteFromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[DB_COLORS]];
				[aLine setFrameInCurrAnim:font];
				aLine.scale = NSMakePoint(130.0, 6.0);
				aLine.position = NSMakePoint(viewSize.width/3.0, logoSprite.position.y-138.0);
				[WCSpriteManager renderSprite:aLine onLayer:RENDER_LAYER_TEXT withCopy:YES];
				aLine.position = NSMakePoint(viewSize.width*(2.0/3.0), logoSprite.position.y-138.0);
				[WCSpriteManager renderSprite:aLine onLayer:RENDER_LAYER_TEXT withCopy:YES];
				for(int i=0; i < NUM_HIGH_SCORES; ++i)
				{
					[WCTextout printAtX:viewSize.width/3.0-(8.0*6.5*2.0) atY:logoSprite.position.y-168.0-(i*24.0) theString:[NSString stringWithFormat:@"%d %s", i+1, WCGlobals.globalsManager.todaysHighScores[i].initials] atScale:2.5 inFont:font orAttribs:nil];
					[WCTextout printAtX:viewSize.width/3.0-16.0 atY:logoSprite.position.y-168.0-(i*24.0) theString:[NSString stringWithFormat:@"%7d", WCGlobals.globalsManager.todaysHighScores[i].score] atScale:2.5 inFont:font orAttribs:nil];
					[WCTextout printAtX:viewSize.width*(2.0/3.0)-(8*6.5*2.0) atY:logoSprite.position.y-168.0-(i*24.0) theString:[NSString stringWithFormat:@"%d %s", i+1, WCGlobals.globalsManager.allTimeHighScores[i].initials] atScale:2.5 inFont:font orAttribs:nil];
					[WCTextout printAtX:viewSize.width*(2.0/3.0)-16.0 atY:logoSprite.position.y-168.0-(i*24.0) theString:[NSString stringWithFormat:@"%7d", WCGlobals.globalsManager.allTimeHighScores[i].score] atScale:2.5 inFont:font orAttribs:nil];
				}
				if(!nextState)
					state = FE_STATE_PRE_DEMO;
			}
			break;
			
		case FE_STATE_PRE_DEMO:
			WCGlobals.globalsManager.renderHUD = YES;
			state = FE_STATE_DEMO;
			theDemo = [WCDemo new];
			// fall through intentionally
			
		case FE_STATE_DEMO:
			if(![theDemo run:frameCounter])
			{
				theDemo = Nil;
				WCGlobals.globalsManager.renderHUD = NO;
				state = FE_STATE_PRE_COPYRIGHT;
			}
			break;
	}

	if((INPUT_1PLAYER & keyState) || (INPUT_2PLAYER & keyState))
	{
		if(INPUT_1PLAYER & keyState)
			WCGlobals.globalsManager.numActivePlayers = 1;
		else
			WCGlobals.globalsManager.numActivePlayers = 2;
		
		[WCGlobals.globalsManager.theEffects removeAllEffects];
		theDemo = Nil;
		
		return NO;
	}
	
	--nextState;

	return YES;
}

@end
