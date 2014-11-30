//
//  WCInputManager.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/hid/IOHIDLib.h>

/*---------------------------------------------------------------------------*/
#define INPUT_SET_BIT(x)	(1<<(x))

#define INPUT_UP			INPUT_SET_BIT(0)
#define INPUT_DOWN			INPUT_SET_BIT(1)
#define INPUT_THRUST		INPUT_SET_BIT(2)
#define INPUT_FIRE			INPUT_SET_BIT(3)
#define INPUT_FLIP			INPUT_SET_BIT(4)
#define INPUT_SMARTBOMB		INPUT_SET_BIT(5)
#define INPUT_HYPER			INPUT_SET_BIT(6)
#define INPUT_1PLAYER		INPUT_SET_BIT(7)
#define INPUT_2PLAYER		INPUT_SET_BIT(8)
#define INPUT_RIGHT			INPUT_SET_BIT(9)
#define INPUT_LEFT			INPUT_SET_BIT(10)
#define INPUT_SELECT		INPUT_SET_BIT(11)
#define INPUT_CANCEL		INPUT_SET_BIT(12)

typedef struct _tagJoyMap
{
	uint32_t	page;
	uint32_t	code;
	long		value;
} WCJoyMap;

extern WCJoyMap				g_joyMap[];
extern UInt32				g_keyMap[];
extern const WCJoyMap		g_joyMapDef[];
extern const UInt32			g_keyMapDef[];
extern UInt32				g_numJoyCntrls;
extern UInt32				g_numKeys;

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCInputManager : NSObject

@property					UInt32			keyState;
@property					IOHIDManagerRef	hidManager;
@property					uint32_t		rawKeyCode;
@property					WCJoyMap		rawJoyCode;

+ (WCInputManager *) inputManager;

@end
