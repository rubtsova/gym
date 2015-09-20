//
//  SimpleCellElement.swift
//  Rhythmic Gymnastics
//
//  Created by Наталья on 27.02.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import UIKit
/**
    это простейший элемент,который может существовать как часть CardElement
    или являться единственным его компонентом (проще говоря, CardElement 
    может содержать в себе один или несколько SimpleCellElement в зависимости от типа)

    именно на эти элементы пользователь будет кликать чтобы картинка добавилась на карточку

    ПРОБЛЕМА в том, что таких элементов порядка 300 или даже более и все их нужно проинициализировать
    присвоить стоимость, описание и картинку

    КАК ЭТО СДЕЛАТЬ Я ВООБЩЕ НЕ ЗНАЮ!
*/

///Простейший элемент для добавления на карточку
public class SimpleCellElement : NSObject, NSCoding {
    var name: String
    
    var imageName: String
    
    var imageForCard: UIImage!
    
    ///Картинка, изображающая исполнение элемента в действительности(не суть короче, она просто есть или нет)
    var imageDescription: UIImage?
    
    var value: Double
    var functional: Bool?
    
    override init () {
        self.name = ""
        self.imageForCard = nil
        self.imageDescription = nil
        self.value = 0
        self.functional = nil
        self.imageName = ""
    }

    init(name: String, imName: String, imageCard: UIImage, imageDescr: UIImage?, value: Double) {
        self.name = name
        self.imageName = imName
        self.imageForCard = imageCard
        self.imageDescription = imageDescr
        self.value = value
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.value = aDecoder.decodeDoubleForKey("value")
        if aDecoder.containsValueForKey("functional") {
            self.functional = aDecoder.decodeBoolForKey("functional")
        }
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.imageName = aDecoder.decodeObjectForKey("imageName") as! String
        self.imageForCard = UIImage(named: imageName + ".png")
            //aDecoder.decodeObjectForKey("imageForCard") as! UIImage
        self.imageDescription = aDecoder.decodeObjectForKey("imageDescription") as? UIImage
        super.init()
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(Double(self.value), forKey:"value")
        if functional != nil { aCoder.encodeBool(self.functional!, forKey:"functional") }
        aCoder.encodeObject(self.name, forKey:"name")
        aCoder.encodeObject(self.imageName, forKey:"imageName")
        aCoder.encodeObject(self.imageForCard, forKey:"imageForCard")
        aCoder.encodeObject(self.imageDescription, forKey:"imageDescription")
    }
}