//
//  File6.swift
//  Rhythmic Gymnastics
//
//  Created by Наталья on 28.02.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import UIKit

///Элемент "Мастерство владения предметом"
public class ElementM: CardElement {
    
    var base1: SimpleCellElement? //не нужен optional
    var base2: SimpleCellElement?
    
    var criteria1: SimpleCellElement? //не нужен optional
    var criteria2: SimpleCellElement?
    
    //elementM - всегда одинаковый и единственный
    //конструктор для 1 - base и 2 - criteria
    init(elementM: SimpleCellElement, base: SimpleCellElement, crit1: SimpleCellElement, crit2: SimpleCellElement) {
        super.init() //просит инициализировать, но я ведь ниже это делаю, в базовом классе вообще такого поля нет, каким образом я определю его в этом конструкторе?
        
        //чтобы скомпилилось поставила optionals у base1 и criteria1 хотя они там не нужны
        
        simpleElems.append(elementM)
        base1 = base
        criteria1 = crit1
        criteria2 = crit2
        
        self.value = 0.3
        
    }
    
    //конструктор для 2 - base и 1 - criteria
    init(elementM: SimpleCellElement, base1: SimpleCellElement, base2: SimpleCellElement, crit1: SimpleCellElement) {
        super.init()
        
        simpleElems.append(elementM)
        self.base1 = base1
        self.base2 = base2
        criteria1 = crit1
        
        self.value = 0.3
    }
}