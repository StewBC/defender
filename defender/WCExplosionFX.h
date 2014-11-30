//
//  WCExplosionFX.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCEffects.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCExplosionFX : WCEffect
{
	UInt32	colChange[2];
	UInt32	colChangeTimer;
}

@property (nonatomic, copy)		NSMutableArray	*particles;

- (id)initAt:(NSPoint)aPoint withTimeToLive:(UInt32)ttl andTemplateIdx:(UInt32)tIdx;
- (void)fadeEffect;
- (void)animateAndDrawEffect:(UInt32)frameCounter;

@end
