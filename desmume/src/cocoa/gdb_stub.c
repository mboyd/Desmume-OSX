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

#ifdef GDB_STUB

#include <pthread.h>

//GDB Stub implementation----------------------------------------------------------------------------

void * createThread_gdb(void (*thread_function)( void *data),void *thread_data)
{
    // Create the thread using POSIX routines.
    pthread_attr_t  attr;
    pthread_t*      posixThreadID = (pthread_t*)malloc(sizeof(pthread_t));
    
    assert(!pthread_attr_init(&attr));
    assert(!pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE));
    
    int threadError = pthread_create(posixThreadID, &attr, (void* (*)(void *))thread_function, thread_data);
    
    assert(!pthread_attr_destroy(&attr));
    
    if (threadError != 0)
    {
        // Report an error.
        return NULL;
    }
    else
    {
        return posixThreadID;
    }
}

void joinThread_gdb( void *thread_handle)
{
    pthread_join(*((pthread_t*)thread_handle), NULL);
    free(thread_handle);
}

#endif