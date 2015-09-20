//
//  File.swift
//  Rhythmic Gymnastics
//
//  Created by Наталья on 28.02.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation

///Элемент "Микс трудность"
public class ElementMixD: CardElement {
    
    ///Количество вращений для каждого из elements (если там вращения)
    var numbers: [Int?] = []
    
//  init(elements: (first: SimpleCellElement, second: SimpleCellElement), rotationNumbers: (Int?, Int?)) {
    //elements.0 elements.first
    //elements.1 elemtnts.second
    
    init(elements: [SimpleCellElement], rotationNumbers: [Int?]) {
        super.init()
        
        let first = elements[0]
        let second = elements[1]
        
        self.simpleElems.append(first)
        self.simpleElems.append(second)
        
        numbers = rotationNumbers
        
        //VALUE CALCULATION
        var calcVal : Double = 0
        
        if numbers[0] != nil {
            calcVal = calcVal + first.value * Double(numbers[0]!)
        }
        else { calcVal = calcVal + first.value }
        
        if numbers[1] != nil {
            calcVal = calcVal + second.value * Double(numbers[1]!) //ok??(!)
        }
        else { calcVal = calcVal + second.value }
        
        calcVal = calcVal + 0.1 //надбавка за соединение элементов
        
        value = calcVal
    }
}

