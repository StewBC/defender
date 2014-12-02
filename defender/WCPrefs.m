//
//  WCPrefs.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-27.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCPrefs.h"
#import "WCGlobals.h"
#import "WCInputManager.h"
#import "WCTextout.h"

/*---------------------------------------------------------------------------*/
#define PREFS_KEY_REPEAT_RATE	GAME_SECONDS(0.25)
#define COUNTER_HOLD_TIME		GAME_SECONDS(0.1)

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCPrefs

@synthesize menuItems;
@synthesize keyFontAttrDict;
@synthesize joyFontAttrDict;
@synthesize font;
@synthesize counter;
@synthesize keyHeld;
@synthesize repeatRate;
@synthesize selected;

/*---------------------------------------------------------------------------*/
- (id)init
{
	if(self = [super init])
	{
		menuItems = [NSArray arrayWithObjects:@"UP", @"DOWN", @"THRUST", @"FIRE", @"FLIP", @"SMART BOMB", @"HYPERSPACE", @"1 PLAYER", @"2 PLAYER", @"RESET TO DEFAULTS", nil];
		keyFontAttrDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
															   [NSFont fontWithName:@"Times Roman" size:26.0],
															   [NSColor redColor],
															   [NSColor blackColor],
															   nil]
													  forKeys:[NSArray arrayWithObjects:
															   NSFontAttributeName,
															   NSForegroundColorAttributeName,
															   NSBackgroundColorAttributeName,
															   nil]];
		joyFontAttrDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
															   [NSFont fontWithName:@"Times Roman" size:26.0],
															   [NSColor cyanColor],
															   [NSColor blackColor],
															   nil]
													   forKeys:[NSArray arrayWithObjects:
															   NSFontAttributeName,
															   NSForegroundColorAttributeName,
															   NSBackgroundColorAttributeName,
															   nil]];

	}
	return self;
}

