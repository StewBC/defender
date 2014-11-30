//
//  WCPlayer.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCAISprite.h"

/*---------------------------------------------------------------------------*/
enum
{
		PLAYER_X_EVAL_SPEED,	// Speed going between POS.. and CURR_DEST
		PLAYER_X_CURR_DEST,		// LEFT_DEST or RIGHT_DEST depending on dir
		PLAYER_X_LEFT_DEST,		// left pos on screen
		PLAYER_X_RIGHT_DEST,	// right pos on screen
		PLAYER_NUM_X,
};

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCPlayer : WCAISprite
{
	CGFloat		playerX[PLAYER_NUM_X];
}

- (UInt32)isA;
- (void)setup;
- (void)drawPlayerUsingEngineSprite:(WCSprite *)engineSprite andFrameCounter:(UInt32)frameCounter;
- (void)run:(UInt32)frameCounter;

@property (nonatomic, retain)	WCSprite		*thrustSprite;
@property (nonatomic, retain)	WCSprite		*idleSprite;
@property (nonatomic)			WCSprite		*renderSprite;
@property (nonatomic, copy)		NSMutableArray	*lasers;
@property (nonatomic, copy)		NSMutableArray	*theCargo;
@property						NSRect			worldRect;
@property						CGFloat			thrust;
@property						CGFloat			targetVelocity;
@property						UInt32			keyHeld;
@property						UInt32			playerFrame;
@property						int32_t			thrustFrame;
@property						UInt32			numThrustFrames;
@property						UInt32			laserColor;
@property (nonatomic, retain)	NSSound			*thrustSound;
@property						UInt32			thrustReset;
@property						BOOL			smartBombActive;
@property						BOOL			hyperActive;

@end
