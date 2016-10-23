//
//  GANHelper.swift
//  rhythmic gymnastics
//
//  Created by Студент on 10/07/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit

typealias GA = GANHelper

class GANHelper: NSObject {
    static let instance = GANHelper()
    
    let gai: GAI
    
    private override init() {
        gai = GAI.sharedInstance()
        let tracker = gai.trackerWithTrackingId("UA-65006896-1")
        gai.defaultTracker = tracker
        gai.trackUncaughtExceptions = true  // report uncaught exceptions
        gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
        
        super.init()
    }
    
    class func screen(name: String) {
        let tracker = GANHelper.instance.gai.defaultTracker
        
        tracker.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    class func event(name: String) {
        let tracker = GANHelper.instance.gai.defaultTracker
        
        tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_event", action: name, label: nil, value: nil).build() as [NSObject: AnyObject])
    }
}
