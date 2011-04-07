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

#import "NDSView.h"
#import "screen_state.h"

#define HORIZONTAL(angle) ((angle) == -90 || (angle) == -270)
#define VERTICAL(angle) ((angle) == 0 || (angle) == -180)

#import <OpenGL/gl.h>

//screenstate extended to hold rotated copies
@interface ScreenState(extended)
- (void)rotateTo90;
- (void)rotateTo0;
@end

@implementation NDSView

- (id)initWithFrame:(NSRect)frame
{
    //Create the pixel format for our video output view
    NSOpenGLPixelFormatAttribute attrs[] =
    {
        //NSOpenGLPFAFullScreen,
        NSOpenGLPFAWindow, //need a renderer that can draw to a window
        //NSOpenGLPFARendererID, some_number, //this picks a particular renderer, for testing
        (NSOpenGLPixelFormatAttribute)0
    };
    
    NSOpenGLPixelFormat* pixel_format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    if(pixel_format == nil)
    {
        messageDialog(NSLocalizedString(@"Error", nil), @"Couldn't create OpenGL pixel format for video output");
        return nil;
    }

	self = [super initWithFrame:frame pixelFormat:pixel_format];
    
    [pixel_format release];

	if(self==nil)
	{
		messageDialog(NSLocalizedString(@"Error", nil), @"Couldn't create a view for video output");
		return nil;
	}

	//init screen buffer
	[self setScreenState:[ScreenState blackScreenState]];
    
    //setup bounds
    [self setFrame:frame];

	return self;
}

- (void)drawRect:(NSRect)bounds
{
	if(screen_buffer == nil)
        return; //simply dont draw anything if we dont have a screen data object allocated
    
    
	[[self openGLContext] makeCurrentContext];
    
	if([self boundsRotation] == 0 || [self boundsRotation] == -180)
	{
		//here we send our corrected video buffer off to OpenGL where it gets pretty much
		//directly copied to the frame buffer (and converted to the devices color format)
		glDrawPixels(DS_SCREEN_WIDTH, DS_SCREEN_HEIGHT*2, GL_RGBA, GL_UNSIGNED_SHORT_1_5_5_5_REV, (const GLvoid*)[screen_buffer colorData]);
	} else
	{
		glDrawPixels(DS_SCREEN_HEIGHT*2, DS_SCREEN_WIDTH, GL_RGBA, GL_UNSIGNED_SHORT_1_5_5_5_REV, (const GLvoid*)[screen_buffer colorData]);
	}
    
	glFlush();
}

- (void)dealloc
{
	[screen_buffer release];

	[super dealloc];
}

- (void)setScreenState:(ScreenState*)screen
{
	if(screen_buffer == screen)return;

	if(screen == nil)
	{
		messageDialog(NSLocalizedString(@"Error", nil), @"Recieved invalid screen update");
		return;
	}

	[screen_buffer release]; //get rid of old screen data
	screen_buffer = screen;
	[screen_buffer retain]; //retain the new screendata since we will need it if we have to redraw before we recieve another update

	//rotate the screen
	if(HORIZONTAL([self boundsRotation]))
        [screen_buffer rotateTo90];

	//redraw
	[self display];
}

- (const ScreenState*)screenState
{
	ScreenState *temp = [[ScreenState alloc] initWithScreenState:screen_buffer];
	if(HORIZONTAL([self boundsRotation]))[temp rotateTo0];
	return temp;
}

- (float)screenWidth
{
	return DS_SCREEN_WIDTH;
}

- (float)screenHeight
{
	return DS_SCREEN_HEIGHT*2;
}

