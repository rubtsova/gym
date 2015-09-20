//
//  CardPDFViewController.swift
//  Rhythmic Gymnastics
//
//  Created by Наталья on 27.04.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit
import StoreKit

let cardNumber = "cardNumber"

class CardPDFViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    var cardContent: CardContent = CardContent()
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var openedFromEditor = false
    var pdfFilePath: String!
    
    let productIdentifiers = Set(["me.rubtsova.gymnastics.inapp.unlimited", "me.rubtsova.gymnastics.inapp.cards10", "me.rubtsova.gymnastics.inapp.cards3"])
    
    var product: SKProduct?
    var productsArray = Array<SKProduct>()
    
    //берем кол-во оплаченных карт
    let userDef = NSUserDefaults.standardUserDefaults()
    var purchasedCardNumb: Int = 0
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestProductData()//????????НЕ ОЧЕНЬ
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        purchasedCardNumb = userDef.integerForKey(cardNumber) as Int
        
        if cardContent.blocked == true {
            drawCard(true)
        }
        else { drawCard(false) }
        let data = NSData(contentsOfFile: pdfFilePath)!
        webView.loadData(data, MIMEType: "application/pdf", textEncodingName: "utf-8", baseURL: NSURL())
        
        if openedFromEditor {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Готово", style: .Done, target: self, action: "clickDone")
        }
    }
    
    func clickDone() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    //@IBOutlet weak var pdfCard: UIWebView!

    private func export() {
        if cardContent.blocked == false { exportPDF() }
        if purchasedCardNumb > 0 { cardsAreExist() }
        else { cardsAreNotExist() }
    }

    
    private func cardsAreExist() {
        let userDef = NSUserDefaults.standardUserDefaults()
        let boughtCardsCount = userDef.integerForKey(cardNumber) as Int

        let s: String = "Количество оплаченных карточек: " + boughtCardsCount.description + "\nИспользовать одну из них, чтобы сохранить или отправить готовую карточку?\nИмейте в виду, что возможность сохранить готовый документ будет доступна только для данной карточки. Если отредактируете и снова захотите сохранить, придется использовать новую активацию."
        let alert = UIAlertController(title: "Сохранение готовой программы", message: s, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Да", style: UIAlertActionStyle.Cancel, handler: {(alert: UIAlertAction) in self.take1Card()}))
        
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    func take1Card() {
        if userDef.boolForKey("isUnlimited") != true {
            userDef.setObject(--purchasedCardNumb, forKey: cardNumber)
        }
        cardContent.blocked = false
        exportPDF()
        GA.screen("pdf:take1card")
    }
    
    private func cardsAreNotExist() {
        let userDef = NSUserDefaults.standardUserDefaults()
        _ = userDef.integerForKey(cardNumber) as Int
        
        let s: String = "Чтобы сохранить готовую карточку в формате PDF любым возможным способом, приобретите какой-либо из пакетов."
        let alert = UIAlertController(title: "Сохранение готовой программы", message: s, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "4 карточки за " + productsArray[2].price.description + " руб." , style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction) in self.buyProduct(self.productsArray[2])}))
        alert.addAction(UIAlertAction(title: "12 карточек за " + productsArray[1].price.description + " руб." , style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction) in self.buyProduct(self.productsArray[1])}))
        alert.addAction(UIAlertAction(title: "Безлимит за " + productsArray[0].price.description + " руб." , style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction) in self.buyProduct(self.productsArray[0])}))
        alert.addAction(UIAlertAction(title: "Отмена", style: UIAlertActionStyle.Default, handler: nil))

        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    private func exportPDF() {
        drawCard(false)//
        let data = NSData(contentsOfFile: pdfFilePath)!
        webView.loadData(data, MIMEType: "application/pdf", textEncodingName: "utf-8", baseURL: NSURL())
        
        let activityController = UIActivityViewController(activityItems: [data, "Катя - Лента"], applicationActivities: nil)
        
        //без этого работать не станет
        activityController.modalPresentationStyle = .Popover
        activityController.popoverPresentationController!.barButtonItem = editButton
        self.presentViewController(activityController, animated: true, completion: nil)
        GA.screen("pdf:exportCard")
    }
    
    private func drawCard(safe: Bool) {
        //будет хранить в папке кеша
        let cachesUrl = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
        pdfFilePath = cachesUrl.URLByAppendingPathComponent(cardContent.getName() + ".pdf").path!
        
        //var path = NSTemporaryDirectory()
        //var pdfFilePath = path.stringByAppendingPathComponent(cardContent.getName() + ".pdf")
        
        //атрибуты для текста
        let font = UIFont(name: "Helvetica", size: 12)
        let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        let textColor = UIColor.blackColor()
        let textFontAttributes = [
            NSFontAttributeName : font!,
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: textStyle
        ]

        let data = NSMutableData()
        
        //UIGraphicsBeginPDFContextToFile(pdfFilePath, CGRectMake(0, 0, 595, 842), nil)
        let rect = CGRectMake(0, 0, 595, 842)
        UIGraphicsBeginPDFContextToData(data, rect, nil)
        UIGraphicsBeginPDFPage()
        //делаем новую пдф
        getEmptyPNGImageWithRect(rect)
        
        let spaceX: Double = 15
        var preX : Double
        let preY: Double = 145
        var columnNumb = 0
        var rectTextRowValue = CGRect()
        for (i,item) in cardContent.content.enumerate() {
            columnNumb = i/10
            preX = spaceX + Double(columnNumb*193)
            //print value for row
            if item.totalVal > 0 {
                rectTextRowValue = CGRectMake((CGFloat)(preX + 40), (CGFloat)(preY + Double(43*(i%10)) - 17), 100, 100)
                item.totalVal.description.drawInRect(rectTextRowValue, withAttributes: textFontAttributes)
            }
            
            var sum: Double  = 0
            for elem in item.row {
                var im = elem.imageForCard
                if elem.imageName.hasPrefix("add_0_6") { im = UIImage(named: "probel.png") }
                
                var imageWidth: Double = (Double)(im.size.width)/(Double)(im.size.height) * 20
                imageWidth = elem.imageName.hasPrefix("add_1") ? imageWidth/3:imageWidth
                
                sum += (Double)(imageWidth)
            }
            
            preX = preX + (145 - sum)/2
            
            for elem in item.row {
                preX = drawElem(elem, preImageCordX: preX, coordY: preY + Double(43*(i%10)))
            }
            
        }
        var percentF = ((Double)(cardContent.countF)/(Double)(cardContent.countF + cardContent.countO))*100
        percentF = round(percentF)
        var percentO = 100 - percentF
        if cardContent.countF + cardContent.countO == 0 {
            percentF = 0
            percentO = 0
        }

        let rectTextGymName = CGRectMake(20, 87, 200, 100)
        let rectTextFpercent = CGRectMake(269, 557, 100, 100)
        let rectText0percent = CGRectMake(260, 571, 100, 100)
        let rectTextTotal = CGRectMake(460, 558, 100, 100)
        let rectTextCoach = CGRectMake(130, 730, 100, 100)
        let rectTextMusic = CGRectMake(155, 557, 30, 30)
        
        let str : String = cardContent.card.city + "  " + cardContent.card.gymName + "  " + cardContent.card.birthyear.description
        
        str.drawInRect(rectTextGymName, withAttributes: textFontAttributes)
        percentF.description.drawInRect(rectTextFpercent, withAttributes: textFontAttributes)
        percentO.description.drawInRect(rectText0percent, withAttributes: textFontAttributes)
        cardContent.card.coach.drawInRect(rectTextCoach, withAttributes: textFontAttributes)
        cardContent.totalValue.description.drawInRect(rectTextTotal, withAttributes: textFontAttributes)
        if cardContent.card.musicVoice { "V".drawInRect(rectTextMusic, withAttributes: textFontAttributes) }
        
        //предмет рисуем
        let numb = cardContent.card.subject.rawValue - 2
        if (numb >= 0){
        let imageToPDF = UIImage (named: "sub" + numb.description + ".bmp")
            imageToPDF?.drawInRect(CGRectMake(CGFloat(370 + numb*25), 86, 25, 25))
        }
        
        if safe { getSafePNGImageWithRect(rect) }
        
        UIGraphicsEndPDFContext()
        
        data.writeToFile(pdfFilePath, atomically: true)
    }
    
    @IBAction func touchEditorButton(sender: AnyObject) {
        let alert = UIAlertController()
        alert.modalPresentationStyle = UIModalPresentationStyle.Popover
        alert.addAction(UIAlertAction(title: "Редактор", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction) in self.alertEdit()}))
        alert.addAction(UIAlertAction(title: "Экспорт", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction) in self.export()}))
        alert.addAction(UIAlertAction(title: "Отмена", style: UIAlertActionStyle.Default, handler: nil))
        let popPresenter = alert.popoverPresentationController
        //var but = sender as! UIBarButtonItem
        popPresenter?.barButtonItem = editButton
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func alertEdit() {
                let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
                let fileAbsoluteUrl = documentsUrl.URLByAppendingPathComponent(cardContent.getName() + ".card").absoluteURL
        
                cardContent = NSKeyedUnarchiver.unarchiveObjectWithFile(fileAbsoluteUrl.path!) as! CardContent
        
                if openedFromEditor {
                    self.navigationController!.popViewControllerAnimated(true)
                } else {
                    //!! аналогично при "Создать"
                    let editor = self.storyboard!.instantiateViewControllerWithIdentifier("CardEditorViewController") as! CardEditorViewController
                    editor.allCardContent = cardContent
                    self.navigationController!.setViewControllers([self.navigationController!.viewControllers[0], editor], animated: true)
                }
    }
    
    private func drawElem(element: SimpleCellElement, preImageCordX: Double, coordY: Double) -> Double {
        var drawingImage = element.imageForCard
        
        if  element.imageName.hasPrefix("add_0_6") {
            drawingImage = UIImage (named: "probel.png")
        }
        
            var imageWidth: Double = (Double)(drawingImage.size.width)/(Double)(drawingImage.size.height) * 20
            var imageHeight : Double = 20
            
            imageHeight = element.imageName.hasPrefix("add_1") ? 20/3:20
            imageWidth = element.imageName.hasPrefix("add_1") ? imageWidth/3:imageWidth
                    
            let y = element.imageName.hasPrefix("add_1") ? coordY + 16: coordY

            drawingImage?.drawInRect(CGRectMake(CGFloat(preImageCordX), CGFloat(y), CGFloat(imageWidth), CGFloat(imageHeight)))
            
            return preImageCordX + imageWidth
        }
    
    private func getEmptyPNGImageWithRect(rect: CGRect) {
        let image = UIImage(named: "empty")!
        image.drawInRect(rect)
    }
    
    private func getSafePNGImageWithRect(rect: CGRect) {
        let image = UIImage(named: "pngCard")!
        image.drawInRect(rect)
    }
    
