//
//  Recorder.h
//  Hello Darkness
//
//  Created by gustavo on 6/1/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

#ifndef Hello_Darkness_Recorder_h
#define Hello_Darkness_Recorder_h


#endif

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define SAMPLE_RATE 44100.0

@interface Recorder : NSObject{
    @public AudioBuffer brinca;
    @public AUGraph graficozinho;
    @public AudioUnit myUnit;
}


- (instancetype)initUsingAudioGraph;

- (instancetype)initUsingAudioUnitsWithCallback:(BOOL)callbackEnabled;

- (void) beAwesome;

- (void) pauseAwesomeness;

- (void) checkForError:(OSStatus)status;

@end