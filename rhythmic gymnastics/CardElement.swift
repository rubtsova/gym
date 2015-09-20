//
//  CardElement.swift
//  Rhythmic Gymnastics
//
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import UIKit

///Отдельный элемент упражнения
public class CardElement {
    var simpleElems: [SimpleCellElement] = []

    var value: Double

    init() {
        simpleElems = []
        value = 0
    }
    
    init(elems: [SimpleCellElement], value: Double) {
        simpleElems = elems
        self.value = value
    }
    
}







