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

//DeSmuME Cocoa includes
#import "NDSController.h"
#import "screenshot.h"
#import "screen_state.h"
#import "NDSView.h"
#import "input.h"
#import "DesmumePreferencesController.h"
#import "dialogs/rom_info.h"
#import "dialogs/speed_limit_selection_window.h"

// Save types settings
/*NSString *save_types[MAX_SAVE_TYPE] = { 
 NSLocalizedString(@"Auto Detect", nil), // 0
 NSLocalizedString(@"EEPROM 4kbit", nil),	// 1
 NSLocalizedString(@"EEPROM 64kbit", nil),	// 2
 NSLocalizedString(@"EEPROM 512kbit", nil),	// 3
 NSLocalizedString(@"FRAM 256knit", nil),	// 4
 NSLocalizedString(@"FLASH 2mbit", nil),	// 5
 NSLocalizedString(@"FLASH 4mbit", nil)	// 6
 };*/


@implementation NDSController

//Private interface ------------------------------------------------------------

- (void)setStatusText:(NSString*)value
{
	[status_bar_text release];
	status_bar_text = value;
	[status_bar_text retain];

	if(status_view)[status_view setStringValue:status_bar_text];
}

- (NSString*)statusText
{
	if(status_bar_text)return status_bar_text;
	return @"";
}

//Public Interface -----------------------------------------------------------

- (void) awakeFromNib
{
	status_view = nil;
	status_bar_text = nil;
	input = nil;
	no_smaller_than_ds = true;
	
    keep_proportions = true;
    
    nds = [[NintendoDS alloc] init];

	//Add callbacks
	[nds setVideoUpdateCallback:@selector(setScreenState:) withObject:nds_view];
	[nds setErrorCallback:@selector(emulationError) withObject:self];

	//Create the input manager and insert it into the cocoa responder chain
	input = [[InputHandler alloc] initWithController:self];
	NSResponder *temp = [window nextResponder];
	[window setNextResponder:input];
	[input setNextResponder:temp];
}

- (NintendoDS*) ds
{
    return nds;
}

- (NDSView*) view
{
    return nds_view;
}

- (BOOL)loadROM:(NSString*)filename
{
	//Attemp to load the rom
	BOOL result = [nds loadROM:filename];

	//Set status var and screen depending on whether the rom could be loaded
	if(result == NO)
	{
		[nds_view setScreenState:[ScreenState blackScreenState]]; //black if the rom doesn't load
		[self setStatusText:NSLocalizedString(@"No ROM Loaded", nil)];
		messageDialog(NSLocalizedString(@"Error", nil), @"Couldn't load ROM");
	} else
	{
		//if it worked, check the execute upon load option
		if([[NSUserDefaults standardUserDefaults] boolForKey:PREF_EXECUTE_UPON_LOAD])
			[nds execute];
		else
		{
			[nds_view setScreenState:[ScreenState whiteScreenState]]; //white if the rom loaded but is not playing
			[self setStatusText:NSLocalizedString(@"ROM Loaded", nil)];
		}

		//add the rom to the recent documents list
		[[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:filename]];

		//update the rom info window, if needed
		[ROMInfo changeDS:nds];
	}

	return result;
}

- (BOOL)ROMLoaded
{
    return [nds ROMLoaded];
}

- (IBAction)execute:(id)sender
{
	[nds execute];

 	[self setStatusText:NSLocalizedString(@"Emulation Executing", nil)];
}

- (IBAction)pause:(id)sender
{
	[nds pause];

 	[self setStatusText:NSLocalizedString(@"Emulation Paused", nil)];
}

- (IBAction)reset:(id)sender
{
	[nds reset];

	//if we're paused, clear the screen to show we've reset
	//as opposed to just leaving whatever image is there
	if([nds paused])
	{
		[self setStatusText:NSLocalizedString(@"Emulation Reset", nil)];
		[nds_view setScreenState:[ScreenState whiteScreenState]];
	}
}

- (void)emulationError
{
	messageDialog(NSLocalizedString(@"Error", nil), NSLocalizedString(@"An emulation error occured", nil));
}

- (void)setFrameSkip:(int)frameskip
{
	[nds setFrameSkip:frameskip];
	frameskip = [nds frameSkip];
}

- (void)setFrameSkipFromMenuItem:(id)sender
{
	//FIXME
}

- (void)setSpeedLimit:(int)speedLimit
{
	[nds setSpeedLimit:speedLimit];

	//Set the correct menu states
	speedLimit = [nds speedLimit];
}

- (void)setSpeedLimitFromMenuItem:(id)sender
{

	/*if(sender == speed_limit_custom_item)
	{
		//create
		SpeedLimitSelectionWindow *s_window = [[SpeedLimitSelectionWindow alloc] initWithDS:self];

		//show & run
		NSWindowController *window_controller = [[NSWindowController alloc] initWithWindow:s_window];
		[window_controller showWindow:nil];
		[s_window runModal];

		//release
		[s_window release];
		[window_controller release];
	}*/
}

