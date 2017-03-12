//
//  CardRow.swift
//  Rhythmic Gymnastics
//
//  Created by Наталья on 28.02.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import UIKit

///Строка из таблицы выполняемых элементов
public class CardRow : NSObject, NSCoding {
    ///Строка таблицы карточки
    var row: [SimpleCellElement] = []
    
    override init() {
        self.row = [SimpleCellElement]()
    }
    
    ///Общая стоимость всех элементов строки
    var totalVal: Double = 0
    
    /**
    Добавление элемента в строку
    
    - parameter elem: Элемент для добавления
    */
    func addElement (elem: SimpleCellElement) {
        row.append(elem)
        recountTotal()
    }
    
    func count() -> Int {
        return row.count
    }
    func removeElement (elem: SimpleCellElement) {
        var index = -1
        for (i,item) in row.enumerate() {
            if item.imageName == elem.imageName {
                index = i
                break
        }
        }
        row.removeAtIndex(index)
        recountTotal()
    }
    
    func removeElementAtIndex (index: Int) {
        row.removeAtIndex(index)
        recountTotal()
    }
    
    private func recountTotal() {
        var val: Double = 0
        for (i, element) in row.enumerate() {
            if element.imageName.hasPrefix("rota") {//повороты, мультипл трудность вращения
                var ii = i
                while ii < row.count - 1 && row[ii+1].imageName.hasPrefix("add_1") {
                    val = val + Double(Int(row[ii+1].imageName[6])! + 1) * element.value
                    ii=ii+1
                }
            }
            if element.imageName.hasPrefix("DER_1")||element.imageName.hasPrefix("DER_2") {//доп критерии рисков
                val = val + 0.1
            }
            if element.imageName.hasPrefix("sub_5_1_N")||element.imageName.hasPrefix("sub_5_2_N") {//преакробатические
                val = val + 0.1
            }
            if element.imageName.hasPrefix("add_0_5") {//плюс
                val = val + 0.1
            }
            if element.imageName.hasPrefix("DER_0") {//база риска
                val = val + Double(Int(element.imageName[6])! + 2)*0.1
            }
            if element.imageName.hasPrefix("M_M") {//мастерство
                val = val + 0.3
            }
            
            val = val + element.value // все оставшиеся, те равновесия и прыжки
            
        }
        totalVal = val
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.totalVal = aDecoder.decodeDoubleForKey("totalVal")
        self.row = aDecoder.decodeObjectForKey("row") as! [SimpleCellElement]
        super.init()
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(Double(self.totalVal), forKey:"totalVal")
        aCoder.encodeObject(self.row, forKey:"row")
    }
    
}
