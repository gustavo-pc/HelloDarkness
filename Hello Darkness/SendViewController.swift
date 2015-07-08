//
//  SendViewController.swift
//  Hello Darkness
//
//  Created by gustavo on 6/1/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class SendViewController: UIViewController, MCNearbyServiceBrowserDelegate, MCSessionDelegate, NSStreamDelegate, AudioStreamRecorderDelegate {
    
    var myID : MCPeerID?
    var mySession: MCSession?
    var myBrowser: MCNearbyServiceBrowser?
//    var outputStream: NSOutputStream?
    
    let recorder = AudioStreamRecorder();
    
    @IBOutlet weak var writeOnStreamButton: UIButton!
    
    //MARK: VC Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.setupConnectivity()
        recorder.delegate = self;
        recorder.outputMuted = true;
        recorder.beAwesome();
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        recorder.pauseAwesomeness();
        
        self.stopConnectivity()
    }
    
    //MARK: IBActions
    
    var i = 0;
    
    @IBAction func writeOnStream() {
        
        let numberData = NSKeyedArchiver.archivedDataWithRootObject("Teste")
        
//        recorder.outputStream.write(UnsafePointer(numberData.bytes), maxLength: numberData.length)
    }
    
    //MARK: Setup
    
    func setupConnectivity() {
        
        myID = MCPeerID(displayName: UIDevice.currentDevice().name);
        mySession = MCSession(peer: myID);
        
        myBrowser = MCNearbyServiceBrowser(peer: myID, serviceType: "audio-try");
        mySession?.delegate = self;
        myBrowser?.delegate = self;
        myBrowser?.startBrowsingForPeers();
        println("browsing");
    }
    
    func stopConnectivity() {
        mySession = nil
        myBrowser?.stopBrowsingForPeers()
    }
    
    
    //MARK: AudioStreamRecorderDelegate
    func audioStreamRecorder(recorder: AudioStreamRecorder!, didRenderNewBuffer buffer: AudioBuffer) {
        
        if (mySession?.connectedPeers.count != 0) {
            
            let bufferData = NSData(bytes: buffer.mData, length: Int(buffer.mDataByteSize));
//            mySession?.sendData(bufferData, toPeers: mySession?.connectedPeers, withMode: .Unreliable, error: nil);
            
        }
        
        free(buffer.mData);
    }
    
    //MARK: Session Delegate
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        switch state {
        case .Connected:
            self.recorder.outputStream = mySession?.startStreamWithName("stream", toPeer: peerID, error: nil)
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ Void in
                self.writeOnStreamButton.enabled = true
            })
            
            if let outputStream = recorder.outputStream {
//                outputStream.delegate = self.recorder
                outputStream.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
                outputStream.open()
            }
            
        case .Connecting:
            println("Connecting to \(peerID.displayName)")
        case .NotConnected:
            println("Lost connection to \(peerID.displayName)")
        }
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {}
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {}
    
    //MARK: Browser Delegate
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        println("\(peerID.displayName) found")
        browser.invitePeer(peerID, toSession: mySession, withContext: nil, timeout: 0)
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {}

    //MARK: Stream Delegate
    
    var counter = 0;
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        if (eventCode == NSStreamEvent.HasSpaceAvailable){
            println("TA LIVRE: \(counter++ * 143) bytes escritos")
        }
    }
}
