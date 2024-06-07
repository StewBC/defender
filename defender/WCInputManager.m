//
//  WCInputManager.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

/*---------------------------------------------------------------------------*\
 This needs work.  Attached devices need to be checked for analog controls and
 the ranges for these controls.  Currently any control that doesn't do a range
 greater than 16,384 will not be picked up correctly as I quite arbitrarily
 chose that number as a dead-zone number.  This config lets me use my 360
 controller with the driver from http://tattiebogle.net/
\*---------------------------------------------------------------------------*/

#import "WCInputManager.h"

/*---------------------------------------------------------------------------*/
WCJoyMap g_joyMap[] =
{
	{1, 49, -1}, // INPUT_UP,
	{1, 49,  1}, // INPUT_DOWN,
	{9,  3,  1}, // INPUT_THRUST
	{9,  1,  1}, // INPUT_FIRE,
	{9,  4,  1}, // INPUT_FLIP,
	{9,  2,  1}, // INPUT_SMARTBOMB,
	{9,  6,  1}, // INPUT_HYPER,
	{9,  9,  1}, // INPUT_1PLAYER
	{9, 10,  1}, // INPUT_2PLAYER
	{1, 48,  1}, // INPUT_RIGHT,
	{1, 48, -1}, // INPUT_LEFT,
	{1, 53,  1}, // INPUT_SELECT,
	{1, 50,  1}, // INPUT_CANCEL,
};
UInt32 g_numJoyCntrls = sizeof(g_joyMap) / sizeof(g_joyMap[0]);

UInt32 g_keyMap[] =
{
	kHIDUsage_KeyboardUpArrow,			// INPUT_UP,
	kHIDUsage_KeyboardDownArrow,		// INPUT_DOWN,
	kHIDUsage_KeyboardLeftGUI,			// INPUT_THRUST
	kHIDUsage_KeyboardLeftShift,		// INPUT_FIRE,
	kHIDUsage_KeyboardLeftControl,		// INPUT_FLIP,
	kHIDUsage_KeyboardLeftAlt,			// INPUT_SMARTBOMB,
	kHIDUsage_KeyboardZ,				// INPUT_HYPER,
	kHIDUsage_Keyboard1,				// INPUT_1PLAYER
	kHIDUsage_Keyboard2,				// INPUT_2PLAYER
	kHIDUsage_KeyboardRightArrow,		// INPUT_RIGHT,
	kHIDUsage_KeyboardLeftArrow,		// INPUT_LEFT,
	kHIDUsage_KeyboardReturnOrEnter,	// INPUT_SELECT,
	kHIDUsage_KeyboardEscape,			// INPUT_CANCEL,
};
UInt32 g_numKeys = sizeof(g_keyMap) / sizeof(g_keyMap[0]);

const WCJoyMap g_joyMapDef[] =
{
	{1, 49, -1}, // INPUT_UP,
	{1, 49,  1}, // INPUT_DOWN,
	{9,  3,  1}, // INPUT_THRUST
	{9,  1,  1}, // INPUT_FIRE,
	{9,  4,  1}, // INPUT_FLIP,
	{9,  2,  1}, // INPUT_SMARTBOMB,
	{9,  6,  1}, // INPUT_HYPER,
	{9,  9,  1}, // INPUT_1PLAYER
	{9, 10,  1}, // INPUT_2PLAYER
	{1, 48,  1}, // INPUT_RIGHT,
	{1, 48, -1}, // INPUT_LEFT,
	{1, 53,  1}, // INPUT_SELECT,
	{1, 50,  1}, // INPUT_CANCEL,
};

const UInt32 g_keyMapDef[] =
{
	kHIDUsage_KeyboardUpArrow,			// INPUT_UP,
	kHIDUsage_KeyboardDownArrow,		// INPUT_DOWN,
	kHIDUsage_KeyboardLeftGUI,			// INPUT_THRUST
	kHIDUsage_KeyboardLeftShift,		// INPUT_FIRE,
	kHIDUsage_KeyboardLeftControl,		// INPUT_FLIP,
	kHIDUsage_KeyboardLeftAlt,			// INPUT_SMARTBOMB,
	kHIDUsage_KeyboardZ,				// INPUT_HYPER,
	kHIDUsage_Keyboard1,				// INPUT_1PLAYER
	kHIDUsage_Keyboard2,				// INPUT_2PLAYER
	kHIDUsage_KeyboardRightArrow,		// INPUT_RIGHT,
	kHIDUsage_KeyboardLeftArrow,		// INPUT_LEFT,
	kHIDUsage_KeyboardReturnOrEnter,	// INPUT_SELECT,
	kHIDUsage_KeyboardEscape,			// INPUT_CANCEL,
};

