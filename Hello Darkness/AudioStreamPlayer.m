//
//  AudioStreamPlayer.m
//  Hello Darkness
//
//  Created by gustavo on 6/3/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioStreamPlayer.h"

dispatch_semaphore_t mutex;

static OSStatus playbackCallback (void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData){
    
    AudioStreamPlayer *player = (__bridge AudioStreamPlayer *)inRefCon;
    
    AudioBuffer dequeued = retrieveBuffer(&(player->unplayedBuffers), mutex);
    
    if (dequeued.mDataByteSize != 0){
        memcpy(ioData->mBuffers[0].mData, dequeued.mData, dequeued.mDataByteSize);
//        free(dequeued.mData);
    }
    else {
        *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
        memset(ioData->mBuffers[0].mData, 0, sizeof(ioData->mBuffers[0].mData));
    }
    
    return 0;
}

@implementation AudioStreamPlayer

#pragma mark Setup

- (void)configureAudioSession{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *err;
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&err];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error: &err];
    [session setPreferredSampleRate:44100.0 error: &err];
    [session setActive:YES error:&err];
}

- (void)setupPlaybackUnit {
    
    OSStatus errorCheck;
    
    AudioComponentDescription acd = [self remoteIODescription];
    
    AudioComponent remoteIOFactory = AudioComponentFindNext(NULL, &acd);
    
    errorCheck = AudioComponentInstanceNew(remoteIOFactory, &playbackUnit);
    [self checkForError:errorCheck];
    
    AURenderCallbackStruct callback;
    callback.inputProc = playbackCallback;
    callback.inputProcRefCon = (__bridge void *)self;
    errorCheck = AudioUnitSetProperty(playbackUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callback, sizeof(AURenderCallbackStruct));
    
    AudioStreamBasicDescription asbd = [self streamDescription];
    errorCheck = AudioUnitSetProperty(playbackUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &asbd, sizeof(AudioStreamBasicDescription));
    [self checkForError:errorCheck];
    
    
}

#pragma mark Auxiliar

- (AudioComponentDescription)remoteIODescription {
    
    AudioComponentDescription desc = {0};
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    
    return desc;
}

- (AudioStreamBasicDescription)streamDescription {
    AudioStreamBasicDescription description = {0};
    description.mSampleRate = 44100.0;
    description.mFormatID = kAudioFormatLinearPCM;
    description.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    description.mFramesPerPacket	= 1;
    description.mChannelsPerFrame	= 1;
    description.mBitsPerChannel		= 16;
    description.mBytesPerPacket		= 2;
    description.mBytesPerFrame		= 2;
    
    return description;
}

- (void)checkForError:(OSStatus)status {
    if (status != noErr) {
        printf("%d: Deu merda\n", (int)status);
    }
}

#pragma mark Public API

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureAudioSession];
        [self setupPlaybackUnit];
        
        initalizeDynamicBufferList(&unplayedBuffers);
        _accumulatedBuffersBeforeStarting = 0;
        
        mutex = dispatch_semaphore_create(1);
        
    }
    return self;
}

- (void)startReceivingAudio{
    if (_accumulatedBuffersBeforeStarting == 0) {
        printf("liguei no start\n");
        AudioOutputUnitStart(playbackUnit);
    }
}

- (void)stopReceivingAudio{
    AudioOutputUnitStop(playbackUnit);
}

-(void)enqueueBuffer:(AudioBuffer)buffer{

    addBuffer(buffer, &(unplayedBuffers), mutex);
    
    
    if (_accumulatedBuffersBeforeStarting == unplayedBuffers.mCurrentBuffers) {
        AudioOutputUnitStart(playbackUnit);
//        printf("liguei por codigo\n");
    }
    
}

@end