- (void)setSaveType:(int)savetype
{
	/*[super setSaveType:savetype];
	savetype = [super saveType];

	int i;
	for(i = 0; i < MAX_SAVE_TYPE; i++)
		if([save_type_item[i] target] == self)
			if(i == savetype)
				[save_type_item[i] setState:NSOnState];
			else
				[save_type_item[i] setState:NSOffState];
}

- (void)setSaveTypeFromMenuItem:(id)sender
{
	// Find the culprit
	int i;
	for(i = 0; i < MAX_SAVE_TYPE; i++)
		if(sender == save_type_item[i])
		{
			[self setSaveType:i];
			return;
		}*/
}


- (void)closeROM
{
	[nds closeROM];

	//reset window
	[nds_view setScreenState:[ScreenState blackScreenState]];
	[self setStatusText:NSLocalizedString(@"No ROM Loaded", nil)];

	//reset menu items
	/*if([window isMainWindow] == YES)
	{
		int i;
		for(i = 0; i < MAX_SLOTS; i++)
			[saveSlot_item[i] setState:NSOffState];

		[execute_item setState:NSOffState];
		[pause_item setState:NSOffState];
	}*/

	//close ROM info
	[ROMInfo closeROMInfo];
}

- (void)askAndCloseROM
{
	if(messageDialogYN(NSLocalizedString(@"DeSmuME Emulator", nil), NSLocalizedString(@"Are you sure you want to close the ROM?", nil)))
		[self closeROM];
}

- (BOOL)saveState:(NSString*)file
{
	return [nds saveState:file];
}

- (BOOL)loadState:(NSString*)file
{
	return [nds loadState:file];
}

- (BOOL)saveStateToSlot:(int)slot
{
	if([nds saveStateToSlot:slot] == YES)
	{
		//if([saveSlot_item[slot] target] == self);
		//	[saveSlot_item[slot] setState:NSOnState];

		//if([clear_all_saves_item target] == self);
		//[clear_all_saves_item setEnabled:YES];

		return YES;
	}

	return NO;
}

- (BOOL)loadStateFromSlot:(int)slot
{
	return [nds loadStateFromSlot:slot];
}

- (BOOL)saveStateAs
{
    //pause emulation so it doesnt save the state after
	BOOL was_executing = [nds executing];
	[nds pause];

	//file select
	NSSavePanel *panel = [NSSavePanel savePanel];
	[panel setTitle:NSLocalizedString(@"Save State...", nil)];
	[panel setRequiredFileType:@"DST"];

	//save it
	if([panel runModal] == NSFileHandlingPanelOKButton)
	{
		if(was_executing == YES)[nds execute];
		return [self saveState:[panel filename]];
	}

	//unpause emulation if needed
	if(was_executing == YES)[nds execute];

	return NO;
}

- (BOOL)loadStateFrom
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setTitle:NSLocalizedString(@"Load State From...", nil)];
	[panel setCanChooseFiles:YES];
	[panel setCanChooseDirectories:NO];
	[panel setAllowsMultipleSelection:NO];

	if([panel runModalForTypes:[NSArray arrayWithObject:@"DST"]] == NSFileHandlingPanelOKButton)
		return [self loadState:[panel filename]];

	return NO;
}

- (BOOL)saveToSlot:(id)menu_item
{
	//get the save slot by detecting which menu item sent the message
	int i;
	for(i = 0; i < MAX_SLOTS; i++)
		//if(menu_item == saveSlot_item[i])break;

	//quit if the message wasn't sent by a save state menu item
	if(i >= MAX_SLOTS)return NO;

	return [self saveStateToSlot:i];
}

- (BOOL)loadFromSlot:(id)menu_item
{
	int i;
	for(i = 0; i < MAX_SLOTS; i++)
		//if(menu_item == loadSlot_item[i])break;

	if(i >= MAX_SLOTS)return NO;

	return [self loadStateFromSlot:i];
}

- (NSPoint)windowPointToDSCoords:(NSPoint)location
{
	NSPoint p = [nds_view convertPoint:location fromView:nil];

	NSRect bounds = [nds_view bounds];
    CGFloat x_size = bounds.size.width;
    CGFloat y_size = bounds.size.height;
    
    if(p.y >= y_size / 2)
        return NSMakePoint(-1, -1);

    //scale the coordinates
    p.x *= ((float)DS_SCREEN_WIDTH) / ((float)x_size);
    p.y *= ((float)DS_SCREEN_HEIGHT_COMBINED) / ((float)y_size);

    //invert the y
    p.y = DS_SCREEN_HEIGHT - location.y - 1;

	return p;
}

