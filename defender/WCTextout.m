//
//  WCTextout.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCGlobals.h"
#import "WCTextout.h"
#import "WCSpriteManager.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCTextSprite : WCSprite
- (void)offsetYBy:(CGFloat)xo;
@end

/*---------------------------------------------------------------------------*/
@implementation WCTextSprite
- (void)offsetYBy:(CGFloat)yo
{
	srcRect.origin.y -= yo;
}
@end

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCTextout

/*---------------------------------------------------------------------------*/
+ (void)printAtX:(CGFloat)x atY:(CGFloat)y theString:(NSString*)aString atScale:(CGFloat)scale inFont:(UInt32)font orAttribs:(WCTextAttr*)aAttribs
{
	WCTextSprite *aSprite = [WCSpriteManager makeSpriteClass:[WCTextSprite class] fromImage:DB_STRINGS[DB_FONT_PNG] forAnim:Nil];
	UInt32 len = (UInt32)[aString length];
	
	CGFloat transparency = 1.0;
	for(int i = 0; i < len ; ++i)
	{
		UInt32 c = [aString characterAtIndex:i];
		c -= ' ';
		if(c)										// if not space
		{
			if(--c)									// no space in font, so ! is now at 0
			{
				if(c >= 32)							// A-Z
					c -= 16;
				else if(c >= 15 && c <= 25)			// 0123456789:
					c -= 12;
				else if(c == 13)					// .
					c = 1;
				else if(c == 6)						// '
					c = 2;
				else if(c == 28)					// =
					c = 14;
				else
					c = 15;							// Unknown - force to ?
			}
			
			aSprite.srcRect = aSprite.spriteData.frameData[c];
			if(aAttribs)
			{
				font = aAttribs[i].font;
				scale = aAttribs[i].scale;
				transparency = aAttribs[i].transparency;
			}
			[aSprite offsetYBy:(aSprite.srcRect.size.height+1.0) * 2.0 * font];
			aSprite.position = NSMakePoint(x, y);
			aSprite.scale = NSMakePoint(scale, scale);
			aSprite.transparency = transparency;
			[WCSpriteManager renderSprite:aSprite onLayer:RENDER_LAYER_TEXT withCopy:YES];
			x += (aSprite.srcRect.size.width + 1.0) * scale;
		}
		else
		{
			x += (aSprite.spriteData.frameData[3].size.width + 1.0) * scale;	// space width is width of '0' char
		}
	}
}
@end
