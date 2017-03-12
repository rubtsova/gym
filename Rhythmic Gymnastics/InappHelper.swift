//
//  InappHelper.swift
//  rhythmic gymnastics
//
//  Created by Sergey Pronin on 12/24/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit

let CardsLeftDefault = "cardNumber"
let FreeCardsLeftDefault = "free_cards"
let UnlimitedSubscriptionDefault = "isUnlimited"

class InappHelper {
    
    struct Identifier {
        #if IPAD
        static let unlimited = "me.rubtsova.gymnastics.inapp.unlimited"
        static let cards10 = "me.rubtsova.gymnastics.inapp.cards10"
        static let cards3 = "me.rubtsova.gymnastics.inapp.cards3"
        #else
        static let unlimited = "me.rubtsova.gymnastics.inapp.unlimited.iphone"
        static let cards10 = "me.rubtsova.gymnastics.inapp.cards10.iphone"
        static let cards3 = "me.rubtsova.gymnastics.inapp.cards3.iphone"
        #endif
        
        static let all = Set([Identifier.unlimited, Identifier.cards10, Identifier.cards3])
    }
    
    static let shared = InappHelper()
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private init() { }
    
    var purchasedCardsLeft: Int {
        get {
            return defaults.integerForKey(CardsLeftDefault)
        }
        set {
            defaults.setInteger(newValue, forKey: CardsLeftDefault)
            defaults.synchronize()
        }
    }
    
    var freeCardsLeft: Int? {
        get {
            return defaults.objectForKey(FreeCardsLeftDefault) as? Int
        }
        set {
            if let value = newValue {
                defaults.setInteger(value, forKey: FreeCardsLeftDefault)
                defaults.synchronize()
            }
        }
    }
    
    var hasUnlimitedSubsription: Bool {
        get {
            return defaults.boolForKey(UnlimitedSubscriptionDefault)
        }
        set {
            defaults.setBool(newValue, forKey: UnlimitedSubscriptionDefault)
            defaults.synchronize()
        }
    }

}