- (IBAction)toggleConstrainProportions:(id)sender;
{
	//change the state
	keep_proportions = !keep_proportions;

	//constrain
	if(keep_proportions)
	{
        [window setFrame:[window frame] display:YES];
	}

	//set the menu checks
    [sender setState:keep_proportions?NSOnState:NSOffState];
}

- (IBAction)toggleTopBackground:(id)sender
{
    NSInteger i = [sender tag];
    if (i >= 0 && i <= 3)
    {
        SEL toggle = NSSelectorFromString([NSString stringWithFormat:@"toggleTopBackground%i", i]);
        [nds performSelector:toggle];
        if ([sender state] == NSOnState)
            [sender setState:NSOffState];
        else
            [sender setState:NSOnState];
    }
}

- (IBAction)toggleSubBackground:(id)sender
{
	NSInteger i = [sender tag];
    if (i >= 0 && i <= 3)
    {
        SEL toggle = NSSelectorFromString([NSString stringWithFormat:@"toggleSubBackground%i", i]);
        [nds performSelector:toggle];
        if ([sender state] == NSOnState)
            [sender setState:NSOffState];
        else
            [sender setState:NSOnState];
    }
}

- (void)saveScreenshot
{
	BOOL executing = [nds executing];
	[nds pause];

	[Screenshot saveScreenshotAs:[nds_view screenState]];

	if(executing == YES)[nds execute];
}

- (BOOL)windowShouldClose:(id)sender
{
	[sender hide];
	return FALSE;
}

- (void)windowDidResize:(NSNotification*)aNotification;
{
	if(nds_view == nil)return;
}

- (NSSize)windowWillResize:(NSWindow*)sender toSize:(NSSize)proposedFrameSize
{
	if(!keep_proportions)
        return proposedFrameSize;
    
    NSRect frameBounds = [sender frame];
    NSSize frameSize = frameBounds.size;
    
    NSRect viewBounds = [nds_view bounds];
    NSSize viewSize = viewBounds.size;
    
    CGFloat chromeWidth = frameSize.width - viewSize.width;
    CGFloat chromeHeight = frameSize.height - viewSize.height;
    
    NSSize proposedViewSize;
    proposedViewSize.width = proposedFrameSize.width - chromeWidth;
    proposedViewSize.height = proposedFrameSize.height - chromeHeight;
    
    NSSize constrainedSize;
    
    double n = proposedViewSize.height / (DS_SCREEN_HEIGHT_COMBINED / 2.0);
    double delta = n - round(n);
    
    if (fabs(delta) < .08)
        proposedViewSize.height = (n-delta) * (DS_SCREEN_HEIGHT_COMBINED / 2.0);
    
    constrainedSize.height = proposedViewSize.height + chromeHeight;
    constrainedSize.width = (proposedViewSize.height) * (DS_SCREEN_X_RATIO) + chromeWidth;

	return constrainedSize;
}

- (void)showRomInfo
{
	[ROMInfo showROMInfo:nds];
}

- (void)setVolume:(int)volume
{
	[nds setVolume:volume];
}

- (void)enableMute
{
	[nds enableMute];
}

- (void)disableMute
{
	[nds disableMute];
}

- (void)windowDidBecomeMain:(NSNotification*)notification
{
	//Update the ROM Info window
	if([nds ROMLoaded] == YES)
		[ROMInfo changeDS:nds];
	else
		[ROMInfo closeROMInfo];
}

- (BOOL)validateMenuItem:(NSMenuItem*)item
{
	//This function is called automatically by Cocoa
	//when it needs to know if a menu item should be greyed out

	/*int i;

	if([self ROMLoaded] == NO)
	{ //if no rom is loaded, various options are disabled
		if(item == close_rom_item)return NO;
		if(item == rom_info_item)return NO;
		if(item == save_state_as_item)return NO;
		if(item == load_state_from_item)return NO;
		for(i = 0; i < MAX_SLOTS; i++)
		{
			if(item == saveSlot_item[i])return NO;
			if(item == loadSlot_item[i])return NO;
		}

		if(item == execute_item)return NO;
		if(item == pause_item)return NO;
		if(item == reset_item)return NO;

		if(item == screenshot_to_file_item)return NO;
	}

	else
		for(i = 0; i < MAX_SLOTS; i++)
			if(item == loadSlot_item[i])
				if([self saveStateExists:i]==NO)return NO;

	if(nds_view == nil)
	{
		if(item == resize1x)return NO;
		if(item == resize2x)return NO;
		if(item == resize3x)return NO;
		if(item == resize4x)return NO;
		if(item == constrain_item)return NO;
		if(item == rotation0_item)return NO;
		if(item == rotation90_item)return NO;
		if(item == rotation180_item)return NO;
		if(item == rotation270_item)return NO;
		if(item == screenshot_to_file_item)return NO;
	}
	
	if([self hasSound] == NO)
	{
		if(item == mute_item)return NO;
		for(i = 0; i < 10; i++)if(item == volume_item[i])return NO;
	}*/

	return YES;
}

@end
