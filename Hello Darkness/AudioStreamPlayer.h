//
//  AudioStreamPlayer.h
//  Hello Darkness
//
//  Created by gustavo on 6/3/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AudioStreamRecorder.h"
#import "DynamicBufferList.h"

@import AVFoundation;


@interface AudioStreamPlayer : NSObject <NSStreamDelegate> {
    AudioUnit playbackUnit;
    NSArray *receivedBuffers;
    
    @public DynamicAudioBufferList unplayedBuffers;
    @public NSInputStream *inputStream;
}


@property int accumulatedBuffersBeforeStarting;

- (void)startReceivingAudio;

- (void)stopReceivingAudio;

- (void)enqueueBuffer:(AudioBuffer)buffer;

- (void)setInputStream:(NSInputStream *)newStream;

#pragma mark Testing Stuff
- (void)readAndPrint;

@end