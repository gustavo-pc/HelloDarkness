//
//  DynamicBufferList.c
//  Hello Darkness
//
//  Created by gustavo on 6/17/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

#include "DynamicBufferList.h"




void initalizeDynamicBufferList(DynamicAudioBufferList *bufferList){
    bufferList->mCurrentBuffers = 0;
    bufferList->mPlayPosition = 0;
}

void addBuffer(AudioBuffer buffer, DynamicAudioBufferList *inBufferList, dispatch_semaphore_t usingSemaphore){
    dispatch_semaphore_wait(usingSemaphore, DISPATCH_TIME_NOW);
    
    inBufferList->mBuffers[inBufferList->mCurrentBuffers].mData = malloc(buffer.mDataByteSize);
    
    memcpy(inBufferList->mBuffers[inBufferList->mCurrentBuffers].mData, buffer.mData, buffer.mDataByteSize);
    inBufferList->mBuffers[inBufferList->mCurrentBuffers].mDataByteSize = buffer.mDataByteSize;
    inBufferList->mBuffers[inBufferList->mCurrentBuffers].mNumberChannels = buffer.mNumberChannels;
    inBufferList->mCurrentBuffers++;
    
    printf("adicionei na posicao %i\n", (unsigned int)inBufferList->mCurrentBuffers);
    
    if (inBufferList->mCurrentBuffers >= DBL_CAPACITY) {
        inBufferList->mCurrentBuffers = 0;
    }
    
    dispatch_semaphore_signal(usingSemaphore);
}

AudioBuffer retrieveBuffer(DynamicAudioBufferList *fromBufferList, dispatch_semaphore_t usingSemaphore){
    AudioBuffer retrieved;
    retrieved.mDataByteSize = 0;
    retrieved.mNumberChannels = 0;

    dispatch_semaphore_wait(usingSemaphore, DISPATCH_TIME_NOW);
    
    if (fromBufferList->mPlayPosition < fromBufferList->mCurrentBuffers) {
        retrieved.mDataByteSize = fromBufferList->mBuffers[fromBufferList->mPlayPosition].mDataByteSize;
        retrieved.mNumberChannels = fromBufferList->mBuffers[fromBufferList->mPlayPosition].mNumberChannels;
        retrieved.mData = malloc(fromBufferList->mBuffers[fromBufferList->mPlayPosition].mDataByteSize);
        memcpy(retrieved.mData, fromBufferList->mBuffers[fromBufferList->mPlayPosition].mData, fromBufferList->mBuffers[fromBufferList->mPlayPosition].mDataByteSize);
        fromBufferList->mPlayPosition++;
        
        printf("lendo na posicao %i\n", (unsigned int)fromBufferList->mPlayPosition);
    }
    
    if (fromBufferList->mPlayPosition >= DBL_CAPACITY) {
        fromBufferList->mPlayPosition = 0;
    }
    
    dispatch_semaphore_signal(usingSemaphore);
    return retrieved;
}