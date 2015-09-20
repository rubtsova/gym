//
//  File2.swift
//  Rhythmic Gymnastics
//
//  Created by Наталья on 28.02.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation

///Элемент "Комбинация танцевальных шагов"
public class ElementDance: CardElement {
    
    init(element: SimpleCellElement) { //всегда одинаковый и единственный, его можно без конструктора сразу
        super.init()
        
        self.simpleElems.append(element)
        value = 0.3
    }
}