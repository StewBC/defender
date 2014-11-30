//
//  WCBomb.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-18.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCAISprite.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCBomb : WCAISprite

@property		UInt32	frame;
@property		UInt32	timeTillAnim;
@property		UInt32	timeTillDie;

- (id)init;
- (UInt32)isA;
- (void)run:(UInt32)frameCounter;

@end
