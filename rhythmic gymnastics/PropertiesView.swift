//
//  PropertiesView.swift
//  Rhythmic Gymnastics
//
//  Created by Наталья on 09.04.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit

class PropertiesView: UIView {
    
    @IBOutlet weak var countFLabel: UILabel!
    @IBOutlet weak var countOLabel: UILabel!
    @IBOutlet weak var countMLabel: UILabel!
    @IBOutlet weak var countDERLabel: UILabel!
    @IBOutlet weak var countDLabel: UILabel!
    @IBOutlet weak var perFLabel: UILabel!
    @IBOutlet weak var TotalValueLabel: UILabel!
    
    var dance: Int = 0
    var countF: Int = 0
    var countO: Int = 0
    var percentF: Double = 0.0
    var countMaster: Int = 0
    var countDer: Int = 0
    var countD: Int = 0
    
    func setF(fund: Int) {
        countF = fund
        countFLabel.text = countF.description
    }
    
    func setO(other: Int) {
        countO = other
        countOLabel.text = countO.description
        recountFper()
    }

    func setM(master: Int) {
        countMLabel.text = master.description
    }
    
    func setDER(der: Int) {
        countDERLabel.text = der.description
    }
    
    func setD(diff: Int) {
        countDLabel.text = diff.description
    }
    
    private func recountFper() {
        if countO + countF == 0 {
            percentF = 0
            perFLabel.text = percentF.description
            return
        }
        percentF = ((Double)(countF)/(Double)(countF + countO))*100
        percentF = round(percentF)
        perFLabel.text = percentF.description
        
    }
    
    func recountProperties(allContent: CardContent) {
        reset()
        var difficultyAdd = false
        for row in allContent.content {
            for element in row.row {
             if element.functional == true { setF(++countF) }
             if element.functional == false { setO(++countO) }
             if element.imageName.hasPrefix("rota") || element.imageName.hasPrefix("bala") || element.imageName.hasPrefix("leap"){//повороты, мультипл трудность вращения
                if !difficultyAdd { setD(++countD)}
                difficultyAdd = true
            }
            if element.imageName.hasPrefix("add_0_5") {//плюс
                difficultyAdd = false
            }
            if element.imageName.hasPrefix("DER_0") {//база риска
                setDER(++countDer)
            }
            if element.imageName.hasPrefix("M_18") {//мастерство
                setM(++countMaster)
            }
            if element.imageName.hasPrefix("sub_5_0_N_S") {dance += 1}
            }
            difficultyAdd = false
        }
        recountFper()
    }
    
    func reset() {
        setF(0)
        setO(0)
        setM(0)
        setD(0)
        setDER(0)
        dance = 0
        countF = 0
        countO = 0
        percentF = 0.0
        countMaster = 0
        countDer = 0
        countD = 0
    }
}
