//
//  WCBackground.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*---------------------------------------------------------------------------*/
typedef struct _tagWCStar
{
	NSRect	frame;
	BOOL	visible;
	UInt32	decay;
	UInt32	colorIndex;
	UInt32	colors[2];
} WCStar;

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCBackground : NSObject
{
	WCStar						*stars;
	UInt32						*stripIndex;
}

@property (nonatomic, copy)		NSMutableArray	*colors;
@property						NSPoint			*groundPoints;
@property						UInt32			stripWidth;
@property						UInt32			numStrips;
@property						UInt32			vitalsFont;
@property						UInt32			scoreFlashTimer;
@property						UInt32			scoreOffFlag;
@property						UInt32			bombTipColor;
@property						UInt32			podFlashTimer;

- (id)init;
int starCmp(const void *a, const void *b);
- (void)makeGround;
- (CGFloat)getGroundHeightAtX:(CGFloat)xPos;
- (void)blowupGround;
- (void)makeStars;
- (void)drawGround:(UInt32)stripCount atOffset:(NSPoint)drawPoint;
- (void)showVitals;
- (void)drawMinMap;
- (void)drawStars;
- (void)drawHud;

@end
