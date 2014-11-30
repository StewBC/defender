//
//  WCWessels.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-13.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCWessels.h"
#import "WCGlobals.h"

/*---------------------------------------------------------------------------*/
#define WESSELS_COLCHANGE_TIME		4

const NSPoint points[] =
{
	  8.0,  20.0,   8.0,  16.0,   8.0,  12.0,   0.0,  11.0,   0.0,  15.0,   0.0,  19.0,   0.0,  23.0,   8.0,  26.0,
	 16.0,  26.0,  24.0,  26.0,  21.0,  22.0,  19.0,  18.0,  17.0,  14.0,  15.0,  10.0,  11.0,   6.0,   8.0,   2.0,
	  5.0,   0.0,  16.0,   2.0,  20.0,   6.0,  22.0,  10.0,  29.0,  14.0,  37.0,  16.0,  40.0,  20.0,  40.0,  24.0,
	 32.0,  24.0,  32.0,  20.0,  29.0,  16.0,  29.0,  12.0,  28.0,   8.0,  27.0,   4.0,  26.0,   0.0,  35.0,   6.0,
	 37.0,  10.0,  45.0,  14.0,  49.0,  18.0,  51.0,  22.0,  51.0,  26.0,  42.0,   3.0,  47.0,   3.0,  52.0,   7.0,
	 56.0,  11.0,  48.0,  11.0,  45.0,   7.0,  42.0,   3.0,  42.0,   0.0,  50.0,   0.0,  57.0,   4.0,  60.0,   8.0,
	 63.0,  11.0,  71.0,  13.0,  66.0,   9.0,  66.0,   5.0,  64.0,   1.0,  58.0,   0.0,  66.0,   4.0,  74.0,   8.0,
	 78.0,   9.0,  86.0,  12.0,  85.0,   9.0,  82.0,   5.0,  82.0,   1.0,  76.0,   0.0,  75.0,   2.0,  87.0,   3.0,
	 95.0,   3.0, 101.0,   4.0, 106.0,   8.0, 103.0,   9.0,  95.0,   8.0,  95.0,   4.0,  95.0,   0.0, 103.0,   0.0,
	105.0,   4.0, 109.0,   6.0, 111.0,  10.0, 114.0,  14.0, 118.0,  18.0, 121.0,  22.0, 125.0,  26.0, 131.0,  27.0,
	128.0,  23.0, 124.0,  19.0, 121.0,  15.0, 117.0,  11.0, 114.0,   7.0, 112.0,   3.0, 112.0,   0.0, 118.0,   2.0,
	124.0,   4.0, 127.0,   8.0, 132.0,  11.0, 131.0,   7.0, 131.0,   3.0, 129.0,   0.0, 121.0,   0.0, 129.0,   1.0,
	137.0,   2.0, 140.0,   6.0, 133.0,  15.0, 133.0,  19.0, 141.0,  21.0, 149.0,  21.0, 152.0,  17.0, 152.0,  13.0,
	144.0,  12.0, 138.0,  12.0, 137.0,  16.0, 140.0,  17.0, 145.0,  16.0, 145.0,  20.0,
};
const UInt32 numPoints = sizeof(points) / sizeof(points[0]);

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCWessels

@synthesize segments;
@synthesize state;
@synthesize pointIndex;
@synthesize myRect;
@synthesize frame;
@synthesize colorChange;

/*---------------------------------------------------------------------------*/
- (void)setup
{
	segments = [NSMutableArray array];
	myRect = srcRect;
	pointIndex = 0;
	self.state = WESSELS_START;
	frame = 0;
}

/*---------------------------------------------------------------------------*/
- (void)run:(UInt32)frameCounter
{
	switch(self.state)
	{
		case WESSELS_START:
			{
				if(!(frameCounter % 1))
				{
					if(!colorChange--)
					{
						frame = 1 - frame;
						colorChange = frame ? 6 : 3;
					}

					if(pointIndex < numPoints)
					{
						NSRect aRect = NSMakeRect(0.0, 0.0, 8.0, 4.5);
						aRect.origin = points[pointIndex++];
						[segments addObject:[NSValue valueWithRect:aRect]];
					}
					else
					{
						self.state = WESSELS_ENDSTRIPS;
					}
				}
				
				NSPoint myPos = self.position;
				for(NSValue *aRectVal in segments)
				{
					NSRect aRect = [aRectVal rectValue];
					self.position = NSMakePoint(myPos.x + WESSELS_SIZE*aRect.origin.x, myPos.y + WESSELS_SIZE*aRect.origin.y);
					if(frame)
						aRect.origin.y += 32.0;

					self.srcRect = aRect;
					[WCSpriteManager renderSprite:self onLayer:RENDER_LAYER_TEXT withCopy:YES];
				}
				self.position = myPos;
			}
			break;
			
		case WESSELS_ENDSTRIPS:
			self.srcRect = myRect;
			[segments removeAllObjects];
			pointIndex = 0;
			self.state = WESSELS_HOLD;
			// Intentionally fall through
			
		case WESSELS_HOLD:
			if(!(frameCounter % 1))
			{
				if(!colorChange--)
				{
					frame = 1 - frame;
					colorChange = frame ? 6 : 3;
				}
			}
			[self setFrameInCurrAnim:frame];
			[WCSpriteManager renderSprite:self onLayer:RENDER_LAYER_TEXT withCopy:NO];
			break;
	}
}

@end
