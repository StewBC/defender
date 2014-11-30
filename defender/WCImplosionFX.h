//
//  WCImplosionFX.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-14.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCEffects.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCImplosionFX : WCEffect

@property (nonatomic, copy)		NSMutableArray	*particles;

- (id)initAt:(NSPoint)aPoint withTimeToLive:(int)ttl andTemplateIdx:(int)tIdx;
- (void)fadeEffect;
- (void)animateAndDrawEffect:(UInt32)frameCounter;

@end
