//
//  WCTextout.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*---------------------------------------------------------------------------*/
typedef struct _tagWCTextAttr
{
	UInt32	font;
	CGFloat	scale;
	CGFloat	transparency;
} WCTextAttr;

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCTextout : NSObject

+ (void)printAtX:(CGFloat)x atY:(CGFloat)y theString:(NSString*)aString atScale:(CGFloat)scale inFont:(UInt32)font orAttribs:(WCTextAttr*)aAttribs;
@end
