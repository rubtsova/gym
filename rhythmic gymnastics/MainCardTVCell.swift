
//
//  mainCardTVCell.swift
//  Rhythmic Gymnastics
//
//  Created by Наталья on 05.04.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit

///протокол оповещения о событиях в ячейке
protocol MainCardTVCellDelegate {
    func singleClickToElementInMainCell(index: Int, cell: MainCardTVCell)
    func dragElementInElValCell(recognizer: UIPanGestureRecognizer, currElement: SimpleCellElement, cell: MainCardTVCell)
    func editingValueInCellDidEnd(cell: MainCardTVCell, value: Double)
}

class MainCardTVCell: UITableViewCell, UITextFieldDelegate {
   
    @IBOutlet var imageViews: [UIImageView]!
    
    @IBOutlet weak var valueField: UITextField!
    
    @IBOutlet weak var hiddenBack: UIImageView!
    
    var delegate: MainCardTVCellDelegate?
    
    var value: Double = 0
    
    override func awakeFromNib() {
        for imView in imageViews {
            let recognizerSingleClick: UITapGestureRecognizer = UITapGestureRecognizer()
            recognizerSingleClick.numberOfTapsRequired = 1
            recognizerSingleClick.addTarget(self, action: #selector(MainCardTVCell.singleTap(_:)))
            imView.addGestureRecognizer(recognizerSingleClick)
            imView.userInteractionEnabled = false
            
            let recognizerDrag: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action:#selector(MainCardTVCell.dragImView(_:)))
            imView.addGestureRecognizer(recognizerDrag)
    
        }
        selectionStyle = .None
        valueField.text = "0.0"
        valueField.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        for myImageView in imageViews {
            myImageView.image = nil
        }
        
        hiddenBack.hidden = true
        valueField.text = "0.0"
        value = 0
        elements = CardRow()
    }
    
    var elements : CardRow = CardRow()
    
    @IBAction func editingValueDidEnd(sender: UITextField) {
        guard let text = sender.text else { return }
        let val = (text as NSString).doubleValue == 0.0 ? elements.totalVal : (text as NSString).doubleValue
        elements.totalVal = val
        value = val
        self.delegate?.editingValueInCellDidEnd(self, value: val)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
//    NSArray *identifiers = @[
//    @"com.example.myapp.apple",
//    @"com.example.myapp.pear",
//    @"com.example.myapp.banana"
//    ];
//    
//    [[CargoBay sharedManager] productsWithIdentifiers:[NSSet setWithArray:identifiers]
//    success:^(NSArray *products, NSArray *invalidIdentifiers) {
//    NSLog(@"Products: %@", products);
//    NSLog(@"Invalid Identifiers: %@", invalidIdentifiers);
//    } failure:^(NSError *error) {
//    NSLog(@"Error: %@", error);
//    }];
    
    func loadElements(elems: CardRow, animatedTag: Int) {
        let value = elems.totalVal
        if elems.count() == 0 {
            return
        }
        elements = CardRow()
        for myImageView in imageViews {
            myImageView.image = nil
        }
        for element in elems.row {
            addElement(element, animatedTag: animatedTag)
        }
        
        let valueInLabel = round(10 * value) / 10
        valueField.text = valueInLabel.description
    }
    
    ///Добавление элемента в ячейку
    func addElement(element: SimpleCellElement, animatedTag: Int) -> Bool{
        let index = elements.count()
        
        
        /*if !iphone{
        if index == 0 {
            let imageWidth: Double = (Double)(element.imageForCard.size.width)/(Double)(element.imageForCard.size.height) * 40
            let imageHeight : Double = 40
            
            imageViews[0].frame = CGRect(x: 12, y: 18, width: imageWidth, height: imageHeight)
            imageViews[0].image = element.imageForCard
            imageViews[0].userInteractionEnabled = true
            
            if element.imageName.hasPrefix("add_0_6") {
                return false
            }
        }
        }*/
        
        //iphone
        if index == 0 {
            let imageWidth: Double = (Double)(element.imageForCard.size.width)/(Double)(element.imageForCard.size.height) * 40
            let imageHeight : Double = 40
            
            imageViews[0].image = element.imageForCard
            imageViews[0].userInteractionEnabled = true
            imageViews[0].addConstraint(NSLayoutConstraint(item: imageViews[0], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: CGFloat(imageWidth)))
            
            imageViews[0].addConstraint(NSLayoutConstraint(item: imageViews[0], attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: CGFloat(imageHeight)))
            
            if element.imageName.hasPrefix("add_0_6") {
                return false
            }
        }
        
        if elements.count() > imageViews.count { return false}
        
        for imageView in imageViews {
            if imageView.tag == index && index != 0 {
                var drawingImage = element.imageForCard
                
                if  element.imageName.hasPrefix("add_0_6") {
                    drawingImage = UIImage (named: "probel.png")
                }
                
                var imageWidth: Double = (Double)(drawingImage.size.width)/(Double)(drawingImage.size.height) * 40
                var imageHeight : Double = 40
                
                imageHeight = element.imageName.hasPrefix("add_1") ? imageHeight/3:imageHeight
                imageWidth = element.imageName.hasPrefix("add_1") ? imageWidth/3:imageWidth
                
                for preImageView in imageViews {
                    if preImageView.tag == elements.count() - 1 /*предыдущий*/ {
                        
                        if ((Double)(preImageView.frame.minX + preImageView.frame.width) + imageWidth > 300) {
                            //предупреждение
                            return false
                        }
                        
                        imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: CGFloat(imageWidth)))
                        
                        imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: CGFloat(imageHeight)))
                    }
                }
                
                /*for preImageView in imageViews {
                 if preImageView.tag == elements.count() - 1 /*предыдущий*/ {
                 
                 imageHeight = element.imageName.hasPrefix("add_1") ? 40/3:40
                 imageWidth = element.imageName.hasPrefix("add_1") ? imageWidth/3:imageWidth
                 
                 coordY = element.imageName.hasPrefix("add_1") ? coordY + 26: coordY
                 
                 imageView.frame = CGRect(x: (Double)(preImageView.frame.minX + preImageView.frame.width), y: coordY, width: imageWidth, height: imageHeight)
                 
                 if ((Double)(preImageView.frame.minX + preImageView.frame.width) + imageWidth > 300) {
                 //предупреждение
                 return false
                 }
                 }
                 }*/
                
