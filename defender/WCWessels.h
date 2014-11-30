//
//  WCWessels.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-13.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCSpriteManager.h"

/*---------------------------------------------------------------------------*/
enum
{
	WESSELS_START,
	WESSELS_ENDSTRIPS,
	WESSELS_HOLD,
};


/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCWessels : WCSprite

@property (nonatomic, copy)		NSMutableArray		*segments;
@property						NSRect				myRect;
@property						UInt32				state;
@property						UInt32				pointIndex;
@property						UInt32				frame;
@property						UInt32				colorChange;

- (void)setup;
- (void)run:(UInt32)frameCounter;

@end