- (void)setFrame:(NSRect)rect
{
	[super setFrame:rect];

	[[self openGLContext] makeCurrentContext];
	[[self openGLContext] update];

	//set the viewport (so the raster pos will be correct)
	glViewport(0, 0, rect.size.width, rect.size.height);

	float angle = [self boundsRotation];

	if(angle == 0)
	{
		glRasterPos2f(-1, 1);
		glPixelZoom(((float)rect.size.width) / ((float)DS_SCREEN_WIDTH), -((float)rect.size.height) / ((float)DS_SCREEN_HEIGHT*2));
	} else if(angle == -90)
	{
		glRasterPos2f(-1, 1);
		glPixelZoom(((float)rect.size.width) / ((float)DS_SCREEN_HEIGHT*2), -((float)rect.size.height) / ((float)DS_SCREEN_WIDTH));
	} else if (angle == -180)
	{
		glRasterPos2f(1, -1);
		glPixelZoom(-((float)rect.size.width) / ((float)DS_SCREEN_WIDTH), ((float)rect.size.height) / ((float)DS_SCREEN_HEIGHT*2));
	} else if (angle == -270)
	{
		glRasterPos2f(1, -1);
		glPixelZoom(-((float)rect.size.width) / ((float)DS_SCREEN_HEIGHT*2), ((float)rect.size.height) / ((float)DS_SCREEN_WIDTH));
	}
}

- (BOOL)isOpaque
{
	if(screen_buffer)
		return YES;

	//if there is no screen buffer, then we can't draw anything
	//so this view is completely transparent
	return NO;
}

- (void)setBoundsRotation:(CGFloat)angle
{
	float old_angle = [self boundsRotation];

	[super setBoundsRotation:angle];

	//[context makeCurrentContext];

	NSSize size = [self frame].size;

	if(angle == 0)
	{
		glRasterPos2f(-1, 1);
		glPixelZoom(((float)size.width) / ((float)DS_SCREEN_WIDTH), -((float)size.height) / ((float)DS_SCREEN_HEIGHT*2));
	} else if(angle == -90)
	{
		glRasterPos2f(-1, 1);
		glPixelZoom(((float)size.width) / ((float)DS_SCREEN_HEIGHT*2), -((float)size.height) / ((float)DS_SCREEN_WIDTH));
	} else if (angle == -180)
	{
		glRasterPos2f(1, -1);
		glPixelZoom(-((float)size.width) / ((float)DS_SCREEN_WIDTH), ((float)size.height) / ((float)DS_SCREEN_HEIGHT*2));
	} else if (angle == -270)
	{
		glRasterPos2f(1, -1);
		glPixelZoom(-((float)size.width) / ((float)DS_SCREEN_HEIGHT*2), ((float)size.height) / ((float)DS_SCREEN_WIDTH));
	}

	//Rotate the screen buffer
	if(HORIZONTAL(angle) && VERTICAL(old_angle))
		[screen_buffer rotateTo90];

	if(VERTICAL(angle) && HORIZONTAL(old_angle))
		[screen_buffer rotateTo0];
}

@end

@implementation ScreenState (extended)
- (void)rotateTo90
{
	int width = [ScreenState width], height = [ScreenState height];

	unsigned char temp_buffer[width * height * DS_BPP];
	memcpy(temp_buffer, color_data, width * height * DS_BPP);

	int x, y;
	for(x = 0; x< width; x++)
		for(y = 0; y < height; y++)
		{
			color_data[(x * height + (height - y - 1)) * 2] = temp_buffer[(y * width + x) * 2];
			color_data[(x * height + (height - y - 1)) * 2 + 1] = temp_buffer[(y * width + x) * 2 + 1];
		}
}

- (void)rotateTo0
{
	int height = [ScreenState width], width = [ScreenState height];

	unsigned char temp_buffer[width * height * DS_BPP];
	memcpy(temp_buffer, color_data, width * height * DS_BPP);

	int x, y;
	for(x = 0; x< width; x++)
		for(y = 0; y < height; y++)
		{
			color_data[((width - x - 1) * height + y) * 2] = temp_buffer[(y * width + x) * 2];
			color_data[((width - x - 1) * height + y) * 2 + 1] = temp_buffer[(y * width + x) * 2 + 1];
		}
}
@end
