//
//  ElementsValuesCell.swift
//  Rhythmic Gymnastics
//
//  Created by Студент on 10.03.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit

///протокол оповещения о событиях в ячейке
protocol ElementsValuesTVCellDelegate {
    func singleClickToElementInElValCell(currElement: SimpleCellElement)
    func doubleClickToElementInElValCell(currElement: SimpleCellElement)
}



class ElementsValuesTVCell: UITableViewCell {

    @IBOutlet weak var labelValue: UILabel!

    @IBOutlet weak var headerImage: UIImageView!

    @IBOutlet var imageViews: [UIImageView]!

    //подписчик на события
    var delegate: ElementsValuesTVCellDelegate?
    
    @IBOutlet weak var firstIm: UIImageView!
    
    //как только она загрузится из Storyboard
    override func awakeFromNib() {
        
        for imView in imageViews ?? [] {
            let recognizerSingleClick: UITapGestureRecognizer = UITapGestureRecognizer()
            recognizerSingleClick.numberOfTapsRequired = 1
            recognizerSingleClick.addTarget(self, action: "singleTap:")
            
            let recognizerDoubleClick: UITapGestureRecognizer = UITapGestureRecognizer()
            recognizerDoubleClick.numberOfTapsRequired = 2
            recognizerDoubleClick.addTarget(self, action: "doubleTap:")
            
            imView.addGestureRecognizer(recognizerSingleClick)
            imView.addGestureRecognizer(recognizerDoubleClick)
            imView.userInteractionEnabled = true
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        for myImageView in imageViews {
            myImageView.image = nil
        }
        headerImage.image = nil
    }

    
    var elements: [SimpleCellElement]! {
        didSet {
            if elements.count == 0 {
                return
            }
            let labelval = round(10 * elements[0].value) / 10
            labelValue.text = labelval.description
            for (i, element) in elements.enumerate() {
                //поставить картинки
                for myImageView in imageViews {
                    if myImageView.tag == i {
                        myImageView.image = element.imageForCard
                        break
                    }
                }
            
            }
        }
    }
    
    //простое нажатие(один клик)
    func singleTap(recognizer: UITapGestureRecognizer) {
        let index: Int = recognizer.view!.tag
        if index < self.elements.count {
        self.delegate?.singleClickToElementInElValCell(self.elements[index])
        }
    }
    
    func doubleTap(recognizer: UITapGestureRecognizer) {
        let index: Int = recognizer.view!.tag
        if index < self.elements.count {
            self.delegate?.doubleClickToElementInElValCell(self.elements[index])
        }
    }
}