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

#import "input.h"
#import "NDSController.h"
#import "DesmumePreferencesController.h"

@implementation InputHandler

- (id)init
{
	//make sure we go through through the designated init function
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithController:(NDSController*)nds
{
	self = [super init];
	
	my_controller = nds;
	[my_controller retain];
    
    my_ds = [nds ds];
    [my_ds retain];
	
	return self;
}

- (void)dealloc
{
	[my_ds release];
    [my_controller release];
	[super dealloc];
}

- (void)keyDown:(NSEvent*)event
{
	if([event isARepeat])
        return;
    
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	NSString *chars = [event characters];
	
         if([chars isEqualToString:[settings stringForKey:PREF_KEY_A     ]])[my_ds pressA];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_B     ]])[my_ds pressB];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_SELECT]])[my_ds pressSelect];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_START ]])[my_ds pressStart];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_RIGHT ]])[my_ds pressRight];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_LEFT  ]])[my_ds pressLeft];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_UP    ]])[my_ds pressUp];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_DOWN  ]])[my_ds pressDown];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_R     ]])[my_ds pressR];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_L     ]])[my_ds pressL];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_X     ]])[my_ds pressX];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_Y     ]])[my_ds pressY];
}

- (void)keyUp:(NSEvent*)event
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	NSString *chars = [event characters];
	
	     if([chars isEqualToString:[settings stringForKey:PREF_KEY_A     ]])[my_ds liftA];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_B     ]])[my_ds liftB];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_SELECT]])[my_ds liftSelect];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_START ]])[my_ds liftStart];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_RIGHT ]])[my_ds liftRight];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_LEFT  ]])[my_ds liftLeft];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_UP    ]])[my_ds liftUp];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_DOWN  ]])[my_ds liftDown];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_R     ]])[my_ds liftR];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_L     ]])[my_ds liftL];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_X     ]])[my_ds liftX];
	else if([chars isEqualToString:[settings stringForKey:PREF_KEY_Y     ]])[my_ds liftY];
}

- (void)mouseDown:(NSEvent*)event
{
	NSPoint p = [event locationInWindow];
    NSPoint ds_p = [my_controller windowPointToDSCoords:p];
    
	if(ds_p.x >= 0 && ds_p.y>=0)
        [my_ds touch:ds_p];
}

- (void)mouseDragged:(NSEvent*)event
{
	[self mouseDown:event];
}

- (void)mouseUp:(NSEvent*)event
{
	[my_ds releaseTouch];
}

@end

