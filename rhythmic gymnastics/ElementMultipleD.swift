//
//  ElementMixD.swift
//  Rhythmic Gymnastics
//
//  Created by Наталья on 28.02.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation

///Элемент "Мультипл трудность вращения (Фуэте)"
public class ElementMultipleD: CardElement {
    
    ///Количество вращений для каждого из elements
    var numbers: [[Int]] = []
    
    init(elements: [SimpleCellElement], rotationNumbers: [[Int]]) {
        super.init()
        
        for elem in elements {
            self.simpleElems.append(elem)
        }
        
        numbers = rotationNumbers
        
        //VALUE CALCULATION
        let i : Int = 0
        for elem in simpleElems {
            for numb in numbers[i] {
                self.value = self.value + elem.value * Double(numb)
            }
        }
        
    }
}
