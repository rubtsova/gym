//
//  ElementSimpleD.swift
//  Rhythmic Gymnastics
//
//  Created by Наталья on 28.02.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation

///Элемент "Трудность тела"
public class ElementSimpleD: CardElement {
    
    ///Если "вращение", то количество, иначе nil
    var number: Int?
    
    init(element: SimpleCellElement, rotationNumb: Int?) {
        super.init()
        
        self.simpleElems.append(element)
        number = rotationNumb
        
        
        //VALUE CALCULATION
        if number != nil {
            self.value = element.value * Double(number!)
        }
        else { self.value = element.value }
    }
}
