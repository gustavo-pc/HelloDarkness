//
//  AudioStreamRecorder.m
//  Hello Darkness
//
//  Created by gustavo on 6/3/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

#import "AudioStreamRecorder.h"
#import <AVFoundation/AVFoundation.h>



static OSStatus mySelfWrittenCallback(void *inRefCon,
                                      AudioUnitRenderActionFlags *ioActionFlags,
                                      const AudioTimeStamp *inTimeStamp,
                                      UInt32 inBusNumber,
                                      UInt32 inNumberFrames,
                                      AudioBufferList *ioData) {
    
    AudioStreamRecorder *recorder = (__bridge AudioStreamRecorder *)(inRefCon);
    
    ///Audio data will be rendered here
    AudioBuffer temporaryBuffer;
    temporaryBuffer.mNumberChannels = 1;
    temporaryBuffer.mDataByteSize = inNumberFrames * 2;
    temporaryBuffer.mData = malloc(inNumberFrames * 2);
    
    ///Declaring this just because AudioUnitRender only works with AudioBufferList
    AudioBufferList temporaryBufferList;
    temporaryBufferList.mNumberBuffers = 1;
    temporaryBufferList.mBuffers[0] = temporaryBuffer;

    
    AudioUnitRender(recorder->myUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, &temporaryBufferList);
    
    
    
    if (!recorder.outputMuted) {
        memcpy(ioData->mBuffers[0].mData, temporaryBuffer.mData, temporaryBuffer.mDataByteSize);
        //    ioData->mBuffers[0].mData = temporaryBuffer.mData;
    }else {
        *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
    }
    
    [recorder deliverBuffer:temporaryBuffer];
    
    return 0;
}


@implementation AudioStreamRecorder


#pragma mark Setup

- (void)configureAudioSession{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *err;
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&err];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error: &err];
    [session setPreferredSampleRate:44100.0 error: &err];
    [session setActive:YES error:&err];
    
    //    NSLog(@"Current sample rate: %f", session.sampleRate);
}

- (void)configureAudioUnitsWithCallback{
    
    OSStatus errorCheck;
    
    AudioComponentDescription acd = [self remoteIODescription];
    
    AudioComponent remoteIOFactory = AudioComponentFindNext(NULL, &acd);
    
    errorCheck = AudioComponentInstanceNew(remoteIOFactory, &myUnit);
    [self checkForError:errorCheck];
    
    UInt32 enableIO = 1;
    errorCheck = AudioUnitSetProperty(myUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &enableIO, sizeof(UInt32));
    [self checkForError:errorCheck];
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = mySelfWrittenCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    errorCheck = AudioUnitSetProperty(myUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callbackStruct, sizeof(AURenderCallbackStruct));
    [self checkForError:errorCheck];
    
    AudioStreamBasicDescription asbd = [self streamDescription];
    errorCheck = AudioUnitSetProperty(myUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &asbd, sizeof(asbd));
    errorCheck = AudioUnitSetProperty(myUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &asbd, sizeof(asbd));
    [self checkForError:errorCheck];
    
    errorCheck = AudioUnitInitialize(myUnit);
    [self checkForError:errorCheck];
    
    printf("A a o S m g\n");
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

- (instancetype)init{
    self = [super init];
    if (self) {
        [self configureAudioSession];
        [self configureAudioUnitsWithCallback];
        _outputMuted = NO;
    }
    return self;
}

- (void)beAwesome{
    AudioOutputUnitStart(myUnit);
}

- (void)pauseAwesomeness{
    AudioOutputUnitStop(myUnit);
}

- (void)deliverBuffer:(AudioBuffer)deliveredBuffer{
    
    //tem que duplicar a regiao de memoria que contem os dados tbm
    //e colocar o ponteiro pra la na struct
    
    //    NSData *bufferData = [NSData dataWithBytes:deliveredBuffer.mData length:deliveredBuffer.mDataByteSize];
    
    [self.delegate audioStreamRecorder:self didRenderNewBuffer:deliveredBuffer];
    
}

- (void) muteOutput {
    
}

@end
