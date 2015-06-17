//
//  DynamicBufferList.h
//  Hello Darkness
//
//  Created by gustavo on 6/17/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

#ifndef __Hello_Darkness__DynamicBufferList__
#define __Hello_Darkness__DynamicBufferList__

#include <stdio.h>
#include <AudioToolbox/AudioToolbox.h>

#endif /* defined(__Hello_Darkness__DynamicBufferList__) */


#define DBL_CAPACITY 500


typedef struct DynamicAudioBufferList{
    UInt32      mCurrentBuffers;
    AudioBuffer mBuffers[DBL_CAPACITY];
    UInt32      mPlayPosition;
    
} DynamicAudioBufferList;


void initalizeDynamicBufferList(DynamicAudioBufferList bufferList);

void addBuffer(AudioBuffer buffer, DynamicAudioBufferList inBufferList, dispatch_semaphore_t usingSemaphore);

AudioBuffer retrieveBuffer(DynamicAudioBufferList fromBufferList, dispatch_semaphore_t usingSemaphore);