//    private func getEmptyPDFImage() {
//        let url = NSURL(fileURLWithPath:NSBundle.mainBundle().pathForResource("empty", ofType:"pdf")!)
//        let pdf = CGPDFDocumentCreateWithURL(url)
//        let page = CGPDFDocumentGetPage(pdf, 1)
//        let rect = CGPDFPageGetBoxRect(page, CGPDFBox.CropBox)
//        
//        //UIGraphicsBeginImageContext(rect.size)
//        let context = UIGraphicsGetCurrentContext()
//        
//        CGContextSaveGState(context)
//        CGContextTranslateCTM(context, 0.0, rect.size.height)
//        CGContextScaleCTM(context, 1.0, -1.0)
//        
//        CGContextSetGrayFillColor(context, 1.0, 1.0)
//        CGContextFillRect(context, rect)
//        
//        let transform = CGPDFPageGetDrawingTransform(page, CGPDFBox.CropBox, rect, 0, true)
//        CGContextConcatCTM(context, transform)
//        CGContextDrawPDFPage(context, page)
//        
//        //var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
//        CGContextRestoreGState(context)
//        //UIGraphicsEndImageContext()
//        
//        //return image;
//    }
    
    //_______________________РАБОТА СО ВСТРОЕННЫМИ ПОКУПКАМИ_______________________________//
    
    func requestProductData()
    {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: self.productIdentifiers)
            request.delegate = self
            request.start()
        } else {
            let alert = UIAlertController(title: "Встроенные покупки недоступны", message: "Пожалуйста включите Встроенные покупки в Настройках", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Настройки", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
                
                let url: NSURL? = NSURL(string: UIApplicationOpenSettingsURLString)
                if url != nil
                {
                    UIApplication.sharedApplication().openURL(url!)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Отмена", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
        var products = response.products
        
        if (products.count != 0) {
            for var i = 0; i < products.count; i++
            {
                self.product = products[i]
                self.productsArray.append(product!)
            }
            productsArray.sortInPlace(orderBefore)
            //подгрузить в алерты
        } else {
            print("No products found")
        }
    }
    
    func buyProduct(prod: SKProduct) {
        GA.screen("pdf:clickBUY")
        let payment = SKPayment(product: prod)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    func orderBefore (prod1: SKProduct, prod2: SKProduct) -> Bool {
        if prod1.price.doubleValue  > prod2.price.doubleValue { return true }
        return false
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.Purchased:
                self.deliverProduct(transaction)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            case SKPaymentTransactionState.Failed:
                let alert = UIAlertController(title: "Сбой", message: "Транзакция отклонена", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                GA.screen("pdf:transactionFAILED")
            default:
                break
            }
        }
    }
    
    func deliverProduct(transaction:SKPaymentTransaction) {
        var s = ""
        
        if transaction.payment.productIdentifier == "me.rubtsova.gymnastics.inapp.unlimited"
        {
            userDef.setBool(true, forKey: "isUnlimited")
            s = "бесконечность"
        }
        else if transaction.payment.productIdentifier == "me.rubtsova.gymnastics.inapp.cards10"
        {
            userDef.setInteger(12, forKey: cardNumber)
            userDef.setBool(false, forKey: "isUnlimited")
            s = "12"
        }
        else if transaction.payment.productIdentifier == "me.rubtsova.gymnastics.inapp.cards3"
        {
            userDef.setInteger(4, forKey: cardNumber)
            userDef.setBool(false, forKey: "isUnlimited")
            s = "4"
        }
        
        let alert = UIAlertController(title: "Спасибо", message: "Покупка завершена успешно\n Количество карточек для сохранения: " + s, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        cardsAreExist()
        GA.screen("pdf:PURCHASEwasFINISHED" + s)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? CardEditorViewController {
            controller.allCardContent = cardContent
        }
    }

}
