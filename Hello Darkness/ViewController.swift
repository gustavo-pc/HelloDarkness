//
//  ViewController.swift
//  Hello Darkness
//
//  Created by gustavo on 6/1/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AudioStreamRecorderDelegate {
    
    var recorder = AudioStreamRecorder();
    
    let player = AudioStreamPlayer();
    
    var buffers: Array<AudioBuffer> = Array<AudioBuffer>();
    
    override func viewDidLoad() {
        recorder.delegate = self;
        recorder.outputMuted = true;
        recorder.beAwesome();
        player.accumulatedBuffersBeforeStarting = 0;
        player.startReceivingAudio();
    }
    
    
    func audioStreamRecorder(recorder: AudioStreamRecorder!, didRenderNewBuffer buffer: AudioBuffer) {
        
        let bufferData = NSData(bytes: buffer.mData, length: Int(buffer.mDataByteSize));
        free(buffer.mData);
        
        processBufferData(bufferData);
    }
    
    func processBufferData(bufferData: NSData) {
        
        let unpacked = AudioBuffer(mNumberChannels: 1, mDataByteSize: UInt32(bufferData.length), mData: UnsafeMutablePointer<Void>(bufferData.bytes));
        player.enqueueBuffer(unpacked);
    }
    
}

struct Constants {
    static let kMultipeerServiceType = "audio";
}
