//
//  AudioStreamRecorder.h
//  Hello Darkness
//
//  Created by gustavo on 6/3/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>





@class AudioStreamRecorder;

@protocol AudioStreamRecorderDelegate <NSObject>

- (void)audioStreamRecorder:(AudioStreamRecorder *)recorder didRenderNewBuffer:(AudioBuffer)buffer;

@end


@interface AudioStreamRecorder : NSObject{
@public AudioUnit myUnit;
    
}



@property BOOL outputMuted;

@property id<AudioStreamRecorderDelegate> delegate;

- (void) beAwesome;

- (void) pauseAwesomeness;

- (void) deliverBuffer:(AudioBuffer)deliveredBuffer;

@end


