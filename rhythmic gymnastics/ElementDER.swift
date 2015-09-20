//
//  File5.swift
//  Rhythmic Gymnastics
//
//  Created by Наталья on 28.02.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation

///Элемент "Динамический элемент с вращением"
public class ElementDER: CardElement {
    
    var rotationNumb: Int = 0
    
    //elementR - всегда одинаковый и единственный
    //elements - дополнительные критерии
    init(elementR: SimpleCellElement, elements: [SimpleCellElement], rotationNum: Int) {
        super.init()
        
        self.rotationNumb = rotationNum
        self.simpleElems.append(elementR)
        
        for elem in elements {
            self.simpleElems.append(elem)
        }
        
        //VALUE CALCULATION
        var calcVal: Double = 0
        calcVal = calcVal + Double(rotationNumb) * 0.1 //риск посчитали
        calcVal = calcVal + Double(elements.count) * 0.1 //дополнительные критерии
    }
}