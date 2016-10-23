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

func qq_dispatchAfter(delaySeconds: Double, block: () -> ()) {
    let popTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delaySeconds * Double(NSEC_PER_SEC)))
    dispatch_after(popTime, dispatch_get_main_queue(), block)
}

class CardPDFViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver, UIAlertViewDelegate, UIActionSheetDelegate {
    
    var cardContent: CardContent = CardContent()
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var openedFromEditor = false
    var pdfFilePath: String!
    var iphone:Bool = true
    
    
    let productIdentifiers = Set(["me.rubtsova.gymnastics.inapp.unlimited.iphone", "me.rubtsova.gymnastics.inapp.cards10.iphone", "me.rubtsova.gymnastics.inapp.cards3.iphone"])
    
    var product: SKProduct?
    var productsArray = Array<SKProduct>()
    
    //берем кол-во оплаченных карт
    let userDef = NSUserDefaults.standardUserDefaults()
    var purchasedCardNumb: Int = 0
    
    deinit {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestProductData()//????????НЕ ОЧЕНЬ
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        purchasedCardNumb = userDef.integerForKey(cardNumber) as Int
        
        let freeCards = userDef.integerForKey("free_cards")
        if cardContent.blocked && freeCards > 0 {
            cardContent.blocked = false
            dispatch_async(dispatch_get_main_queue(), {
                self.cardContent.save()
            })
            userDef.setInteger(freeCards-1, forKey: "free_cards")
            userDef.synchronize()
            
            GA.event("card_spendFree")
        }
        
        drawCard(cardContent.blocked && !NSUserDefaults.standardUserDefaults().boolForKey("isUnlimited"))
        
        let data = NSData(contentsOfFile: pdfFilePath)!
        webView.loadData(data, MIMEType: "application/pdf", textEncodingName: "utf-8", baseURL: NSURL())
        
        if openedFromEditor {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Готово", style: .Done, target: self, action: #selector(CardPDFViewController.clickDone))
        }
    }
    
    func clickDone() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    //@IBOutlet weak var pdfCard: UIWebView!

