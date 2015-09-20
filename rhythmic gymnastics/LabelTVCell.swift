//
//  LabelTVCell.swift
//  Rhythmic Gymnastics
//
//  Created by Наталья on 02.04.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit


class LabelTVCell: UITableViewCell {
    @IBOutlet weak var cellLabel: UILabel!
    
    var defaultNames = [String]()
    
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.grayColor()
        defaultNames.append("Описание ФТГ или ОТГ (БАЗА для мастерства)")
        defaultNames.append("Описание критерия мастерства")
        defaultNames.append("Дополнительные элементы")
    }
    
    func initi(color: UIColor, index: Int) {
        self.backgroundColor = color
        cellLabel.text = defaultNames[index]
    }

}
