//
//  File4.swift
//  Rhythmic Gymnastics
//
//  Created by Наталья on 28.02.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation

///Элемент "Другая техническая группа"
public class ElementOTG: CardElement {
    
    init(elementOTG: SimpleCellElement) {
        super.init()
        
        self.simpleElems.append(elementOTG)
        value = 0
    }
}