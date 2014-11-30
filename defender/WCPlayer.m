//
//  WCPlayer.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCPlayer.h"
#import "WCGlobals.h"
#import "WCSpriteManager.h"
#import "WCInputManager.h"
#import "WCSoundManager.h"
#import "WCBackground.h"
#import "WCImplosionFX.h"
#import "WCScoreFX.h"
#import "WCAIs.h"
#import "WCHuman.h"
#import "WCBullet.h"
#import "WCLaser.h"

/*---------------------------------------------------------------------------*/
#define PLAYER_VERTICAL_SPEED					5.0
#define PLAYER_POSITION_ON_SCREEN				(1.0/4.0)
#define PLAYER_THRUST_EVAL						0.08
#define	PLAYER_IDLE_EVAL						0.04
#define PLAYER_VELOCITY_EVAL					0.06
#define PLAYER_FIRE_LASER_COLOR_CYCLE			4
#define PLAYER_SHIP_ANIM_SPEED					4
#define PLAYER_THRUST_ANIM_SPEED				2
#define PLAYER_SPEED							10.0

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCPlayer

@synthesize thrustSprite;
@synthesize idleSprite;
@synthesize renderSprite;
@synthesize lasers;
@synthesize theCargo;
@synthesize thrust;
@synthesize targetVelocity;
@synthesize keyHeld;
@synthesize playerFrame;
@synthesize thrustFrame;
@synthesize numThrustFrames;
@synthesize laserColor;
@synthesize thrustSound;
@synthesize thrustReset;
@synthesize smartBombActive;
@synthesize hyperActive;

/*---------------------------------------------------------------------------*/
- (UInt32)isA
{
	return DB_PLAYER;
}

/*---------------------------------------------------------------------------*/
- (void)addCargo:(WCAISprite *)cargo
{
	[theCargo addObject:cargo];
}

/*---------------------------------------------------------------------------*/
- (void)removeCargo:(WCAISprite*)cargo
{
	[theCargo removeObject:cargo];
}

/*---------------------------------------------------------------------------*/
- (void)setup
{
	NSSize viewSize = WCGlobals.globalsManager.viewSize;
	
	playerX[PLAYER_X_CURR_DEST] = playerX[PLAYER_X_LEFT_DEST] = viewSize.width * PLAYER_POSITION_ON_SCREEN;
	playerX[PLAYER_X_EVAL_SPEED] = 0.0;
	playerX[PLAYER_X_RIGHT_DEST] = viewSize.width * (1.0-PLAYER_POSITION_ON_SCREEN);
	
	self.position = NSMakePoint(playerX[PLAYER_X_CURR_DEST], viewSize.height/2.0);
	self.scale = NSMakePoint(SPRITE_SCALE, SPRITE_SCALE);
	self.worldRect = NSMakeRect(0.0, 0.0, self.srcRect.size.width, self.srcRect.size.height);

	thrustSprite = [WCSpriteManager makeSpriteFromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[DB_THRUST]];
	thrustSprite.position = NSMakePoint(self.position.x, self.position.y);
	thrustSprite.pivot = NSMakePoint(thrustSprite.srcRect.size.width+self.pivot.x, thrustSprite.pivot.y);
	thrustSprite.scale = NSMakePoint(SPRITE_SCALE, SPRITE_SCALE);
	
	numThrustFrames = thrustSprite.currAnim.numFrames;
	
	idleSprite = [WCSpriteManager makeSpriteFromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[DB_IDLE]];
	idleSprite.position = NSMakePoint(self.position.x, self.position.y);
	idleSprite.pivot = NSMakePoint(idleSprite.srcRect.size.width+self.pivot.x, idleSprite.pivot.y);
	idleSprite.scale = NSMakePoint(SPRITE_SCALE, SPRITE_SCALE);
	
	NSAssert( numThrustFrames == idleSprite.currAnim.numFrames, @"Thrust and idle animations don't have same # frames");
	
	lasers = [NSMutableArray array];
	theCargo = [NSMutableArray array];
	thrustSound = [WCSoundManager findSound:DB_STRINGS[DB_THRUST]];
	thrustSound.loops = YES;

	thrust = 0.0;
	targetVelocity = 0.0;
	keyHeld = 0;
	playerFrame = thrustFrame = 0;
	smartBombActive = NO;
	WCGlobals.globalsManager.velocity = 0.0;
	WCGlobals.globalsManager.drawPoint = NSZeroPoint;
}

