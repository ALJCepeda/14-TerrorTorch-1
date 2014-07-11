//
//  UICircularGestureRecognizer.swift
//  TerrorTorch
//
//  Created by Michael Honaker on 7/10/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//
//
// Usage From a view controller:
// ====================================================
//    override func viewDidLoad() {
//        ...
//        let circularRecognizer:UICircularGestureRecognizer = UICircularGestureRecognizer(target: self, action: "rotated:");
//        self.view.addGestureRecognizer(circularRecognizer);
//    }
//    func rotated(recognizer: UICircularGestureRecognizer) {
//        UICircularGestureRecognizer.rotateView(recognizer);
//    }

import Foundation
import UIKit


class UICircularGestureRecognizer: UIGestureRecognizer {
    
    var rotation:CGFloat = 0.0;
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        if event.touchesForGestureRecognizer(self).count > 1 {
            self.state = UIGestureRecognizerState.Failed;
        }
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        if UIGestureRecognizerState.Changed == self.state {
            self.state = UIGestureRecognizerState.Ended;
        } else {
            self.state = UIGestureRecognizerState.Failed;
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        self.state = UIGestureRecognizerState.Failed;
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!)  {
        if UIGestureRecognizerState.Possible == self.state {
            self.state = UIGestureRecognizerState.Began;
        } else {
            self.state = UIGestureRecognizerState.Changed;
        }
        
        let touch = touches.anyObject() as UITouch;
        let view = self.view;
        let center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds)); // rotation around center axis
        let current = touch.locationInView(view);
        let previous = touch.previousLocationInView(view);
        self.rotation = atan2f(current.y - center.y, current.x - center.x) - atan2f(previous.y - center.y, previous.x - center.x);
    }
    
    //==========================================================================
    // CLASS METHODS
    //==========================================================================
    
    class func rotateView(circularRecognizer: UICircularGestureRecognizer!) {
        let view:UIView = circularRecognizer.view;
        view.transform = CGAffineTransformRotate(view.transform, circularRecognizer.rotation);
    }
}
