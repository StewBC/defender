//
//  WCBomber.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-10.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCAISprite.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCBomber : WCAISprite

@property		UInt32	frame;
@property		UInt32	color;
@property		UInt32	timeTillAnim;
@property		BOOL	func;
@property		CGFloat	waves;
@property		CGFloat	amplitude;
@property		CGFloat	yOffset;

- (UInt32)isA;
- (NSRect)colRect;
- (void)move;
- (void)setupWithFunc:(BOOL)sinCos waves:(CGFloat)numWaves andAmplitude:(CGFloat)ampl;
- (void)run:(UInt32)frameCounter;

@end
