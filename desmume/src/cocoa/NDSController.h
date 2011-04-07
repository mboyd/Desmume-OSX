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

#import "NintendoDS.h"

#define DS_SCREEN_HEIGHT_COMBINED (192*2) /*height of the two screens*/
#define DS_SCREEN_X_RATIO (256.0 / (192.0 * 2.0))
#define DS_SCREEN_Y_RATIO ((192.0 * 2.0) / 256.0)

@class NDSView;
@class InputHandler;

// Backup media type array length
#define MAX_SAVE_TYPE 7


//This interface is to create and manaage the window
//that displays DS video output and takes keyboard/mouse input
//do not instanciate more than one of these
@interface NDSController : NSObject <NSWindowDelegate>
{
    NintendoDS *nds;
    
    IBOutlet NSWindow *window;
	IBOutlet NDSView *nds_view;
    
	@private
    
    NSTextField *status_view;
    
    NSWindowController *controller;
	NSString *status_bar_text;
	InputHandler *input;

	bool no_smaller_than_ds;
	bool keep_proportions;
}

//initialization
- (void)awakeFromNib;

- (NintendoDS*) ds;
- (NDSView*) view;

- (BOOL)loadROM:(NSString*)filename;
- (BOOL)ROMLoaded;

- (IBAction)execute:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)reset:(id)sender;

- (void)setFrameSkip:(int)frameskip;
- (void)setSaveType:(int)savetype;
- (void)closeROM;

//save features overloaded from nds class
- (BOOL)saveState:(NSString*)file;
- (BOOL)loadState:(NSString*)file;
- (BOOL)saveStateToSlot:(int)slot; //0 to MAX_SLOTS-1, anything else is ignored
- (BOOL)loadStateFromSlot:(int)slot;

//save functions for the program menu to callback to
- (BOOL)saveStateAs;
- (BOOL)loadStateFrom;

//converts window coords to DS coords (returns -1, -1 if invalid)
- (NSPoint)windowPointToDSCoords:(NSPoint)location;

- (IBAction)toggleConstrainProportions:(id)sender;

//layers
- (IBAction)toggleTopBackground:(id)sender;
- (IBAction)toggleSubBackground:(id)sender;

//screenshots
- (IBAction)saveScreenshot: (id)sender;

//delegate
- (void)windowDidBecomeMain:(NSNotification*)notification;

@end
