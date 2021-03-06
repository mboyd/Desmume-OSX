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

#import <Cocoa/Cocoa.h>


//Main Function--------------------------------------------------------------------------------------

int main(int argc, char *argv[])
{
	srand(time(NULL));
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	int result = NSApplicationMain(argc, (const char**)argv);
	
	[pool release];
	
	return result;
}
