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
    var outputStream: NSOutputStream?
    
    let recorder = AudioStreamRecorder();
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func sendMessage() {
//        let textData = NSKeyedArchiver.archivedDataWithRootObject(messageTextField.text)
//        self.outputStream?.write(UnsafePointer(textData.bytes), maxLength: textData.length)
    }
    
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
//        println("chegou buffer novo, tamanho \(buffer.mDataByteSize)");
        
        if (mySession?.connectedPeers.count != 0) {
            
            var err: NSError?;
            
            let bufferData = NSData(bytes: buffer.mData, length: Int(buffer.mDataByteSize));
            mySession?.sendData(bufferData, toPeers: mySession?.connectedPeers, withMode: .Reliable, error: &err);
            
//            outputStream?.write(UnsafePointer(buffer.mData), maxLength: Int(buffer.mDataByteSize));
        }
        
        free(buffer.mData);
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: Browser Delegate
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        println("\(peerID.displayName) found")
        browser.invitePeer(peerID, toSession: mySession, withContext: nil, timeout: 0)
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
    }
    
    //MARK: Session Delegate
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        switch state {
        case .Connected:
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.sendButton.enabled = true
            })
            var err: NSError?
            
//            self.outputStream = mySession?.startStreamWithName("stream", toPeer: peerID, error: &err)
//            if let outputStream = outputStream {
//                outputStream.delegate = self
//                outputStream.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
//                outputStream.open()
//            }
            
        case .Connecting:
            println("Connecting to \(peerID.displayName)")
        case .NotConnected:
            println("Lost connection to \(peerID.displayName)")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.sendButton.enabled = false
            })        }
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    
    //MARK: BrowserVC delegate
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        //show10
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        //massa cara
        browserViewController.dismissViewControllerAnimated(true, completion: nil);
    }
}
