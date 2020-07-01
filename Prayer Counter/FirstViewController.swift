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

class FirstViewController: UIViewController {
    
    

    @IBOutlet weak var cameraBrightness: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {

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
        
    }
    
}

