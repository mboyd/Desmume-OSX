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

/*
 This file is part of the Cocoa (Mac OS X) port of DeSmuME emulator
 By Jeff Bland
 Based on work by yopyop and the DeSmuME team!
 Mac related questions can go to osx@desmume.org
 */

#import "DemumeAppDelegate.h"

@implementation DesmumeAppDelegate

- (IBAction) pickROM: (id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
    
	[panel setCanChooseDirectories:NO];
	[panel setCanChooseFiles:YES];
	[panel setAllowsMultipleSelection:NO];
    
	[panel setTitle:NSLocalizedString(@"Open ROM...", nil)];
    
	if([panel runModalForDirectory:nil file:nil types:[NSArray arrayWithObjects:@"NDS", @"DS.GBA", nil]] == NSOKButton)
	{
		NSString* selected_file = [[panel filenames] lastObject]; //hopefully also the first object
        
		[self application:NSApp openFile:selected_file];
	}
}

- (IBAction) pickFlash: (id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
    
	[panel setCanChooseDirectories:NO];
	[panel setCanChooseFiles:YES];
	[panel setAllowsMultipleSelection:NO];
    
	[panel setTitle:NSLocalizedString(@"Set FAT Image File...", nil)];
    
	if([panel runModalForDirectory:nil file:nil types:[NSArray arrayWithObjects:@"FAT", @"IMG", nil]] == NSOKButton)
	{
		NSString* selected_file = [[panel filenames] lastObject];
        
		[main_window setFlashFile:selected_file];
	}
}

- (BOOL)application:(NSApplication*)sender openFile:(NSString*)filename
{
	//verify everything
	if(sender != NSApp)return NO;
	if(!filename)return NO;
	if([filename length] == 0)return NO;
    
	if([main_window loadROM:filename])
	{
		//[main_window execute];
		return YES;
	}
    
	return NO;
}

- (void)application:(NSApplication*)sender openFiles:(NSArray*)filenames
{
	NSString *filename;
    //verify everything
	if(sender != NSApp)goto fail;
	if(!filenames)goto fail;
	if([filenames count] == 0)goto fail;
	filename = [filenames lastObject];
	if(!filename)goto fail;
	if([filename length] == 0)goto fail;
    
	if([main_window loadROM:filename])
	{
		//[main_window execute];
		[sender replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
		return;
	}
    
fail:
	[sender replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
}

- (IBAction) showPreferences:(id)sender
{
    [NSBundle loadNibNamed:@"Preferences" owner:self];
}

- (void)applicationWillFinishLaunching:(NSNotification*)notification
{
	//Set default values for all preferences
	//(this wont override saved preferences as
	//they work in different preference domains)
	[DesmumePreferencesController setAppDefaults];
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
	//Bring the application to the front
	[NSApp activateIgnoringOtherApps:TRUE];
	
	//check if it should load something by default
	if([[[NSUserDefaults standardUserDefaults] stringForKey:PREF_AFTER_LAUNCHED] compare:PREF_AFTER_LAUNCHED_OPTION_LAST_ROM]==NSOrderedSame)
	{
		NSArray *recent_documents = [[NSDocumentController sharedDocumentController] recentDocumentURLs];
		
		if([recent_documents count] > 0)
		{
			//we have to convert from a URL to file path. in the future, URL's ought to be used since they are more capable/robust...
			
			NSString *file = [[recent_documents objectAtIndex:0] absoluteString]; //gets it in url form
			file = [file stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; //convert escaped characters in url
			file = [file substringFromIndex:16]; //gets rid of "File://localhost" url component (there should be a much better way to do this....)
			
			[main_window loadROM:file];
		}
	}
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender
{
	//Ask user about quitting if a rom is loaded (avoid accidentally quiting with unsaved progress)
	if([main_window ROMLoaded])
        if(!messageDialogYN(NSLocalizedString(@"DeSmuME Emulator", nil), NSLocalizedString(@"Are you sure you want to quit?", nil)))
            return NSTerminateCancel;
    
    bool result = [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"Synchronized: %i", (int)result);
    [main_window release];
    
	return NSTerminateNow;
}

@end
