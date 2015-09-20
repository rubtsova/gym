//
//  CardCollectionViewCell.swift
//  Rhythmic Gymnastics
//
//  Created by Alex Zimin on 02/02/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var cardName: UILabel!
    @IBOutlet weak var choosenCellImage: UIImageView!
    
    var cardContent = CardContent()
    
    @IBOutlet weak var subjectPicture: UIImageView!
    
    
    func getName() -> String {
        return cardContent.getName()
    }
}
