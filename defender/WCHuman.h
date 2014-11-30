//
//  WCHuman.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCAISprite.h"

/*---------------------------------------------------------------------------*/
enum
{
	HUMAN_STATE_INIT,
	HUMAN_STATE_WALKING,
	HUMAN_STATE_CAUGHT,
	HUMAN_STATE_HOISTED,
	HUMAN_STATE_FALLING,
	HUMAN_STATE_SAVED,
	HUMAN_STATE_LANDED,
};

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCHuman : WCAISprite

@property (nonatomic, retain, setter=addHost:)	WCAISprite		*theHost;
@property						NSPoint			desiredPosition;
@property						UInt32			frame;
@property						UInt32			height;

- (UInt32)isA;
- (void)addHost:(WCAISprite*)aHost;
- (void)removeHost;
- (void)hoistBy:(CGFloat)aHoistAmnt;
- (void)run:(UInt32)frameCounter;

@end
