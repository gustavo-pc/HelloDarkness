//
//  Recorder.m
//  Hello Darkness
//
//  Created by gustavo on 6/1/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

#import "Recorder.h"
@import AVFoundation;
@import CoreAudio;

AudioUnit unidade;

static OSStatus mySelfWrittenCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    
    AudioUnitRender(unidade, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
    
    return 0;
}



@implementation Recorder{
    int usedInit;
}


// Init #0
- (void)configureAudioGraph{
    OSStatus errorCheck;
    
    //Criando um grafico
    errorCheck = NewAUGraph(&graficozinho);
    [self checkForError:errorCheck];
    
    
    //Adicionando ao gráfico um nó que representa a
    AUNode ioNode;
    AudioComponentDescription rIODescription = [self remoteIODescription];
    errorCheck = AUGraphAddNode(graficozinho, &rIODescription, &ioNode);
    [self checkForError:errorCheck];
    
    
    //Abrindo o Grafico
    errorCheck = AUGraphOpen(graficozinho);
    [self checkForError:errorCheck];
    
    
    //Recuperando a instancia da unidade para uma variavel da classe
    errorCheck = AUGraphNodeInfo(graficozinho, ioNode, &rIODescription, &myUnit);
    [self checkForError:errorCheck];
    
    
    //Habilitando o I/O no barramento de entrada da unidade
    UInt32 enableIO = 1; //true
    errorCheck =  AudioUnitSetProperty(myUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &enableIO, sizeof(enableIO));
    [self checkForError:errorCheck];
    
    
    //Conectando a entrada da unidade à sua saida
    errorCheck = AUGraphConnectNodeInput(graficozinho, ioNode, 1, ioNode, 0);
    [self checkForError:errorCheck];
    
    //Inicializando o grafico
    errorCheck = AUGraphInitialize(graficozinho);
    [self checkForError:errorCheck];
    
    usedInit = 0;
    
}

// Init #1
- (void)configureAudioUnit{
    OSStatus errorCheck;
    
    AudioComponentDescription acd = [self remoteIODescription];
    AudioComponent remoteComponent = AudioComponentFindNext(NULL, &acd);
    
    errorCheck = AudioComponentInstanceNew(remoteComponent, &myUnit);
    [self checkForError:errorCheck];
    
    UInt32 enableIO = 1; //true
    errorCheck = AudioUnitSetProperty(myUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &enableIO, sizeof(enableIO));
    
    AudioUnitConnection connection;
    connection.sourceAudioUnit = myUnit;
    connection.destInputNumber = 0;
    connection.sourceOutputNumber = 1;
    
    errorCheck = AudioUnitSetProperty(myUnit, kAudioUnitProperty_MakeConnection, kAudioUnitScope_Output, 0, &connection, sizeof(connection));
    [self checkForError:errorCheck];
    
    errorCheck = AudioUnitInitialize(myUnit);
    [self checkForError:errorCheck];
    
    usedInit = 1;
    
}

// Init #2
- (void)configureAudioUnitsWithCallback{
  
    OSStatus errorCheck;
    
    AudioComponentDescription acd = [self remoteIODescription];
    
    AudioComponent remoteIOFactory = AudioComponentFindNext(NULL, &acd);
    
    errorCheck = AudioComponentInstanceNew(remoteIOFactory, &unidade);
    [self checkForError:errorCheck];
    
    UInt32 enableIO = 1;
    errorCheck = AudioUnitSetProperty(unidade, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &enableIO, sizeof(UInt32));
    [self checkForError:errorCheck];
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = mySelfWrittenCallback;
    callbackStruct.inputProcRefCon = NULL;
    errorCheck = AudioUnitSetProperty(unidade, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callbackStruct, sizeof(AURenderCallbackStruct));
    [self checkForError:errorCheck];
    
    AudioStreamBasicDescription asbd = [self streamDescription];
    errorCheck = AudioUnitSetProperty(unidade, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &asbd, sizeof(asbd));
    errorCheck = AudioUnitSetProperty(unidade, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &asbd, sizeof(asbd));
    [self checkForError:errorCheck];
    
    printf("A a o S m g\n");
    usedInit = 2;
}


- (void)checkForError:(OSStatus)status {
    if (status != noErr) {
        printf("%d: Deu merda\n", (int)status);
    }
}

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

- (void)configureAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *err;
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&err];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error: &err];
    [session setPreferredSampleRate:44100.0 error: &err];
    [session setActive:YES error:&err];
    
    //    NSLog(@"Current sample rate: %f", session.sampleRate);
}

#pragma mark Public API

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initUsingAudioGraph{
    self = [super init];
    if (self) {
        [self configureAudioSession];
        [self configureAudioGraph];
    }
    
    return self;
}

- (instancetype)initUsingAudioUnitsWithCallback:(BOOL)callbackEnabled{
    self = [super init];
    if (self){
        [self configureAudioSession];
        if (callbackEnabled) {
            [self configureAudioUnitsWithCallback];
        }
        else {
            [self configureAudioUnit];
        }
    }
    
    return self;
}

- (void) beAwesome {
    OSStatus errorCheck;
    
    switch (usedInit) {
        case 0:
            errorCheck = AUGraphStart(graficozinho);
            [self checkForError:errorCheck];
            break;
        case 1:
            errorCheck = AudioOutputUnitStart(myUnit);
            [self checkForError:errorCheck];
            break;
        case 2:
            errorCheck = AudioOutputUnitStart(unidade);
            [self checkForError:errorCheck];
            break;
        default:
            break;
    }
}

- (void) pauseAwesomeness{
    OSStatus errorCheck;
    
    switch (usedInit) {
        case 0:
            errorCheck = AUGraphStop(graficozinho);
            [self checkForError:errorCheck];
            break;
        case 1:
            errorCheck = AudioOutputUnitStop(myUnit);
            [self checkForError:errorCheck];
            break;
        case 2:
            errorCheck = AudioOutputUnitStop(myUnit);
            break;
            
        default:
            break;
    }
    
}

@end