//
//  AppDelegate.swift
//  MouseCapture
//
//

import Cocoa
import AVFoundation

@main
class AppDelegate: NSObject, NSApplicationDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

	@IBOutlet var window: NSWindow!
	
	var avlayer = AVSampleBufferDisplayLayer()
	var session = AVCaptureSession()
	var currentDisplay = CGDirectDisplayID()
	var input = AVCaptureScreenInput()

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		if let contentView = window.contentView{
			contentView.layer = avlayer
			avlayer.frame = contentView.frame
		}
		else{
			fatalError("No contentView??")
		}
		
		currentDisplay = getScreenWithMouse()
		
		session.sessionPreset = AVCaptureSession.Preset.high
		updateSession()
		
		let output = AVCaptureVideoDataOutput()
		if session.canAddOutput(output){
			session.addOutput(output)
		}
		else{
			fatalError("Cannot add capture screen output")
		}
		
		output.setSampleBufferDelegate(self, queue: DispatchQueue.main);
		
		session.startRunning()
				
	}
	
	func updateSession(){
		session.removeInput(input)
		input = AVCaptureScreenInput(displayID: currentDisplay)!
		input.minFrameDuration = CMTimeMake(value: 1, timescale: 60)
		if session.canAddInput(input) {
			session.addInput(input)
		}
		else{
			fatalError("Cannot add capture screen input")
		}
	}
	
	// called once per frame
	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		avlayer.enqueue(sampleBuffer)	// put the frame on the layer
		let screenWithMouse = getScreenWithMouse()
		if (screenWithMouse != currentDisplay){
			currentDisplay = screenWithMouse
			session.stopRunning()
			updateSession()
			session.startRunning()
		}
	}
	
	func getScreenWithMouse() -> CGDirectDisplayID {
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens
        if let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) }){
            let key = NSDeviceDescriptionKey(rawValue: "NSScreenNumber");
            let displayID = screenWithMouse.deviceDescription[key] as? CGDirectDisplayID
            
            return displayID!
        }
		
		return currentDisplay
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		session.stopRunning()
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool{
		return true
	}
}