                if imageView.tag == animatedTag {
                    imageView.image = drawingImage
                    
                    imageView.alpha = 0
                    UIView.animateWithDuration(0.5 , animations: {imageView.alpha = 1})
                }
                else { imageView.image = drawingImage }
                
                imageView.image = imageView.image!.imageWithRenderingMode(.AlwaysTemplate)
                imageView.tintColor = UIColor.blackColor()
                imageView.userInteractionEnabled = true
            }
        }
        
        elements.addElement(element)
        let temp = round(10 * elements.totalVal) / 10
        valueField.text = temp.description
        return true
    }
    
    func removeElement(element: SimpleCellElement) {
        var currIndex: Int = -1
        for (i, elem) in elements.row.enumerate() {
            if element.imageName == elem.imageName {
            currIndex = i
                break
            }
        }
        remove(currIndex)
        let temp = round(10 * elements.totalVal) / 10
         valueField.text = temp.description
    }
    
    private func remove(index: Int) {
        for imageV in imageViews {
            if imageV.tag == elements.count() - 1{
                imageV.image = nil
                imageV.userInteractionEnabled = false
            }
        }
        elements.removeElementAtIndex(index)
        if index == elements.row.count {
            return
        }
        var tempelems: [SimpleCellElement] = []
        let count = elements.count()
        for _ in index...count-1 {
            tempelems.append(elements.row[index])
            elements.removeElementAtIndex(index)
        }
        
        for elem in tempelems {
            addElement(elem, animatedTag: -1)
        }
    }
    
    func reload(elems: CardRow, viewTag: Int, rect: CGRect, animatedTag: Int) {
        for imV in imageViews {
            if imV.tag == viewTag {
                imV.frame = rect
                break
            }
        }
        loadElements(elems, animatedTag: animatedTag)
    }
    
    //простое нажатие(один клик)
    func singleTap(recognizer: UITapGestureRecognizer) {
        let imageView = recognizer.view as! UIImageView
        
        let index: Int = imageView.tag
        if index < self.elements.count() {
            self.delegate?.singleClickToElementInMainCell(index, cell: self)
        }
    }
    
    //передвижение
    func dragImView(recognizer: UIPanGestureRecognizer) {
        let index: Int = recognizer.view!.tag
        
        if index < self.elements.count() {
            self.delegate?.dragElementInElValCell(recognizer, currElement: self.elements.row[index], cell: self)
        }
        
        
    }
    
}
