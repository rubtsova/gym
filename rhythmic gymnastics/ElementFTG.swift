//
//  File3.swift
//  Rhythmic Gymnastics
//
//  Created by Наталья on 28.02.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation

///Элемент "Фундаментальная техническая группа"
public class ElementFTG: CardElement {
    
    init(elementFTG: SimpleCellElement) {
        super.init()
        
        self.simpleElems.append(elementFTG)
        value = 0
    }
}