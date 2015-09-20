//
//  GroupNameTVCell.swift
//  Rhythmic Gymnastics
//
//  Created by Наталья on 11.03.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit

class GroupNameTVCell: UITableViewCell {
    
    @IBOutlet weak var sectionLabel: UILabel!
    
    //$$ при изменении свойства - изменится текст у label
    var headerText: String! {
        didSet {
            sectionLabel.text = headerText
        }
    }
    
}