    private func export() {
        if cardContent.blocked == false || NSUserDefaults.standardUserDefaults().boolForKey("isUnlimited") {
            exportPDF()
            GA.event("export_options_export")
        } else {
            if purchasedCardNumb > 0 {
                cardsAreExist()
                GA.event("export_options_exportSpend")
            } else {
                cardsAreNotExist()
                GA.event("export_options_exportNotSpend")
            }
        }
    }
    
    
    struct Tags {
        static let Save = 1
        static let Purchase = 2
        static let Export = 3
        static let InApp = 4
    }

    
    private func cardsAreExist() {
        let userDef = NSUserDefaults.standardUserDefaults()
        let boughtCardsCount = userDef.integerForKey(cardNumber) as Int
        
        GA.event("export_ifSpend")

        let s: String = "Количество оплаченных карточек: " + boughtCardsCount.description + "\nИспользовать одну из них, чтобы сохранить или отправить готовую карточку?\nИмейте в виду, что возможность сохранить готовый документ будет доступна только для данной карточки. Если отредактируете и снова захотите сохранить, придется использовать новую активацию."
        
        let alert = UIAlertView(title: "Сохранение готовой программы", message: s, delegate: self, cancelButtonTitle: "Отмена", otherButtonTitles: "Да")
        alert.tag = Tags.Save
        alert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch alertView.tag {
        case Tags.Save:
            if buttonIndex == alertView.cancelButtonIndex {
                GA.event("export_ifSpend_no")
            } else {
                GA.event("export_ifSpend_yes")
                self.take1Card()
            }
        case Tags.Purchase:
            switch buttonIndex {
            case 1: self.buyProduct(self.productsArray[2])
            case 2: self.buyProduct(self.productsArray[1])
            case 3: self.buyProduct(self.productsArray[0])
            default: break
            }
        case Tags.InApp:
            switch buttonIndex {
            case 1:
                if #available(iOS 8.0, *) {
                    let url: NSURL? = NSURL(string: UIApplicationOpenSettingsURLString)
                    if url != nil {
                        UIApplication.sharedApplication().openURL(url!)
                    }
                }
            default:
                break
            }
        default:
            break
        }
    }
    
    func take1Card() {
        if userDef.boolForKey("isUnlimited") != true {
            userDef.setObject(--purchasedCardNumb, forKey: cardNumber)
            GA.event("export_spendCard")
        } else {
            GA.event("export_spendUnlimited")
        }
        cardContent.blocked = false
        cardContent.save()
        exportPDF()
        GA.event("pdf_take1card")
    }
    
    private func cardsAreNotExist() {
        let alert = UIAlertView(title: "Сохранение готовой программы", message: "Чтобы сохранить готовую карточку в формате PDF любым возможным способом, приобретите какой-либо из пакетов.", delegate: self, cancelButtonTitle: "Отмена", otherButtonTitles: "4 карточки за " + productsArray[2].price.description + " руб.", "12 карточек за " + productsArray[1].price.description + " руб.", "Безлимит за " + productsArray[0].price.description + " руб.")
        alert.tag = Tags.Purchase
        alert.show()
    }
    
    private func exportPDF() {
        drawCard(false)//
        let data = NSData(contentsOfFile: pdfFilePath)!
        webView.loadData(data, MIMEType: "application/pdf", textEncodingName: "utf-8", baseURL: NSURL())
        
        let activityController = UIActivityViewController(activityItems: [data, "\(cardContent.card.gymName) \(cardContent.card.cardName)"], applicationActivities: nil)
        
        //без этого работать не станет
        if #available(iOS 8.0, *) {
            activityController.modalPresentationStyle = .Popover
        }
        //activityController.popoverPresentationController!.barButtonItem = editButton
        self.presentViewController(activityController, animated: true, completion: nil)

        GA.event("pdf_exportCard")
    }
    
    private func drawCard(safe: Bool) {
        //будет хранить в папке кеша
        let cachesUrl = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
        pdfFilePath = cachesUrl.URLByAppendingPathComponent(cardContent.getName() + ".pdf")!.path!
        
        //var path = NSTemporaryDirectory()
        //var pdfFilePath = path.stringByAppendingPathComponent(cardContent.getName() + ".pdf")
        
        //атрибуты для текста
        let font = UIFont.init(name: "Helvetica", size: 12)
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
        
        //some comment
    }
    
    @IBAction func touchEditorButton(sender: AnyObject) {
        let sheet = UIActionSheet()
        sheet.addButtonWithTitle("Редактор")
        sheet.addButtonWithTitle("Экспорт")
        sheet.cancelButtonIndex = sheet.addButtonWithTitle("Отмена")
        sheet.delegate = self
        sheet.tag = Tags.Export
        sheet.showInView(self.view)
        GA.event("export_options")
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch actionSheet.tag {
        case Tags.Export:
            switch buttonIndex {
            case 0:
                self.alertEdit()
            case 1:
                qq_dispatchAfter(0.5) {
                    self.export()
                }
            default:
                break
            }
        default:
            break
        }
    }
    
    private func alertEdit() {
        let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fileAbsoluteUrl = documentsUrl.URLByAppendingPathComponent(cardContent.getName() + ".card")!.absoluteURL

        cardContent = NSKeyedUnarchiver.unarchiveObjectWithFile(fileAbsoluteUrl!.path!) as! CardContent

        if openedFromEditor {
            self.navigationController!.popViewControllerAnimated(true)
        } else {
            //!! аналогично при "Создать"
            let editor = self.storyboard!.instantiateViewControllerWithIdentifier("CardEditorViewController") as! CardEditorViewController
            editor.allCardContent = cardContent
            self.navigationController!.setViewControllers([self.navigationController!.viewControllers[0], editor], animated: true)
        }
        
        GA.event("export_options_edit")
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
            let alert = UIAlertView(title: "Встроенные покупки недоступны", message: "Пожалуйста включите Встроенные покупки в Настройках", delegate: self, cancelButtonTitle: "Отмена", otherButtonTitles: "Настройки")
            alert.tag = Tags.InApp
            alert.show()
        }
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
        var products = response.products
        
        if (products.count != 0) {
            for i in 0 ..< products.count
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
        GA.event("pdf_clickBUY")
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
                UIAlertView(title: "Сбой", message: "Транзакция отклонена", delegate: nil, cancelButtonTitle: "ОК").show()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                GA.event("pdf_transactionFAILED")
            default:
                break
            }
        }
    }
    
    func deliverProduct(transaction:SKPaymentTransaction) {
        var s = ""
        
        if transaction.payment.productIdentifier == "me.rubtsova.gymnastics.inapp.unlimited.iphone"
        {
            userDef.setBool(true, forKey: "isUnlimited")
            s = "бесконечность"
        }
        else if transaction.payment.productIdentifier == "me.rubtsova.gymnastics.inapp.cards10.iphone"
        {
            userDef.setInteger(12, forKey: cardNumber)
            userDef.setBool(false, forKey: "isUnlimited")
            s = "12"
        }
        else if transaction.payment.productIdentifier == "me.rubtsova.gymnastics.inapp.cards3.iphone"
        {
            userDef.setInteger(4, forKey: cardNumber)
            userDef.setBool(false, forKey: "isUnlimited")
            s = "4"
        }
        userDef.synchronize()
        
        UIAlertView(title: "Спасибо", message: "Покупка завершена успешно\n Количество карточек для сохранения: " + s, delegate: nil, cancelButtonTitle: "OK").show()
        cardsAreExist()
        GA.event("pdf_PURCHASEwasFINISHED_" + s)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? CardEditorViewController {
            controller.allCardContent = cardContent
        }
    }

}
