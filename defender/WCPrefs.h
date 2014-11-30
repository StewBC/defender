//
//  WCPrefs.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-27.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCPrefs : NSObject

@property (nonatomic, copy)		NSArray			*menuItems;
@property (nonatomic, copy)		NSDictionary	*keyFontAttrDict;
@property (nonatomic, copy)		NSDictionary	*joyFontAttrDict;
@property						UInt32			font;
@property						UInt32			counter;
@property						UInt32			keyHeld;
@property						UInt32			repeatRate;
@property						BOOL			selected;

- (BOOL)run;
- (void)draw;

@end
