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

#import "DesmumePreferencesController.h"
#import "globals.h"
#import "input.h"

/* Preference settings are stored using NSUserDefaults
 which should put them in a property list in /Users/username/Library/Preferences
 
 For the keys we use the same strings you see in the preference menu
 such as "Execute Upon Load" to keep things simple, of course the unlocalized version
 of the strings are used so that when you change language it will still
 finds the settings from before. Also theres no guarantee that localized
 strings will be unique.
 */

#define INTERFACE_INTERNAL_NAME @"Interface"
#define CONTROLS_INTERNAL_NAME @"Controls"
#define FIRMWARE_INTERNAL_NAME @"Firmware"


///////////////////////////////

@implementation DesmumePreferencesController

//This needs to be called when the program starts
+ (void)setAppDefaults
{
	unichar enter = UTF8_RETURN;
    unichar up = UTF8_UP;
    unichar down = UTF8_DOWN;
    unichar right = UTF8_RIGHT;
    unichar left = UTF8_LEFT;
    
    NSMutableDictionary *defaults = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                
        //Flash file default
        @"", PREF_FLASH_FILE,
        
        //Interface defaults
        @"Yes", PREF_EXECUTE_UPON_LOAD,
        PREF_AFTER_LAUNCHED_OPTION_NOTHING, PREF_AFTER_LAUNCHED,
        
        //Firmware defaults
        //@"DeSmuME User", PREF_FIRMWARE_PLAYER_NAME,
        //@"English", PREF_FIRMWARE_LANGUAGE,
                             
        //Controls defaults
         @"x", PREF_KEY_A,
         @"z", PREF_KEY_B,
         @"g", PREF_KEY_X,
         @"h", PREF_KEY_Y,
         @"c", PREF_KEY_L,
         @"n", PREF_KEY_R,
         @" ", PREF_KEY_SELECT,
         [NSString stringWithCharacters:&up length:1], PREF_KEY_UP,
         [NSString stringWithCharacters:&down length:1], PREF_KEY_DOWN,
         [NSString stringWithCharacters:&left length:1], PREF_KEY_LEFT,
         [NSString stringWithCharacters:&right length:1], PREF_KEY_RIGHT,
         [NSString stringWithCharacters:&enter length:1], PREF_KEY_START,
        
        nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)awakeFromNib
{
    [window becomeKeyWindow];
    [self showInterfacePreferences:interface];
}

- (IBAction) showInterfacePreferences:(id)sender
{
    
    NSString *ident = [sender itemIdentifier];
    [toolbar setSelectedItemIdentifier:ident];
    
    [self showPreferencesView:interface_view];
}

- (IBAction) showControlsPreferences:(id)sender
{
    NSString *ident = [sender itemIdentifier];
    [toolbar setSelectedItemIdentifier:ident];
    
    [self showPreferencesView:controls_view];
}

- (void) showPreferencesView:(NSView*)view
{
    [current_view removeFromSuperview];
    
    NSRect new_frame = [window frameRectForContentRect:[view bounds]];
    new_frame.origin = [window frame].origin;
    new_frame.origin.y -= new_frame.size.height - [window frame].size.height;
    [window setFrame:new_frame display:YES animate:YES];
    
    current_view = view;
    [[window contentView] addSubview:view];
}

- (void)windowWillClose:(NSNotification*)aNotification
{
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end

////////////////////////////////////////////////////

@implementation KeyboardValueTransformer

+ (Class) transformedValueClass
{
    return [NSString self];
}

+ (BOOL) allowsReverseTransformation
{
    return YES;
}

- (id) transformedValue:(id)value
{
    return [value uppercaseString];
}

@end
