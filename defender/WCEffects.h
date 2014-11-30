//
//  WCEffects.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WCSpriteManager.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCParticleSprite : WCSprite

@property NSPoint speed;

@end

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCEffect : NSObject

@property					UInt32			timeToLive;
@property					UInt32			timeToFade;
@property					CGFloat			fadeAmount;
@property					NSPoint			worldPoint;

- (id)initWithTimeToLive:(UInt32)ttl;
- (void)fadeEffect;
- (void)animateAndDrawEffect:(UInt32)frameCounter;
- (BOOL)run:(UInt32)frameCounter;

@end

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCEffects : NSObject

@property (nonatomic, copy)	NSMutableArray	*effectsList;

- (void)removeAllEffects;
- (void)addEffect:(WCEffect*)anEffect;
- (void)run:(UInt32)frameCounter;

@end
