//
//  WCPod.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-25.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCAISprite.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCPod : WCAISprite

@property		UInt32	frame;

- (UInt32)isA;
- (void)run:(UInt32)frameCounter;

@end