/*---------------------------------------------------------------------------*/
- (void)drawPlayerUsingEngineSprite:(WCSprite *)engineSprite andFrameCounter:(UInt32)frameCounter
{
	if(Nil == engineSprite)
		engineSprite = idleSprite;
	
	if(!(frameCounter % PLAYER_SHIP_ANIM_SPEED))
	{
		if(++playerFrame == self.currAnim.numFrames)
			playerFrame = 0;
		[self setFrameInCurrAnim:playerFrame];
	}
	[WCSpriteManager renderSprite:self onLayer:RENDER_LAYER_PLAYER withCopy:NO];
	
	if(!(frameCounter % PLAYER_THRUST_ANIM_SPEED))
	{
		if(--thrustFrame < 0)
			thrustFrame = numThrustFrames - 1;
		[engineSprite setFrameInCurrAnim:thrustFrame];
	}
	
	renderSprite.position = self.position;
	[WCSpriteManager renderSprite:renderSprite onLayer:RENDER_LAYER_PLAYER withCopy:NO];
}

/*---------------------------------------------------------------------------*/
- (void)run:(UInt32)frameCounter
{
	UInt32 keyState = [WCInputManager inputManager].keyState;
	NSPoint aPlayerPos = self.position;

	smartBombActive = NO;

	if(keyState & INPUT_SMARTBOMB && !(keyHeld & INPUT_SMARTBOMB) && WCGlobals.globalsManager.smartBombs)
	{
		smartBombActive = YES;
		BOOL killed = NO;
		for(WCAISprite *anAi in WCGlobals.globalsManager.theAIs.aiList)
		{
			UInt32 AiisA = [anAi isA];

			if(AiisA == DB_HUMAN || AiisA == DB_BOMB || AiisA == DB_BULLET)
				continue;
				
			if([WCGlobals WCPointInView:anAi.worldPosition])
			{
				anAi.dead = YES;
				[WCGlobals.globalsManager.theAIs explodeAi:anAi];
				killed = YES;
			}
		}

		WCGlobals.globalsManager.smartBombs--;
		if(killed)
			[WCSoundManager playSound:DB_STRINGS[DB_LANDERDIE]];
	}
	
	if(keyState & INPUT_THRUST)
	{
		if(!thrustSound.isPlaying)
			[thrustSound play];
		thrustSound.volume = 1.0;

		targetVelocity = PLAYER_SPEED * self.scale.x;
		renderSprite = thrustSprite;
	}
	else
	{
		thrustSound.volume = 0.1;

		targetVelocity = 0.0;
		renderSprite = idleSprite;
	}
	
	if(!thrustReset--)
	{
		// This avoids a click sound when the loop retarts - Loop manually for 30 fps
		// but start a little into the sample
		[thrustSound setCurrentTime:0.05];
		thrustReset = GAME_SECONDS(4.0);
	}

	if(keyState & INPUT_UP)
	{
		if(aPlayerPos.y + self.pivot.x + PLAYER_VERTICAL_SPEED < WCGlobals.globalsManager.fieldSize.height)
			aPlayerPos.y += PLAYER_VERTICAL_SPEED;
	}
	else if(keyState & INPUT_DOWN)
	{
		if(self.position.y - PLAYER_VERTICAL_SPEED > self.pivot.x)
			aPlayerPos.y -= PLAYER_VERTICAL_SPEED;
	}
	
	if(keyState & INPUT_FLIP && !(keyHeld & INPUT_FLIP))
	{
			CGFloat direction = -self.scale.x;
			self.scale = NSMakePoint(direction, self.scale.y);
			thrustSprite.scale = NSMakePoint(direction, thrustSprite.scale.y);
			idleSprite.scale = NSMakePoint(direction, idleSprite.scale.y);
			playerX[PLAYER_X_CURR_DEST] = playerX[direction > 0.0 ? PLAYER_X_LEFT_DEST : PLAYER_X_RIGHT_DEST];
	}

	if(keyState & INPUT_HYPER && !(keyHeld & INPUT_HYPER))
	{
		NSPoint drawPoint = NSMakePoint(arc4random_uniform(WCGlobals.globalsManager.fieldSize.width), 0.0);
		WCGlobals.globalsManager.drawPoint = drawPoint;
		WCGlobals.globalsManager.velocity = playerX[PLAYER_X_EVAL_SPEED] = thrust = 0.0;
		playerX[PLAYER_X_CURR_DEST] = playerX[self.scale.x > 0.0 ? PLAYER_X_LEFT_DEST : PLAYER_X_RIGHT_DEST];
		
		CGFloat h = srcRect.size.height * SPRITE_SCALE;
		aPlayerPos = NSMakePoint(playerX[PLAYER_X_CURR_DEST], arc4random_uniform(WCGlobals.globalsManager.fieldSize.height-2.0*h)+h);
		[WCGlobals.globalsManager.theEffects addEffect:[[WCImplosionFX alloc] initAt:aPlayerPos withTimeToLive:self.scale.x < 0.0 ? -GAME_SECONDS(0.5) : GAME_SECONDS(0.5) andTemplateIdx:DB_PLAYER]];
		hyperActive = YES;
	}

	// If a flip is in progress, self.posiiton needs to go to playerX[PLAYER_X_CURR_DEST]
	CGFloat pos_x = aPlayerPos.x;
	[WCGlobals evalCubicCurrPos:&pos_x currSpeed:&playerX[PLAYER_X_EVAL_SPEED] destPos:playerX[PLAYER_X_CURR_DEST] timeStep:PLAYER_VELOCITY_EVAL];

	// Calculate the delta for the move
	pos_x -= aPlayerPos.x;
	// apply it to the world so the ground moves
	NSPoint drawPoint = WCGlobals.globalsManager.drawPoint;
	drawPoint.x -= pos_x;
	// The [0..fw] check happens right after player runs so don't fret about over/underflow
	WCGlobals.globalsManager.drawPoint = drawPoint;
	// also move the player on screen (so the player moves across the screen locked to the ground)
	aPlayerPos.x += pos_x;
	
	// Now calculate any other ground moement based on thrust
	CGFloat timeStep = (keyState & INPUT_THRUST) ? PLAYER_THRUST_EVAL : PLAYER_IDLE_EVAL;
	CGFloat velocity = WCGlobals.globalsManager.velocity;
	[WCGlobals evalCubicCurrPos:&velocity currSpeed:&thrust destPos:targetVelocity timeStep:timeStep];
	WCGlobals.globalsManager.velocity = velocity;
	self.worldPosition = NSMakePoint(aPlayerPos.x + drawPoint.x + velocity, aPlayerPos.y + drawPoint.y);
	// Set this after the worldPosition as setting the worldPosition alters posiiton
	self.position = aPlayerPos;

	// Only after final position is determined, make lasers
	if(keyState & INPUT_FIRE && !(keyHeld & INPUT_FIRE))
	{
		if(++laserColor >= PLAYER_FIRE_LASER_COLOR_CYCLE*(WCCOLOR_NUM_COLORS-1))
			laserColor = WCCOLOR_0;
		
		// Start the laser sound into the sample to nake it work
		NSSound *laser = [WCSoundManager findSound:DB_STRINGS[DB_LASER]];
		[laser setCurrentTime:0.01];
		[laser play];
		WCSoundManager.soundManager.playing = laser;
		WCLaser *aLaser = [[WCLaser alloc] initWithPosition:aPlayerPos direction:self.scale.x andColorIndex:laserColor/PLAYER_FIRE_LASER_COLOR_CYCLE];
		[lasers addObject:aLaser];
	}

	if([theCargo count])
	{
		NSPoint cargoPoint = ((WCAISprite*)[theCargo firstObject]).worldPosition;
		if([WCGlobals.globalsManager.theBackground getGroundHeightAtX:cargoPoint.x] > cargoPoint.y)
		{
			for(WCHuman *aHuman in theCargo)
			{
				[aHuman removeHost];
				WCGlobals.globalsManager.score += GAME_SCORE_SAVE_HUMAN;
			}
			[theCargo removeAllObjects];
			cargoPoint.x -= 48.0 + WCGlobals.globalsManager.drawPoint.x;
			[WCSoundManager playSound:DB_STRINGS[DB_WESSELS]];
			[WCGlobals.globalsManager.theEffects addEffect:[[WCScoreFX alloc] initAt:cargoPoint withTimeToLive:GAME_SECONDS(1.5) andScore:GAME_SCORE_SAVE_HUMAN]];
		}
		else
		{
			NSPoint worldPoint = self.worldPosition;
			worldPoint.y -= self.colRect.size.height * 1.5;
			for(WCHuman *aHuman in theCargo)
			{
				aHuman.worldPosition = worldPoint;
			}
		}
	}

	if(!hyperActive)
		[self drawPlayerUsingEngineSprite:renderSprite andFrameCounter:frameCounter];
	
	// Run the lasers and add the dead ones to a remove array
	NSMutableArray *removeArray = [NSMutableArray array];
	for(WCLaser *aLaser in lasers)
	{
		// Because I didn't put lasers in world space, they need to be removed if you hyperspace
		if(![aLaser run] || hyperActive)
		   [removeArray addObject:aLaser];
	}
	
	// Now remove the dead lasers from the laser array.  This doesn't screw up the iterator
	for(WCLaser *aLaser in removeArray)
	{
		[lasers removeObject:aLaser];
	}
	[removeArray removeAllObjects];
	
	keyHeld = keyState;
}

@end
