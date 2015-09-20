//
//  CardInfo.swift
//  Rhythmic Gymnastics
//
//  Created by Admin on 01.02.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation

/**
    Гимнастка может выступать с одним из 5 предметов или без предмета

    - WA: без предмета
    - Rope: скакалка
    - Hoop: обруч
    - Ball: мяч
    - Clubs: булавы
    - Ribbon: лента
*/
enum Subject: Int {
    case WA = 1, Rope, Hoop, Ball, Clubs, Ribbon
    
    static func getSubject(tag: Int) -> Subject {
        if Subject(rawValue: tag) == nil {
            return Subject.WA
        }
        return Subject(rawValue: tag)!
    }
}

///Первичная информация о карточке
public class CardInfo: NSObject, NSCoding {
    ///Название карточки
    var cardName: String
    
    ///Имя гимнастки
    var gymName: String
    
    ///Город или страна
    var city: String
    
    ///Год рождения
    var birthyear: Int
    
    ///ФИО тренера
    var coach: String
    
    ///Предмет программы
    var subject: Subject = Subject.WA
    
    ///Музыка с голосом
    var musicVoice: Bool = false
    
    
    init(cardName: String, gymName: String, city: String, birthyear: Int, coach: String, subject: Subject, music: Bool) {
        self.cardName = cardName;
        self.gymName = gymName;
        self.city = city;
        self.birthyear = birthyear;
        self.coach = coach;
        self.subject = subject;
        self.musicVoice = music
    }
    override init() {
        self.cardName = "";
        self.gymName = "";
        self.city = "";
        self.birthyear = 0;
        self.coach = "";
        self.subject = Subject.WA;
        self.musicVoice = false
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.cardName = aDecoder.decodeObjectForKey("cardName") as! String
        self.gymName = aDecoder.decodeObjectForKey("gymName") as! String
        self.city = aDecoder.decodeObjectForKey("city") as! String
        self.birthyear = aDecoder.decodeIntegerForKey("birthyear")
        self.musicVoice = aDecoder.decodeBoolForKey("musicVoice")
        self.coach = aDecoder.decodeObjectForKey("coach") as! String
        let sub = aDecoder.decodeIntegerForKey("subject")
        subject = Subject.getSubject(sub)
        super.init()
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.cardName, forKey:"cardName")
        aCoder.encodeObject(self.gymName, forKey:"gymName")
        aCoder.encodeObject(self.city, forKey:"city")
        aCoder.encodeInt(Int32(self.birthyear), forKey:"birthyear")
        aCoder.encodeObject(self.coach, forKey:"coach")
        aCoder.encodeInt(Int32(subject.rawValue), forKey:"subject")
        aCoder.encodeBool(self.musicVoice, forKey: "musicVoice")
    }

}
