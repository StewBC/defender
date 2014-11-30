//
//  WCBaiter.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-11.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCAISprite.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCBaiter : WCAISprite

@property		UInt32	frame;
@property		UInt32	shootTime;

- (UInt32)isA;
- (void)run:(UInt32)frameCounter;

@end
