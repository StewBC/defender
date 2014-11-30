//
//  WCAISprite.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCSpriteManager.h"

/*---------------------------------------------------------------------------*/
@class WCEffect;

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCAISprite : WCSprite

@property (nonatomic, retain)	WCEffect		*entryEffect;
@property						UInt32			state;
@property						NSRect			worldRect;
@property						NSPoint			speed;
@property						BOOL			dead;

- (UInt32)isA;
- (NSRect)colRect;
- (NSPoint)worldPosition;
- (void)setWorldPosition:(NSPoint)aPoint;
- (void)addCargo:(WCAISprite*)cargo;
- (void)removeCargo:(WCAISprite*)cargo;
- (void)run:(UInt32)frameCounter;

@end
