//
//  ViewController.swift
//  TerrorTorch
//
//  Created by ben on 6/17/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import UIKit
import AVFoundation

class MainScreenController: UIViewController {
                            
    @IBOutlet var powerView: UIImageView = nil;
    
    var _device : AVCaptureDevice?
    var isTorchOn = false;
    
    var knobAngle:Float = 0.0;
    var torchLevel:Float = 0.5;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        _device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo);
        
        //Gesture recognizer for transition to settings page
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("presentSettingsScreen:"));
        swipeRecognizer.direction = UISwipeGestureRecognizerDirection.Left;
        self.view.addGestureRecognizer(swipeRecognizer);
        
        //Don't add gesture recognizer to handle user interactions if device doesn't support torch mode
        //There should also be some kind of UI change to signify it's disabled.
        //Torch mode isn't supported on iOS simulator
        if let dvc = _device {
            if(dvc.hasTorch) {
                powerView.userInteractionEnabled = true;
                
                //Gesture recognizer for enabling torch mode
                let singleTapRecognizer = UITapGestureRecognizer(target: self, action: Selector("toggleTorchLight:"));
                powerView.addGestureRecognizer(singleTapRecognizer);
                
                // use circular gesture to adjust torch intensity
                let circularRecognizer:UICircularGestureRecognizer = UICircularGestureRecognizer(target: self, action: "rotated:");
                powerView.addGestureRecognizer(circularRecognizer);
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       // Dispose of any resources that can be recreated.
    }

    func presentSettingsScreen(recognizer: UISwipeGestureRecognizer){
        if(recognizer.state == UIGestureRecognizerState.Ended){ //Had to cast to raw because equality wasn't working
            self.performSegueWithIdentifier("mainToSettings", sender: self);
        }
    }
    
    func toggleTorchLight(recognizer: UITapGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizerState.Ended) {
            if let dvc = _device {
                dvc.lockForConfiguration(nil);
                dvc.torchMode = (isTorchOn) ? AVCaptureTorchMode.Off : AVCaptureTorchMode.On;
                isTorchOn = !isTorchOn;
                
                if isTorchOn {
                    dvc.setTorchModeOnWithLevel(self.torchLevel, error: nil); // restore previous level (if any)
                }
                dvc.unlockForConfiguration()
            }
        }
    }
    
    /**
    *  Changes the torch level/intensity
    *
    *  @param intensity:Float A float value between 0.1 and 1.0
    */
    func changeTorchIntensity(intensity:Float) {
        if let dvc = _device {
            if isTorchOn {
                self.torchLevel = (intensity > 0.0 && intensity <= 1.0) ? intensity : 0.5;
                NSLog("Setting intesity level to: %f", self.torchLevel);
                dvc.lockForConfiguration(nil);
                dvc.setTorchModeOnWithLevel(self.torchLevel, error: nil)
                dvc.unlockForConfiguration();
            }
        }
    }
    
    /**
    *   Action for "knob" control rotate gesture
    */
    func rotated(recognizer: UICircularGestureRecognizer) {
        var currentAngle:Float = 0.0;
        if self.shouldAllowRotation(recognizer.rotation, currentAngle:&currentAngle, minAngle:-90, maxAngle:90) {
            UICircularGestureRecognizer.rotateView(recognizer);
            self.changeTorchIntensity(self.calculateIntensity(currentAngle));
        }
    }
    
    /**
    *  Calculates intensity based on ratio for min/max angles allowed by "knob" control
    *
    *  @param currentAngle:Float The current angle of the "knob" control
    *  @return Float - Returns a float value between 0.1 and 1.0
    */
    func calculateIntensity(currentAngle:Float) -> Float {
        let boundedCurrentAngle:Float = governFloat(currentAngle);
        
        // this method assumes a range of -90 to 90, otherwise math needs to be tweaked
        assert((Int(boundedCurrentAngle) >= -90 && Int(boundedCurrentAngle) <= 90), "Expects a value between -90 and 90");
        
        let angle:Float = (((boundedCurrentAngle < 0) ? floorf(boundedCurrentAngle) : ceilf(boundedCurrentAngle)) + 90); // produces 0 - 180
        if angle > 0 {
            let intensity:Float = (angle / 1.8) / 100.0;
            return ceilf(intensity * 100) / 100;
        }
        return 0.1; // 0.0 causes error even though docs say between 0.0 and 1.0
    }
    
    /**
    *  Correct erroneous float values by limiting it to a desired range.
    *
    *  @param currentFloat:Float The float that requires potential correcting
    *  @param max:Float [optional] Defaults to -90.0
    *  @param min:Float [optional] Defaults to 90.0
    *  @return Float Returns currentFloat if within range, max if above range, min if below range.
    */
    func governFloat(currentFloat:Float, min:Float = -90.0, max:Float = 90.0) -> Float {
        switch currentFloat {
        case let x where x < min:
            return min;
        case let x where x > max:
            return max;
        default:
            return currentFloat;
        }
    }
    
    /**
    *  Determines if "knob" control's current rotation falls within min/max degrees
    *
    *  @param currentRadians:Float The current angle of the "knob" control in radians
    *  @param inout currentAngle:Float Will contain the calculated angle of the "knob" control
    *  @param maxAngle:Float [optional] - Defaults to -90.0
    *  @param minAngle:Float [optional] - Defaults to 90.0
    *  @return Bool - Returns true if within min/max, false otherwise
    */
    func shouldAllowRotation(currentRadians:Float, inout currentAngle:Float, minAngle:Float = -90.0, maxAngle:Float = 90.0) -> Bool {
        let degrees = UICircularGestureRecognizer.radiansToDegrees(currentRadians);
        currentAngle = self.knobAngle + degrees;
        let newAngle:Float = fmodf(currentAngle, 360.0);
        
        var shouldRotate = false;
        if minAngle <= maxAngle {
            shouldRotate = (newAngle >= minAngle && newAngle <= maxAngle) ? true : false;
        } else if minAngle > maxAngle {
            shouldRotate = (newAngle >= minAngle || newAngle <= maxAngle) ? true : false;
        }
        
        if shouldRotate {
            self.knobAngle = newAngle;
        }
        return shouldRotate;
    }
    
    @IBAction func clearCachePressed(sender: UIButton) {
        
        let tmpDirectory = NSFileManager.defaultManager().contentsOfDirectoryAtPath(NSTemporaryDirectory(), error: nil);
        
        for file in tmpDirectory as [String]{
            NSFileManager.defaultManager().removeItemAtPath(NSTemporaryDirectory() + file, error: nil);
        }
    }
}