/*---------------------------------------------------------------------------*/
- (NSString*)humanString:(UInt32)keyCode
{
	switch(keyCode)
	{
		case kHIDUsage_KeyboardA:
			return @"a or A";
			
		case kHIDUsage_KeyboardB:
			return @"b or B";
			
		case kHIDUsage_KeyboardC:
			return @"c or C";
			
		case kHIDUsage_KeyboardD:
			return @"d or D";
			
		case kHIDUsage_KeyboardE:
			return @"e or E";
			
		case kHIDUsage_KeyboardF:
			return @"f or F";
			
		case kHIDUsage_KeyboardG:
			return @"g or G";
			
		case kHIDUsage_KeyboardH:
			return @"h or H";
			
		case kHIDUsage_KeyboardI:
			return @"i or I";
			
		case kHIDUsage_KeyboardJ:
			return @"j or J";
			
		case kHIDUsage_KeyboardK:
			return @"k or K";
			
		case kHIDUsage_KeyboardL:
			return @"l or L";
			
		case kHIDUsage_KeyboardM:
			return @"m or M";
			
		case kHIDUsage_KeyboardN:
			return @"n or N";
			
		case kHIDUsage_KeyboardO:
			return @"o or O";
			
		case kHIDUsage_KeyboardP:
			return @"p or P";
			
		case kHIDUsage_KeyboardQ:
			return @"q or Q";
			
		case kHIDUsage_KeyboardR:
			return @"r or R";
			
		case kHIDUsage_KeyboardS:
			return @"s or S";
			
		case kHIDUsage_KeyboardT:
			return @"t or T";
			
		case kHIDUsage_KeyboardU:
			return @"u or U";
			
		case kHIDUsage_KeyboardV:
			return @"v or V";
			
		case kHIDUsage_KeyboardW:
			return @"w or W";
			
		case kHIDUsage_KeyboardX:
			return @"x or X";
			
		case kHIDUsage_KeyboardY:
			return @"y or Y";
			
		case kHIDUsage_KeyboardZ:
			return @"z or Z";
			
		case kHIDUsage_Keyboard1:
			return @"1 or !";
			
		case kHIDUsage_Keyboard2:
			return @"2 or @";
			
		case kHIDUsage_Keyboard3:
			return @"3 or #";
			
		case kHIDUsage_Keyboard4:
			return @"4 or $";
			
		case kHIDUsage_Keyboard5:
			return @"5 or %";
			
		case kHIDUsage_Keyboard6:
			return @"6 or ^";
			
		case kHIDUsage_Keyboard7:
			return @"7 or &";
			
		case kHIDUsage_Keyboard8:
			return @"8 or *";
			
		case kHIDUsage_Keyboard9:
			return @"9 or (";
			
		case kHIDUsage_Keyboard0:
			return @"0 or )";
			
		case kHIDUsage_KeyboardReturnOrEnter:
			return @"Return (Enter)";
			
		case kHIDUsage_KeyboardEscape:
			return @"Escape";
			
		case kHIDUsage_KeyboardDeleteOrBackspace:
			return @"Delete (Backspace)";
			
		case kHIDUsage_KeyboardTab:
			return @"Tab";
			
		case kHIDUsage_KeyboardSpacebar:
			return @"Spacebar";
			
		case kHIDUsage_KeyboardHyphen:
			return @"- or _";
			
		case kHIDUsage_KeyboardEqualSign:
			return @"= or +";
			
		case kHIDUsage_KeyboardOpenBracket:
			return @"[ or {";
			
		case kHIDUsage_KeyboardCloseBracket:
			return @"] or }";
			
		case kHIDUsage_KeyboardBackslash:
			return @"\\ or |";
			
		case kHIDUsage_KeyboardNonUSPound:
			return @"Non-US # or _";
			
		case kHIDUsage_KeyboardSemicolon:
			return @"; or :";
			
		case kHIDUsage_KeyboardQuote:
			return @"' or \"";
			
		case kHIDUsage_KeyboardGraveAccentAndTilde:
			return @"Grave Accent and Tilde";
			
		case kHIDUsage_KeyboardComma:
			return @", or <";
			
		case kHIDUsage_KeyboardPeriod:
			return @". or >";
			
		case kHIDUsage_KeyboardSlash:
			return @"/ or ?";
			
		case kHIDUsage_KeyboardCapsLock:
			return @"Caps Lock";
			
		case kHIDUsage_KeyboardF1:
			return @"F1";
			
		case kHIDUsage_KeyboardF2:
			return @"F2";
			
		case kHIDUsage_KeyboardF3:
			return @"F3";
			
		case kHIDUsage_KeyboardF4:
			return @"F4";
			
		case kHIDUsage_KeyboardF5:
			return @"F5";
			
		case kHIDUsage_KeyboardF6:
			return @"F6";
			
		case kHIDUsage_KeyboardF7:
			return @"F7";
			
		case kHIDUsage_KeyboardF8:
			return @"F8";
			
		case kHIDUsage_KeyboardF9:
			return @"F9";
			
		case kHIDUsage_KeyboardF10:
			return @"F10";
			
		case kHIDUsage_KeyboardF11:
			return @"F11";
			
		case kHIDUsage_KeyboardF12:
			return @"F12";
			
		case kHIDUsage_KeyboardPrintScreen:
			return @"Print Screen";
			
		case kHIDUsage_KeyboardScrollLock:
			return @"Scroll Lock";
			
		case kHIDUsage_KeyboardPause:
			return @"Pause";
			
		case kHIDUsage_KeyboardInsert:
			return @"Insert";
			
		case kHIDUsage_KeyboardHome:
			return @"Home";
			
		case kHIDUsage_KeyboardPageUp:
			return @"Page Up";
			
		case kHIDUsage_KeyboardDeleteForward:
			return @"Delete Forward";
			
		case kHIDUsage_KeyboardEnd:
			return @"End";
			
		case kHIDUsage_KeyboardPageDown:
			return @"Page Down";
			
		case kHIDUsage_KeyboardRightArrow:
			return @"Right Arrow";
			
		case kHIDUsage_KeyboardLeftArrow:
			return @"Left Arrow";
			
		case kHIDUsage_KeyboardDownArrow:
			return @"Down Arrow";
			
		case kHIDUsage_KeyboardUpArrow:
			return @"Up Arrow";
			
		case kHIDUsage_KeypadNumLock:
			return @"Keypad NumLock or Clear";
			
		case kHIDUsage_KeypadSlash:
			return @"Keypad /";
			
		case kHIDUsage_KeypadAsterisk:
			return @"Keypad *";
			
		case kHIDUsage_KeypadHyphen:
			return @"Keypad -";
			
		case kHIDUsage_KeypadPlus:
			return @"Keypad +";
			
		case kHIDUsage_KeypadEnter:
			return @"Keypad Enter";
			
		case kHIDUsage_Keypad1:
			return @"Keypad 1 or End";
			
		case kHIDUsage_Keypad2:
			return @"Keypad 2 or Down Arrow";
			
		case kHIDUsage_Keypad3:
			return @"Keypad 3 or Page Down";
			
		case kHIDUsage_Keypad4:
			return @"Keypad 4 or Left Arrow";
			
		case kHIDUsage_Keypad5:
			return @"Keypad 5";
			
		case kHIDUsage_Keypad6:
			return @"Keypad 6 or Right Arrow";
			
		case kHIDUsage_Keypad7:
			return @"Keypad 7 or Home";
			
		case kHIDUsage_Keypad8:
			return @"Keypad 8 or Up Arrow";
			
		case kHIDUsage_Keypad9:
			return @"Keypad 9 or Page Up";
			
		case kHIDUsage_Keypad0:
			return @"Keypad 0 or Insert";
			
		case kHIDUsage_KeypadPeriod:
			return @"Keypad . or Delete";
			
		case kHIDUsage_KeyboardNonUSBackslash:
			return @"Non-US \\ or |";
			
		case kHIDUsage_KeyboardApplication:
			return @"Application";
			
		case kHIDUsage_KeyboardPower:
			return @"Power";
			
		case kHIDUsage_KeypadEqualSign:
			return @"Keypad =";
			
		case kHIDUsage_KeyboardF13:
			return @"F13";
			
		case kHIDUsage_KeyboardF14:
			return @"F14";
			
		case kHIDUsage_KeyboardF15:
			return @"F15";
			
		case kHIDUsage_KeyboardF16:
			return @"F16";
			
		case kHIDUsage_KeyboardF17:
			return @"F17";
			
		case kHIDUsage_KeyboardF18:
			return @"F18";
			
		case kHIDUsage_KeyboardF19:
			return @"F19";
			
		case kHIDUsage_KeyboardF20:
			return @"F20";
			
		case kHIDUsage_KeyboardF21:
			return @"F21";
			
		case kHIDUsage_KeyboardF22:
			return @"F22";
			
		case kHIDUsage_KeyboardF23:
			return @"F23";
			
		case kHIDUsage_KeyboardF24:
			return @"F24";
			
		case kHIDUsage_KeyboardExecute:
			return @"Execute";
			
		case kHIDUsage_KeyboardHelp:
			return @"Help";
			
		case kHIDUsage_KeyboardMenu:
			return @"Menu";
			
		case kHIDUsage_KeyboardSelect:
			return @"Select";
			
		case kHIDUsage_KeyboardStop:
			return @"Stop";
			
		case kHIDUsage_KeyboardAgain:
			return @"Again";
			
		case kHIDUsage_KeyboardUndo:
			return @"Undo";
			
		case kHIDUsage_KeyboardCut:
			return @"Cut";
			
		case kHIDUsage_KeyboardCopy:
			return @"Copy";
			
		case kHIDUsage_KeyboardPaste:
			return @"Paste";
			
		case kHIDUsage_KeyboardFind:
			return @"Find";
			
		case kHIDUsage_KeyboardMute:
			return @"Mute";
			
		case kHIDUsage_KeyboardVolumeUp:
			return @"Volume Up";
			
		case kHIDUsage_KeyboardVolumeDown:
			return @"Volume Down";
			
		case kHIDUsage_KeyboardLockingCapsLock:
			return @"Locking Caps Lock";
			
		case kHIDUsage_KeyboardLockingNumLock:
			return @"Locking Num Lock";
			
		case kHIDUsage_KeyboardLockingScrollLock:
			return @"Locking Scroll Lock";
			
		case kHIDUsage_KeypadComma:
			return @"Keypad Comma";
			
		case kHIDUsage_KeypadEqualSignAS400:
			return @"Keypad Equal Sign for AS/400";
			
		case kHIDUsage_KeyboardInternational1:
			return @"International1";
			
		case kHIDUsage_KeyboardInternational2:
			return @"International2";
			
		case kHIDUsage_KeyboardInternational3:
			return @"International3";
			
		case kHIDUsage_KeyboardInternational4:
			return @"International4";
			
		case kHIDUsage_KeyboardInternational5:
			return @"International5";
			
		case kHIDUsage_KeyboardInternational6:
			return @"International6";
			
		case kHIDUsage_KeyboardInternational7:
			return @"International7";
			
		case kHIDUsage_KeyboardInternational8:
			return @"International8";
			
		case kHIDUsage_KeyboardInternational9:
			return @"International9";
			
		case kHIDUsage_KeyboardLANG1:
			return @"LANG1";
			
		case kHIDUsage_KeyboardLANG2:
			return @"LANG2";
			
		case kHIDUsage_KeyboardLANG3:
			return @"LANG3";
			
		case kHIDUsage_KeyboardLANG4:
			return @"LANG4";
			
		case kHIDUsage_KeyboardLANG5:
			return @"LANG5";
			
		case kHIDUsage_KeyboardLANG6:
			return @"LANG6";
			
		case kHIDUsage_KeyboardLANG7:
			return @"LANG7";
			
		case kHIDUsage_KeyboardLANG8:
			return @"LANG8";
			
		case kHIDUsage_KeyboardLANG9:
			return @"LANG9";
			
		case kHIDUsage_KeyboardAlternateErase:
			return @"AlternateErase";
			
		case kHIDUsage_KeyboardSysReqOrAttention:
			return @"SysReq/Attention";
			
		case kHIDUsage_KeyboardCancel:
			return @"Cancel";
			
		case kHIDUsage_KeyboardClear:
			return @"Clear";
			
		case kHIDUsage_KeyboardPrior:
			return @"Prior";
			
		case kHIDUsage_KeyboardReturn:
			return @"Return";
			
		case kHIDUsage_KeyboardSeparator:
			return @"Separator";
			
		case kHIDUsage_KeyboardOut:
			return @"Out";
			
		case kHIDUsage_KeyboardOper:
			return @"Oper";
			
		case kHIDUsage_KeyboardClearOrAgain:
			return @"Clear/Again";
			
		case kHIDUsage_KeyboardCrSelOrProps:
			return @"CrSel/Props";
			
		case kHIDUsage_KeyboardExSel:
			return @"ExSel";
			
		case kHIDUsage_KeyboardLeftControl:
			return @"Left Control";
			
		case kHIDUsage_KeyboardLeftShift:
			return @"Left Shift";
			
		case kHIDUsage_KeyboardLeftAlt:
			return @"Left Alt";
			
		case kHIDUsage_KeyboardLeftGUI:
			return @"Left GUI";
			
		case kHIDUsage_KeyboardRightControl:
			return @"Right Control";
			
		case kHIDUsage_KeyboardRightShift:
			return @"Right Shift";
			
		case kHIDUsage_KeyboardRightAlt:
			return @"Right Alt";
			
		case kHIDUsage_KeyboardRightGUI:
			return @"Right GUI";

		default:
			return @"Unknown";
	}
}

