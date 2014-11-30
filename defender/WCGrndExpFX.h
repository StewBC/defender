//
//  WCGrndExpFX.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-18.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCEffects.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCGrndExpFX : WCEffect

@property (nonatomic, copy)		NSMutableArray	*particles;

- (void)fadeEffect;
- (void)animateAndDrawEffect:(UInt32)frameCounter;

@end
