//
//  CardsViewController.swift
//  Rhythmic Gymnastics
//
//  Created by Admin on 24.01.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit
import MessageUI

let names = "names"

class CardsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let cardsNames = NSUserDefaults.standardUserDefaults()
    var storage = [String]()
    
    var chooseMod = false //на данный момент происходит выбор элементов
    var selectedCards = [String]()
    

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var hiddenToolBar: UIToolbar!
    
    @IBOutlet weak var beginingImage1: UIImageView!
 
    @IBOutlet weak var beginingImage2: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.hidden = true
        var leftWobble: CGAffineTransform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-10.0));
        var rightWobble: CGAffineTransform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(10.0));
        
        beginingImage1.transform = leftWobble;  // starting point
        beginingImage2.transform = rightWobble;  // starting point
        
        
        beginingImage1.image = UIImage(named: "bulava.png")
        beginingImage2.image = UIImage(named: "bulava.png")
        
        UIView.animateWithDuration (0.12, delay:0, options: ([UIViewAnimationOptions.Repeat, UIViewAnimationOptions.Autoreverse]), animations: {
            self.beginingImage2.transform = leftWobble
            self.beginingImage1.transform = rightWobble
            }, completion: { finished in
                UIView.animateWithDuration(0.324 , animations: {
                leftWobble = CGAffineTransformRotate(CGAffineTransformIdentity, self.RADIANS(-180.0));
                rightWobble = CGAffineTransformRotate(CGAffineTransformIdentity, self.RADIANS(180.0));
                self.beginingImage2.transform = leftWobble
                self.beginingImage1.transform = rightWobble
                self.beginingImage2.frame = CGRect(x: 700, y: self.beginingImage2.frame.minY, width: self.beginingImage2.frame.width, height: self.beginingImage2.frame.height)
                self.beginingImage1.frame = CGRect(x: 0, y: self.beginingImage1.frame.minY, width: self.beginingImage1.frame.width, height: self.beginingImage1.frame.height)
                self.beginingImage2.alpha = 0
                self.beginingImage1.alpha = 0
                    }, completion: { finished in
                        self.collectionView.hidden = false
                })
        })
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.9 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.beginingImage2.layer.removeAllAnimations()
            self.beginingImage1.layer.removeAllAnimations()
        }
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    func RADIANS(degrees: CGFloat) -> CGFloat {
        return (degrees * CGFloat(M_PI)) / 180.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        
        GA.screen("cards")
    }
    
    @IBAction func clickReview(sender: AnyObject) {
        let composeController = MFMailComposeViewController()
        composeController.setSubject("Гимнастика — Отзыв")
        composeController.setToRecipients(["sergey@pronin.me", "ekaterina___95@mail.ru"])
        composeController.setMessageBody("\n\n\n" + (NSUserDefaults.standardUserDefaults().objectForKey("user-id") as? String ?? ""), isHTML: false)
        composeController.mailComposeDelegate = self
        self.presentViewController(composeController, animated: true, completion: nil)
    }
    
    //UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        storage = cardsNames.objectForKey(names) as? [String] ?? [String]()
        return storage.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Button", forIndexPath: indexPath) 
            cell.backgroundColor = UIColor(patternImage: UIImage(named: "addNewCard.png")!)
            return cell
        } else {
            storage = cardsNames.objectForKey(names) as! [String]
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Card", forIndexPath: indexPath) as! CardCollectionViewCell
            
            let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let fileAbsoluteUrl = documentsUrl.URLByAppendingPathComponent(storage[indexPath.row - 1] + ".card").absoluteURL
            
            cell.cardContent = NSKeyedUnarchiver.unarchiveObjectWithFile(fileAbsoluteUrl.path!) as! CardContent
            
            cell.cardName.text = storage[indexPath.row - 1]
            let subject = cell.cardContent.card.subject
            cell.subjectPicture.image = UIImage(named: "subjectDesign" + subject.rawValue.description + ".png")
            
            return cell
        }
    }
    
    // UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == 0 {
            GA.event("cards_newCard")
            self.performSegueWithIdentifier("CreateCard", sender: nil)
            //TODO здесь можно сбросить выбор если он имеется
        }
        else {
            let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as! CardCollectionViewCell
            if chooseMod {
                if nameCheck(currentCell.getName()) {
                    UIView.animateWithDuration(0.5 , animations: {currentCell.choosenCellImage.alpha = 0})
                    //currentCell.choosenCellImage.hidden = true
                    //currentCell.choosenCellImage.alpha = 1
                    for (i, item) in selectedCards.enumerate() {
                        if item == currentCell.getName() {
                            selectedCards.removeAtIndex(i)
                            break
                        }
                    }
                }
                else {
                    currentCell.choosenCellImage.hidden = false
                    currentCell.choosenCellImage.alpha = 0
                    UIView.animateWithDuration(0.3 , animations: {currentCell.choosenCellImage.alpha = 1})
                    //currentCell.choosenCellImage.hidden = false
                    selectedCards.append(currentCell.getName())
                }
                
                if selectedCards.isEmpty { hiddenToolBar.hidden = true }
                else { hiddenToolBar.hidden = false }
            }
            
            else {
                //переходим к просмотру
                GA.event("cards_pdf")
                self.performSegueWithIdentifier("listToPDF", sender: currentCell.cardContent)
            }
        }
    }

    func nameCheck (currCellName: String) -> Bool {
        for item in selectedCards {
            if item == currCellName {return true}
        }
        return false
    }
    
    @IBAction func touchChooseButton(sender: AnyObject) {
        let but = sender as! UIBarButtonItem
        
        if !chooseMod {
            chooseMod = true
            but.title = "Отменить"
        }
        else {
            chooseMod = false
            but.title = "Выбрать"
            for cell in collectionView.visibleCells() {
                if let c = cell as? CardCollectionViewCell {
                    c.choosenCellImage.hidden = true
                }
            }
            selectedCards.removeAll(keepCapacity: false)
            hiddenToolBar.hidden = true
        }
        
    }
    
    @IBAction func touchSendSelected(sender: AnyObject) {
        
        let cachesUrl = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
        var pathes = [NSData]()
        var pdfPath = String()
        for (i, item) in storage.enumerate() {
            for (_, selectedItem) in selectedCards.enumerate() {
                if item == selectedItem {
                    pdfPath = cachesUrl.URLByAppendingPathComponent(storage[i] + ".pdf").path!
                    let data = NSData(contentsOfFile: pdfPath)!
                    pathes.append(data)
                }
            }
        }
        
        let activityController = UIActivityViewController(activityItems: pathes, applicationActivities: nil)
        
        //без этого работать не станет
        activityController.modalPresentationStyle = .Popover
        activityController.popoverPresentationController!.barButtonItem = sender as? UIBarButtonItem
        //var rect = self.navigationController!.view.bounds
        //rect.size.height /= 2
        //activityController.popoverPresentationController!.sourceRect = rect
        
        self.presentViewController(activityController, animated: true, completion: nil)
        
        chooseMod = false
        self.navigationItem.rightBarButtonItem?.title = "Выбрать"
        for cell in collectionView.visibleCells() {
            if let c = cell as? CardCollectionViewCell {
                c.choosenCellImage.hidden = true
            }
        }
        hiddenToolBar.hidden = true
        collectionView.reloadData()

        
    }
    @IBAction func touchDeleteSelected(sender: AnyObject) {
        storage = cardsNames.objectForKey(names) as! [String]
        for item in storage {
            for selectedItem in selectedCards {
                if item == selectedItem {
                    for (i, item) in storage.enumerate() {
                        if item == selectedItem {
                            storage.removeAtIndex(i)
                        }
                    }
                }
            }
        }
        selectedCards.removeAll(keepCapacity: false)
        cardsNames.setObject(storage, forKey: names)
        chooseMod = false
        self.navigationItem.rightBarButtonItem?.title = "Выбрать"
        //editButtonItem().title = "Выбрать"
        for cell in collectionView.visibleCells() {
            if let c = cell as? CardCollectionViewCell {
                c.choosenCellImage.hidden = true
            }
        }
        hiddenToolBar.hidden = true
        collectionView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? CardPDFViewController {
            controller.cardContent = sender as! CardContent
        }
    }
}


extension CardsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