/*---------------------------------------------------------------------------*/
- (BOOL)run
{
	UInt32 keyState = WCInputManager.inputManager.keyState;
	uint32_t rawKeyCode = WCInputManager.inputManager.rawKeyCode;
	WCJoyMap rawJoyCode = WCInputManager.inputManager.rawJoyCode;
	BOOL joyScreen = WCGlobals.globalsManager.joystickScreen;
	UInt32 activeItem = [WCGlobals.globalsManager prefItem:joyScreen];
	
	if(keyState & keyHeld)
	{
		if(repeatRate)
		{
			keyState &= ~keyHeld;
			--repeatRate;
		}
		else
		{
			repeatRate = PREFS_KEY_REPEAT_RATE;
		}
	}
	else
	{
		keyHeld = 0;
		repeatRate = PREFS_KEY_REPEAT_RATE;
	}

	if(selected && !(keyState & INPUT_CANCEL))
	{
		if(keyHeld)
			return YES;

		if(joyScreen)
		{
			if(rawJoyCode.value)
			{
				g_joyMap[activeItem] = rawJoyCode;
				selected = NO;
				keyHeld |= INPUT_SELECT;
				if(activeItem < 2)
					keyHeld |= INPUT_UP | INPUT_DOWN;
			}
		}
		else if(-1 != rawKeyCode)
		{
			g_keyMap[activeItem] = rawKeyCode;
			selected = NO;
			keyHeld |= INPUT_SELECT;
			if(activeItem < 2)
				keyHeld |= INPUT_UP | INPUT_DOWN;
		}
		
		return YES;
	}
	
	if(keyState & INPUT_UP)
	{
		keyHeld |= INPUT_UP;
		if(!activeItem)
			activeItem = (UInt32)[menuItems count];
		--activeItem;
	}
	else if(keyState & INPUT_DOWN)
	{
		keyHeld |= INPUT_DOWN;
		++activeItem;
		if(activeItem == [menuItems count])
			activeItem = 0;
	}
	else if(keyState & INPUT_RIGHT || keyState & INPUT_LEFT)
	{
		keyHeld |= INPUT_RIGHT | INPUT_LEFT;
		joyScreen = 1 - joyScreen;
	}
	else if(keyState & INPUT_SELECT)
	{
		keyHeld |= INPUT_SELECT;
		if(activeItem == [menuItems count] - 1)
		{
			if(joyScreen)
				memcpy(g_joyMap, g_joyMapDef, sizeof(WCJoyMap) * g_numJoyCntrls);
			else
				memcpy(g_keyMap, g_keyMapDef, sizeof(UInt32) * g_numKeys);
		}
		else
		{
			selected = 1 - selected;
		}
	}

	[WCGlobals.globalsManager setPrefItem:activeItem forScreen:joyScreen];
	WCGlobals.globalsManager.joystickScreen = joyScreen;

	if(keyState & INPUT_CANCEL)
	{
		keyHeld |= INPUT_CANCEL;
		if(!selected)
			return NO;
		selected = NO;
	}

	return YES;
}

