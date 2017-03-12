//
//  CardPDFViewController.swift
//  Rhythmic Gymnastics
//
//  Created by Наталья on 27.04.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit
import StoreKit



func qq_dispatchAfter(delaySeconds: Double, block: () -> ()) {
    let popTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delaySeconds * Double(NSEC_PER_SEC)))
    dispatch_after(popTime, dispatch_get_main_queue(), block)
}

class CardPDFViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var cardContent: CardContent = CardContent()
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var openedFromEditor = false
    var pdfFilePath: String!
    var iphone: Bool = true
    
    var products: [SKProduct] = []
    
    let productIdentifiers = InappHelper.Identifier.all
    
    deinit {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        requestProductData()
        
        if let freeCards = InappHelper.shared.freeCardsLeft where cardContent.blocked && freeCards > 0 {
            cardContent.blocked = false
            dispatch_async(dispatch_get_main_queue(), {
                self.cardContent.save()
            })
            InappHelper.shared.freeCardsLeft = freeCards - 1
            
            GA.event("card_spendFree")
        }
        
        drawCard(safe: cardContent.blocked && !InappHelper.shared.hasUnlimitedSubsription)
        
        let data = NSData(contentsOfFile: pdfFilePath)!
        webView.loadData(data, MIMEType: "application/pdf", textEncodingName: "utf-8", baseURL: NSURL())
        
        if openedFromEditor {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Готово", style: .Done, target: self, action: #selector(CardPDFViewController.clickDone))
        }
    }
    
    func clickDone() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    private func export() {
        if !cardContent.blocked || InappHelper.shared.hasUnlimitedSubsription {
            exportPDF()
            GA.event("export_options_export")
        } else {
            if InappHelper.shared.purchasedCardsLeft > 0 {
                cardsAreExist()
                GA.event("export_options_exportSpend")
            } else {
                cardsAreNotExist()
                GA.event("export_options_exportNotSpend")
            }
        }
    }
    
    private func cardsAreExist() {
        let boughtCardsCount = InappHelper.shared.purchasedCardsLeft
        
        GA.event("export_ifSpend")

        let message = "Количество оплаченных карточек: \(boughtCardsCount)\nИспользовать одну из них, чтобы сохранить или отправить готовую карточку?\nИмейте в виду, что возможность сохранить готовый документ будет доступна только для данной карточки. Если отредактируете и снова захотите сохранить, придется использовать новую активацию."
        
        let alert = UIAlertController(title: "Сохранение готовой программы", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .Cancel, handler: { _ in
            GA.event("export_ifSpend_no")
        }))
        alert.addAction(UIAlertAction(title: "Да", style: .Default, handler: { _ in
            GA.event("export_ifSpend_yes")
            self.take1Card()
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func take1Card() {
        if InappHelper.shared.hasUnlimitedSubsription {
            GA.event("export_spendUnlimited")
        } else {
            InappHelper.shared.purchasedCardsLeft -= 1
            GA.event("export_spendCard")
        }
        
        cardContent.blocked = false
        cardContent.save()
        exportPDF()
        GA.event("pdf_take1card")
    }
    
    private func cardsAreNotExist() {
        let alert = UIAlertController(title: "Сохранение готовой программы", message: "Чтобы сохранить готовую карточку в формате PDF любым возможным способом, приобретите какой-либо из пакетов.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "4 карточки за \(products[2].price) руб.", style: .Default, handler: { _ in
            self.buyProduct(self.products[2])
        }))
        
        alert.addAction(UIAlertAction(title: "12 карточек за \(products[1].price) руб.", style: .Default, handler: { _ in
            self.buyProduct(self.products[1])
        }))
        
        alert.addAction(UIAlertAction(title: "Безлимит за \(products[0].price) руб.", style: .Default, handler: { _ in
            self.buyProduct(self.products[0])
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func exportPDF() {
        drawCard(safe: false)
        let data = NSData(contentsOfFile: pdfFilePath)!
        webView.loadData(data, MIMEType: "application/pdf", textEncodingName: "utf-8", baseURL: NSURL())
        
        let activityController = UIActivityViewController(activityItems: [data, "\(cardContent.card.gymName) \(cardContent.card.cardName)"], applicationActivities: nil)
        
        if traitCollection.userInterfaceIdiom == .Pad {
            activityController.modalPresentationStyle = .Popover
            activityController.popoverPresentationController?.barButtonItem = editButton
        }
        self.presentViewController(activityController, animated: true, completion: nil)

        GA.event("pdf_exportCard")
    }
    
    private func drawCard(safe safe: Bool) {
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
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(UIAlertAction(title: "Редактор", style: .Default, handler: { _ in
            self.alertEdit()
        }))
        sheet.addAction(UIAlertAction(title: "Экспорт", style: .Default, handler: { _ in
            qq_dispatchAfter(0.5) {
                self.export()
            }
        }))
        sheet.addAction(UIAlertAction(title: "Отмена", style: .Cancel, handler: nil))
        
        if traitCollection.userInterfaceIdiom == .Pad {
            sheet.modalPresentationStyle = .Popover
            sheet.popoverPresentationController?.barButtonItem = editButton
        }
        
        presentViewController(sheet, animated: true, completion: nil)
        GA.event("export_options")
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
    
    
    //_______________________РАБОТА СО ВСТРОЕННЫМИ ПОКУПКАМИ_______________________________//
    
    func requestProductData() {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: self.productIdentifiers)
            request.delegate = self
            request.start()
        } else {
            let alert = UIAlertController(title: "Встроенные покупки недоступны", message: "Пожалуйста включите Встроенные покупки в Настройках", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Отмена", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Настройки", style: .Default, handler: { _ in
                if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }))
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        self.products = response.products
        self.products.sortInPlace({ $0.price.doubleValue > $1.price.doubleValue })
    }
    
    func buyProduct(prod: SKProduct) {
        GA.event("pdf_clickBUY")
        let payment = SKPayment(product: prod)
        SKPaymentQueue.defaultQueue().addPayment(payment)
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
        
        switch transaction.payment.productIdentifier {
        case InappHelper.Identifier.unlimited:
            InappHelper.shared.hasUnlimitedSubsription = true
            s = "бесконечность"
        case InappHelper.Identifier.cards10:
            InappHelper.shared.purchasedCardsLeft += 12
            s = "12"
        case InappHelper.Identifier.cards3:
            InappHelper.shared.purchasedCardsLeft += 4
            s = "4"
        default:
            break
        }
        
        let alert = UIAlertController(title: "Спасибо", message: "Покупка завершена успешно\n Количество карточек для сохранения: \(s)", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .Default, handler: { _ in
            self.cardsAreExist()
        }))
        presentViewController(alert, animated: true, completion: nil)
        
        GA.event("pdf_PURCHASEwasFINISHED_" + s)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? CardEditorViewController {
            controller.allCardContent = cardContent
        }
    }

}
