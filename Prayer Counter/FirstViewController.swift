//
//  FirstViewController.swift
//  Prayer Counter
//
//  Created by Muhammad Albayati on 6/28/20.
//  Copyright © 2020 Muhammad Albayati. All rights reserved.
//

import UIKit
import ImageIO
import AVFoundation
import AVKit

class FirstViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var bowsLabel: UILabel!
    @IBOutlet weak var bowsCounterLabel: UILabel!
    @IBOutlet weak var prostrationsLabel: UILabel!
    @IBOutlet weak var prostrationsCounterLabel: UILabel!
    
    
    
    
    var currentBrightness: CGFloat = 0.0
    var isProstrating: Bool = false
    
    let captureSession = AVCaptureSession()
    
    // For testing purposes at first
    var previewLayer:CALayer!
    var captureDevice:AVCaptureDevice!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareCamera()
        
        self.view.backgroundColor = UIColor.black
        
        prostrationsLabel.textColor = UIColor.white
        prostrationsLabel.backgroundColor = UIColor.init(white: 0, alpha: 1)
        
        prostrationsCounterLabel.textColor = UIColor.white
        prostrationsCounterLabel.backgroundColor = UIColor.init(white: 0, alpha: 1)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        stopCaptureSession()
    }

    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo //used for photo. Will probably not be needed

        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices
        captureDevice = availableDevices.first
        beginSession()

    }

    func beginSession() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }

//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        self.previewLayer = previewLayer
//        self.view.layer.addSublayer(self.previewLayer)
//        self.previewLayer.frame = self.view.layer.frame
        captureSession.startRunning()

        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value: kCVPixelFormatType_32BGRA)]

        dataOutput.alwaysDiscardsLateVideoFrames = true

        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }

        captureSession.commitConfiguration()

        let queue = DispatchQueue(label: "com.Muhammad.captureQueue")
        dataOutput.setSampleBufferDelegate(self, queue: queue)

    }

    func stopCaptureSession() {
        self.captureSession.stopRunning()
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
                
            }
        }
    }


    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

    //Retrieving EXIF data of camara frame buffer
        let rawMetadata = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: CMAttachmentMode(kCMAttachmentMode_ShouldPropagate))
        let metadata = CFDictionaryCreateMutableCopy(nil, 0, rawMetadata) as NSMutableDictionary
        let exifData = metadata.value(forKey: "{Exif}") as? NSMutableDictionary

        let FNumber : Double = exifData?["FNumber"] as! Double
        let ExposureTime : Double = exifData?["ExposureTime"] as! Double
        let ISOSpeedRatingsArray = exifData!["ISOSpeedRatings"] as? NSArray
        let ISOSpeedRatings : Double = ISOSpeedRatingsArray![0] as! Double
        let CalibrationConstant : Double = 50

        //Calculating the luminosity
        let luminosity : Double = (CalibrationConstant * FNumber * FNumber ) / ( ExposureTime * ISOSpeedRatings )

        print(luminosity)
        
        checkIsProstrating(luminosity: luminosity)

    }
    
    func checkIsProstrating(luminosity: Double) {
        if(luminosity < 10.0) {
            isProstrating = true
        } else {
            isProstrating = false
        }
    }
    
    
    @IBAction func decreaseCount(_ sender: Any) {
    }
    
    
    @IBAction func clearCount(_ sender: Any) {
    }
    
    
}