/*---------------------------------------------------------------------------*/
- (void)draw
{
	BOOL joyScreen = WCGlobals.globalsManager.joystickScreen;
	UInt32 activeItem = [WCGlobals.globalsManager prefItem:joyScreen];
	CGFloat y = 320.0;
	UInt32 i = 0;

	if(++counter > COUNTER_HOLD_TIME)
	{
		counter = 0;
		if(++font >= WCCOLOR_NUM_COLORS)
			font = 0;
	}
	
	[WCTextout printAtX:170 atY:450 theString:@"CONFIGURE INPUT" atScale:5 inFont:font orAttribs:Nil];
	[WCTextout printAtX:20 atY:403 theString:@"LEFT AND RIGHT SWITCHES BETWEEN KEYBOARD AND JOYSTICK.  ENTER TO CHANGE" atScale:1.7 inFont:WCCOLOR_PURPLE orAttribs:Nil];

	if(joyScreen)
		[WCTextout printAtX:320 atY:365 theString:@"JOYSTICK" atScale:3.0 inFont:WCCOLOR_CYAN orAttribs:Nil];
	else
		[WCTextout printAtX:320 atY:365 theString:@"KEYBOARD" atScale:3.0 inFont:WCCOLOR_RED orAttribs:Nil];
	
	for(NSString *aMenuStr in menuItems)
	{
		[WCTextout printAtX:100 atY:y theString:aMenuStr atScale:2.5 inFont:activeItem == i ? (selected ? WCCOLOR_RED : WCCOLOR_WHITE) : WCCOLOR_YELLOW orAttribs:Nil];
		if(i < [menuItems count]-1)
		{
			if(!joyScreen)
				[[self humanString:g_keyMap[i]] drawAtPoint:NSMakePoint(400, y-12) withAttributes:keyFontAttrDict];
			else
			{
				if(1 == g_joyMap[i].page)
					[[NSString stringWithFormat:@"Axis %d",g_joyMap[i].code] drawAtPoint:NSMakePoint(400, y-12) withAttributes:joyFontAttrDict];
				else
					 [[NSString stringWithFormat:@"Button %d",g_joyMap[i].code] drawAtPoint:NSMakePoint(400, y-12) withAttributes:joyFontAttrDict];
			}
		}
		
		++i;
		y -= 28;
	}

	[WCTextout printAtX:115 atY:30 theString:@"ESCAPE RETURNS TO THE GAME AND ALSO CANCELS SELECTION" atScale:1.7 inFont:WCCOLOR_PURPLE orAttribs:Nil];
}
@end