/*---------------------------------------------------------------------------*/
@implementation WCInputManager

@synthesize keyState;
@synthesize hidManager;
@synthesize rawKeyCode;
@synthesize rawJoyCode;

/*---------------------------------------------------------------------------*/
+ (id)inputManager
{
	static WCInputManager *inputManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{ inputManager = [[self alloc] init]; });
	return inputManager;
}

/*---------------------------------------------------------------------------*/
//void inputDeviceAdded(void* inContext, IOReturn inResult, void* inSender, IOHIDDeviceRef device)
//{
//	NSLog(@"inputDevice was plugged in");
//}

/*---------------------------------------------------------------------------*/
//void inputDeviceRemoved(void* inContext, IOReturn inResult, void* inSender, IOHIDDeviceRef device)
//{
//	NSLog(@"inputDevice was unplugged");
//}

/*---------------------------------------------------------------------------*/
void inputDeviceAction(void* inContext, IOReturn inResult, void* inSender, IOHIDValueRef value)
{
	IOHIDElementRef elem = IOHIDValueGetElement(value);
	uint32_t page = IOHIDElementGetUsagePage(elem);
	uint32_t code = IOHIDElementGetUsage(elem);
	long state = IOHIDValueGetIntegerValue(value);
	if(page == kHIDPage_KeyboardOrKeypad)
	{
		if(code >= 0x04 && code <= 0xe7)
		{
			if(state)
				WCInputManager.inputManager.rawKeyCode = code;
			else
				WCInputManager.inputManager.rawKeyCode = -1;
		}
		for(int i = 0; i < g_numKeys; ++i)
		{
			if(code == g_keyMap[i])
			{
				UInt32 keyCode = INPUT_SET_BIT(i);
				if(state)
					WCInputManager.inputManager.keyState |= keyCode;
				else
					WCInputManager.inputManager.keyState &= ~keyCode;
			}
		}
	}
	else if(page == kHIDPage_GenericDesktop || page == kHIDPage_Button)
	{
		WCJoyMap raw = { page, code, state};

		if(page == kHIDPage_GenericDesktop)
		{
			if(labs(state) < 16384)
				state = 0;
			raw.value = state;
		}

		WCInputManager.inputManager.rawJoyCode = raw;
		
		for(int i = 0; i < g_numJoyCntrls; ++i)
		{
			if(page == g_joyMap[i].page && code == g_joyMap[i].code && g_joyMap[i].value * state >= 0)
			{
				UInt32 keyCode = INPUT_SET_BIT(i);
				if(state)
					WCInputManager.inputManager.keyState |= keyCode;
				else
					WCInputManager.inputManager.keyState &= ~keyCode;
			}
		}
	}
}

/*---------------------------------------------------------------------------*/
- (id)init {
	if (self = [super init])
	{
		hidManager = IOHIDManagerCreate( kCFAllocatorDefault, kIOHIDOptionsTypeNone);
		
		NSArray *criteria = [NSArray arrayWithObjects:
							 [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt: kHIDPage_GenericDesktop], (NSString*)CFSTR(kIOHIDDeviceUsagePageKey),
							  [NSNumber numberWithInt: kHIDUsage_GD_Keyboard], (NSString*)CFSTR(kIOHIDDeviceUsageKey),
							  nil, nil],
							 [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt: kHIDPage_GenericDesktop], (NSString*)CFSTR(kIOHIDDeviceUsagePageKey),
							  [NSNumber numberWithInt: kHIDUsage_GD_GamePad], (NSString*)CFSTR(kIOHIDDeviceUsageKey),
							  nil, nil],
							 nil];
		
		IOHIDManagerSetDeviceMatchingMultiple(hidManager, (__bridge void*)criteria);
//		IOHIDManagerRegisterDeviceMatchingCallback(hidManager, inputDeviceAdded, (__bridge void*)self);
//		IOHIDManagerRegisterDeviceRemovalCallback(hidManager, inputDeviceRemoved, (__bridge void*)self);
		IOHIDManagerScheduleWithRunLoop(hidManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
		IOHIDManagerOpen(hidManager, kIOHIDOptionsTypeNone);
		IOHIDManagerRegisterInputValueCallback(hidManager, inputDeviceAction, (__bridge void*)self);
	}
	return self;
}

@end

