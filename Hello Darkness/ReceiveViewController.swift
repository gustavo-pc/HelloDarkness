//
//  ReceiveViewController.swift
//  Hello Darkness
//
//  Created by gustavo on 6/1/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import AudioToolbox

class ReceiveViewController: UIViewController, MCSessionDelegate , NSStreamDelegate {
    
    
    var myID: MCPeerID?
    var myAdvertiser: MCAdvertiserAssistant?
    var mySession: MCSession?
    var inputStream: NSInputStream?
    
    var player = AudioStreamPlayer();
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        player.accumulatedBuffersBeforeStarting = 0;
        
        player.startReceivingAudio();
        
        
        self.setupConnectivity();
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopConnectivity()
        player.stopReceivingAudio();
    }
    
    
    func setupConnectivity() {
        myID = MCPeerID(displayName: UIDevice.currentDevice().name)
        mySession = MCSession(peer: myID)
        
        myAdvertiser = MCAdvertiserAssistant(serviceType: "audio-try", discoveryInfo: nil, session: mySession)
        
        myAdvertiser?.start()
        mySession?.delegate = self
        
    }
    
    func stopConnectivity() {
        mySession = nil
        myAdvertiser?.stop()
    }
    
    //MARK: Session Delegate
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        switch state {
        case .Connected:
            println("Connected to \(peerID.displayName)");
        case .Connecting:
            println("Connecting to \(peerID.displayName)")
        case .NotConnected:
            println("Lost connection to \(peerID.displayName)")
    }
}

func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
    println("recebi \(data.length) bytes");
    
    var receivedBuffer = AudioBuffer(mNumberChannels: 1, mDataByteSize: UInt32(data.length), mData: UnsafeMutablePointer<Void>(data.bytes));
    
    player.enqueueBuffer(receivedBuffer);
}

func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
    
    println("recebi stream")
    self.inputStream = stream
    inputStream?.delegate = self
    inputStream?.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    inputStream?.open()
}

func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
}

func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
}

//MARK: NSStream Delegate

func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
    switch eventCode {
    case NSStreamEvent.HasBytesAvailable:
        let input = aStream as! NSInputStream
        var buffer = Array<UInt8>(count: 1024, repeatedValue: 0)
        let numberBytes = input.read(&buffer, maxLength: 1024)
        let dataString = NSData(bytes: &buffer, length: numberBytes)
        let message = NSKeyedUnarchiver.unarchiveObjectWithData(dataString) as! String
        println(message)
        
        //            var receivedData = UnsafeMutablePointer<UInt8>();
        //            input.read(receivedData, maxLength: 2048);
        
        
    default:
        break
    }
    
    
}
}
