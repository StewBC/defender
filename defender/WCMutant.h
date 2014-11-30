//
//  WCMutant.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCAISprite.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCMutant : WCAISprite

@property		UInt32	frame;
@property		UInt32	animTick;
@property		UInt32	shootTime;

- (id)init;
- (UInt32)isA;
- (void)run:(UInt32)frameCounter;

@end
