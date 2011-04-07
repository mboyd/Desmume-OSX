/*  Copyright (C) 2007 Jeff Bland

	This file is part of DeSmuME

	DeSmuME is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	DeSmuME is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with DeSmuME; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#import <Cocoa/Cocoa.h>

#define PREF_EXECUTE_UPON_LOAD @"Execute Upon Load"

#define PREF_AFTER_LAUNCHED @"When Launching, Load"
#define PREF_AFTER_LAUNCHED_OPTION_NOTHING @"Load Nothing"
#define PREF_AFTER_LAUNCHED_OPTION_LAST_ROM @"Load Last ROM"

#define PREF_FLASH_FILE @"Flash File"

#ifdef GDB_STUB
#define PREF_ARM9_GDB_PORT @"arm9gdb"
#define PREF_ARM7_GDB_PORT @"arm7gdb"
#endif

#define PREF_KEY_A @"A Button"
#define PREF_KEY_B @"B Button"
#define PREF_KEY_X @"X Button"
#define PREF_KEY_Y @"Y Button"
#define PREF_KEY_L @"L Button"
#define PREF_KEY_R @"R Button"
#define PREF_KEY_UP  @"Up Button"
#define PREF_KEY_DOWN @"Down Button"
#define PREF_KEY_LEFT @"Left Button"
#define PREF_KEY_RIGHT @"Right Button"
#define PREF_KEY_START @"Start Button"
#define PREF_KEY_SELECT @"Select Button"

#define UTF8_RETURN ((unichar)13L)
#define UTF8_RIGHT ((unichar)63235L)
#define UTF8_LEFT ((unichar)63234L)
#define UTF8_UP ((unichar)63232L)
#define UTF8_DOWN ((unichar)63233L)

@interface DesmumePreferencesController : NSObject <NSWindowDelegate>
{
	IBOutlet NSWindow *window;
    IBOutlet NSToolbar *toolbar;
    IBOutlet NSView *pref_view;
	
    IBOutlet NSToolbarItem *interface;
	IBOutlet NSView *interface_view;
	
    IBOutlet NSToolbarItem *controls;
	IBOutlet NSView *controls_view;
	
    IBOutlet NSToolbarItem *ds_firmware;
	IBOutlet NSView *firmware_view;
    
    NSView *current_view;
    
    @private
    NSString *k_return, *k_right, *k_left, *k_up, *k_down;
}

//preferences
+ (void)setAppDefaults;

- (void)awakeFromNib;

- (IBAction)showInterfacePreferences:(id)sender;
- (IBAction)showControlsPreferences:(id)sender;

- (void)showPreferencesView:(NSView*)view;

- (void)windowWillClose:(NSNotification *)notification;

@end

@interface KeyboardValueTransformer : NSValueTransformer
{}

+ (Class) transformedValueClass;
+ (BOOL) allowsReverseTransformation;

- (id) transformedValue:(id)value;
@end
