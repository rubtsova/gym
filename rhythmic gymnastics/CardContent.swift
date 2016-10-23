//
//  CardContent.swift
//  Rhythmic Gymnastics
//
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation

//не знаю что тут с иерархией классов придумать, поэтому просто делаю агрегацию


///Класс, содержащий полную информацию о карточке и её контенте
public class CardContent : NSObject, NSCoding {
    
    ///Общая информация о карточке
    var card: CardInfo
    
    var countF: Int
    var countO: Int
    var countM: Int
    var countDER: Int
    var countDiff: Int
    
    var blocked: Bool
    
    //массив двумерный, так как мы должны располагать элементы в карточке построчно
    ///Элементы в карточке
    var content: [CardRow] = []
    
    init(cardinfo: CardInfo) {
        card = cardinfo
        content = [CardRow]()
        countF = 0
        countO = 0
        countM = 0
        countDER = 0
        countDiff = 0
        blocked = true
        
        super.init()
    }
    override init() {
        card = CardInfo()
        content = [CardRow]()
        countF = 0
        countO = 0
        countM = 0
        countDER = 0
        countDiff = 0
        blocked = true
        
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.countF = aDecoder.decodeIntegerForKey("countF")
        self.countO = aDecoder.decodeIntegerForKey("countO")
        self.countM = aDecoder.decodeIntegerForKey("countM")
        self.countDER = aDecoder.decodeIntegerForKey("countDER")
        self.countDiff = aDecoder.decodeIntegerForKey("countDiff")
        self.blocked = aDecoder.decodeBoolForKey("blocked")
        self.card = aDecoder.decodeObjectForKey("card") as! CardInfo
        self.content = aDecoder.decodeObjectForKey("content") as! [CardRow]
        super.init()
    }
    
    ///Итоговая стоимость карточки
    var totalValue: Double {
        get {
            var val: Double = 0
            for row in content {
                    val += row.totalVal
                }
            return val
        }
    }

    func count() -> Int {
        return content.count
    }
    
    func addRow(newRow: CardRow) {
        if content.count < 30 {
        content.append(newRow)
        }
    }
    
    
    public func getName()-> String {
        return card.cardName
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInt(Int32(self.countF), forKey:"countF")
        aCoder.encodeInt(Int32(self.countO), forKey:"countO")
        aCoder.encodeInt(Int32(self.countM), forKey:"countM")
        aCoder.encodeInt(Int32(self.countDER), forKey:"countDER")
        aCoder.encodeInt(Int32(self.countDiff), forKey:"countDiff")
        aCoder.encodeObject(self.card, forKey:"card")
        aCoder.encodeObject(self.content, forKey:"content")
        aCoder.encodeBool(self.blocked, forKey:"blocked")
    }
    
    func save() {
        let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fileAbsoluteUrl = documentsUrl.URLByAppendingPathComponent(self.getName() + ".card")
        NSKeyedArchiver.archiveRootObject(self, toFile: fileAbsoluteUrl!.path!)
    }
}



