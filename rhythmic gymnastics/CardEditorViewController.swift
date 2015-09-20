//
//  CardEditorViewController.swift
//  Rhythmic Gymnastics
//
//  Created by Студент on 10.03.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit

class CardEditorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ElementsValuesTVCellDelegate, MainCardTVCellDelegate {
    
//
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
    
    ///основная таблица элементов созданной карточки
    @IBOutlet weak var cardTableView: UITableView!
    ///область редактирования карточки
    @IBOutlet weak var mainEditingView: UIView!
    
    @IBOutlet weak var mainSegmentedControl: UISegmentedControl!
    @IBOutlet weak var supportSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    //окно первой вкладки
    @IBOutlet weak var descriptElemLabel: UILabel!
    @IBOutlet weak var descriptElemImageView: UIImageView!
    
    //кнопка удаления элемента из главной таблицы
    @IBOutlet weak var deleteElementButton: UIButton!
    
    @IBOutlet weak var cardPropertiesView: PropertiesView!

    var card: CardInfo!
    var allCardContent: CardContent!
    var currentCell = MainCardTVCell()
    var selectedElement: SimpleCellElement!
    
    @IBOutlet var mainSegmentViews: [UIView]!
    
    @IBOutlet weak var difficultyView: UIView!
    @IBOutlet weak var masterRiskView: UIView!
    @IBOutlet weak var myElementsView: UIView!
    @IBOutlet weak var addingsView: UIView!
    
    
    @IBOutlet weak var addMaster: UIButton!
    
    var arrayLeaps: [[[SimpleCellElement]]] = []
    var arrayBala: [[[SimpleCellElement]]] = []
    var arrayRotate: [[[SimpleCellElement]]] = []
    
    var arrayFandO: [[[SimpleCellElement]]] = []
    var arrayMasterCriteria: [[SimpleCellElement]] = []
    var arrayRiskDER: [[SimpleCellElement]] = []
    var arrayAddings: [[SimpleCellElement]] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if allCardContent == nil {
            allCardContent = CardContent(cardinfo: card)
            
            for _ in 1...30 {
                self.allCardContent.addRow(CardRow())
            }
        }
        else {
            cardPropertiesView.setF(allCardContent.countF)
            cardPropertiesView.setO(allCardContent.countO)
            cardPropertiesView.setD(allCardContent.countDiff)
            cardPropertiesView.setDER(allCardContent.countDER)
            cardPropertiesView.setM(allCardContent.countM)
            cardPropertiesView.TotalValueLabel.text = allCardContent.totalValue.description
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        //заполним массивы данными
        arrayLeaps = loadDifficulty("leap")
        arrayBala = loadDifficulty("bala")
        arrayRotate = loadDifficulty("rota")
        
        arrayFandO = loadFandO()
        arrayMasterCriteria = loadMaster()
        arrayRiskDER = loadRisks()
        arrayAddings = loadAddings()
        
        //указываем, что данные таблица получает из текущего контроллера
        tableView.dataSource = self
        tableView.delegate = self
        
        cardTableView.dataSource = self
        cardTableView.delegate = self
        
        cardTableView.editing = true
        cardTableView.allowsSelectionDuringEditing = true
        
        cardPropertiesView.recountProperties(allCardContent)
        
    }
    
    //UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == cardTableView { return 1 }
        
        let main = mainSegmentedControl.selectedSegmentIndex
        let support = supportSegmentedControl.selectedSegmentIndex
        
        if main == 0 {
            return sectionHeaders()[support].count
        }
        else { return 1 }

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView != cardTableView {
            return
        }
        
        selectedElement = nil //сбрасываем элемент, теперь ничего не выбрано
        deleteElementButton.hidden = true
        currentCell = cardTableView.cellForRowAtIndexPath(indexPath) as! MainCardTVCell
        reSelectCellInMainTable(currentCell)
        resetHighlight()
        
        for imView in currentCell.imageViews {
            
            imView.tintColor = UIColor.blackColor()
            //imView.highlighted = false
            //imView.highlightedImage = nil
        }
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if tableView == cardTableView {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        //ячейку перенесли с sourceIndexPath на destinationIndexPath
        //поменять в модели
        let temp = allCardContent.content[sourceIndexPath.row]
        allCardContent.content.removeAtIndex(sourceIndexPath.row)
        allCardContent.content.insert(temp, atIndex: destinationIndexPath.row)
        
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None //надо бы чтобы удалялось
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //количество ячеек в каждой секции
        
        if tableView == cardTableView {
            return 30
        }
        
        let main = mainSegmentedControl.selectedSegmentIndex
        let support = supportSegmentedControl.selectedSegmentIndex
        
        var count = 0
        
        if main == 0 && support == 0 {
            for item in arrayLeaps[section] {
                if item.count != 0 {count++}
            }
        }
        if main == 0 && support == 1 {
            for item in arrayBala[section] {
                if item.count != 0 {count++}
            }
        }

        if main == 0 && support == 2 {
            for item in arrayRotate[section] {
                if item.count != 0 {count++}
            }
        }
        
        if main == 1 && support == 0 {
            count = 12
        }
        if main == 1 && support == 1 {
            count = 2
        }
        if main == 1 && support == 2 {
            count = 3
        }
        if main == 2 {
            count = 2
        }
        
        return count
    }

    
    @IBAction func mainSegmentChanged(sender: AnyObject) {
        if tableView == cardTableView { return }
        let main = mainSegmentedControl.selectedSegmentIndex
        reloadMainSegment(main)
    }
    
    @IBAction func supportSegmentChanged(sender: UISegmentedControl) {
        if tableView == cardTableView { return }
        self.tableView.reloadData()
    }
    
    func reloadMainSegment(main: Int) {
        for view in mainSegmentViews {
            if view.tag == main {view.hidden = false}
            else {view.hidden = true}
        }
        
        if main == 2 || main == 3 {
            supportSegmentedControl.hidden = true
            tableView.sectionHeaderHeight = 0
        }
        else {
            supportSegmentedControl.hidden = false
            if main == 0 {
                supportSegmentedControl.setTitle("Прыжки", forSegmentAtIndex: 0)
                supportSegmentedControl.setTitle("Равновесия", forSegmentAtIndex: 1)
                supportSegmentedControl.setTitle("Повороты", forSegmentAtIndex: 2)
                tableView.sectionHeaderHeight = 35
                tableView.sectionFooterHeight = 35
            }
            else {
                supportSegmentedControl.setTitle("ФТГ(F) и ДТГ(О)", forSegmentAtIndex: 0)
                supportSegmentedControl.setTitle("Критерии мастерства", forSegmentAtIndex: 1)
                supportSegmentedControl.setTitle("Риски", forSegmentAtIndex: 2)
                tableView.sectionHeaderHeight = 35
            }
        }
        
        self.tableView.reloadData()
    }


    //UITableViewDelegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == cardTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("MainCardTVCell") as! MainCardTVCell!
            cell.delegate = self
            cell.shouldIndentWhileEditing = false
            //если у нас имеется уже эта ячейка, то есть ее уже заполняли
            if allCardContent.content.count >= indexPath.row + 1 {
                if indexPath.row == 0 {
                    
                }
                cell.loadElements(allCardContent.content[indexPath.row], animatedTag: -1)
            }

            if indexPath.row == 0 && indexPath.section == 0 && allCardContent.content.count <= 1 {
                currentCell = cell
                reSelectCellInMainTable(currentCell)
                resetHighlight()
            }
            return cell
            
        }
        
        //var cell
        let main = mainSegmentedControl.selectedSegmentIndex
        let support = supportSegmentedControl.selectedSegmentIndex
        
        if tableView == cardTableView {return MainCardTVCell()}
        
        if main == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("ElementsValuesTVCell") as! ElementsValuesTVCell!
            cell.delegate = self
            cell.selectionStyle = .None
            cell.labelValue.hidden = false
            cell.headerImage.hidden = true
            
            //если массив пуст(нет элементов с такой ценностью в данной секции) взять следующую
            
            switch support {
            case 0:
                cell.elements = arrayLeaps[indexPath.section][findDifficultyElemForCell(indexPath,array: arrayLeaps)]
            case 1:
                cell.elements = arrayBala[indexPath.section][findDifficultyElemForCell(indexPath,array: arrayBala)]
            case 2:
                cell.elements = arrayRotate[indexPath.section][findDifficultyElemForCell(indexPath,array: arrayRotate)]

            default: cell = nil
            }
            
            return cell
        }
        
        if main == 1 {
            var cell = tableView.dequeueReusableCellWithIdentifier("ElementsValuesTVCell") as! ElementsValuesTVCell!
            cell.delegate = self
            cell.selectionStyle = .None
            
            switch support {
            case 0:
                var elementsForCell = arrayFandO[(indexPath.row)/2][(indexPath.row) % 2]
                let helper = SimpleCellElement()
                if indexPath.row % 2 == 0 {
                    cell.headerImage.image = UIImage(named: "sub" + String(indexPath.row/2) + ".png")
                    helper.imageForCard = UIImage(named: "fund.png")
                    helper.name = "В строке представлены Фундаментальные технические группы движений с данным предметом"
                    
                }
                else {
                    helper.imageForCard = UIImage(named: "other.png")
                    helper.name = "В строке представлены Другие технические группы движений с данным предметом"
                }
                elementsForCell.insert(helper, atIndex: 0)
                cell.elements = elementsForCell
                cell.labelValue.hidden = true
                cell.headerImage.hidden = false
            case 1:
                cell.elements = arrayMasterCriteria[indexPath.row]
                cell.labelValue.hidden = true
                cell.headerImage.hidden = true
            case 2:
                cell.headerImage.image = UIImage(named: "DERheader_" + String(indexPath.row) + ".png")
                cell.elements = arrayRiskDER[indexPath.row]
                cell.labelValue.hidden = true
                cell.headerImage.hidden = false
                
            default: cell = nil
            }
            
            return cell
        }
        
        if main == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ElementsValuesTVCell") as! ElementsValuesTVCell!
            cell.headerImage.image = UIImage(named: "addheader_" + String(indexPath.row) + ".png")
            cell.delegate = self
            cell.selectionStyle = .None

            cell.elements = arrayAddings[indexPath.row]
            cell.labelValue.hidden = true
            cell.headerImage.hidden = false
            
            return cell
        }

        return UITableViewCell()
    }

    
    func findDifficultyElemForCell(index: NSIndexPath, array: [[[SimpleCellElement]]]) -> Int {
        var k = 0 //счетчик
        var currIndex = 0
        //бежим по массивам в поисках следующего непустого
        while k < array[index.section].count {
            if array[index.section][k].count != 0 {
                if currIndex == index.row {return k}
                else {currIndex++}
            }
            k++
        }
        return k
    }
    
    var header: UILabel!
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == cardTableView {
            //let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            //view.backgroundColor = UIColor.tr
            return nil
        }
        
        let main = mainSegmentedControl.selectedSegmentIndex
        let support = supportSegmentedControl.selectedSegmentIndex
        
        var view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 35))
        let label: UILabel = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width, height: 35))
        
        if main == 0 {
            label.backgroundColor = UIColor.whiteColor()
            //label.textAlignment
            label.text = sectionHeaders()[supportSegmentedControl.selectedSegmentIndex][section]
            view.addSubview(label)
            return view
        }
        if main == 1 && support == 0 {
            view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 70))
            view.backgroundColor = supportSegmentedControl.backgroundColor
            //label.textAlignment
            label.numberOfLines = 3
            label.text = ""
            header = label
            view.addSubview(label)
            return view
        }
        if main == 1 {
            view.backgroundColor = supportSegmentedControl.backgroundColor
            //label.textAlignment
            label.text = ""
            header = label
            view.addSubview(label)
            return view
        }
        
        return nil
        
    }
    
    @IBAction func editInfoButtonTouch(sender: UIButton) {
        self.performSegueWithIdentifier("editCardInfo", sender: allCardContent.card)
    }
    
    
    //1 клик по элементу в общей таблице всех элементов
    func singleClickToElementInElValCell(currElement: SimpleCellElement) {
        
        let main = mainSegmentedControl.selectedSegmentIndex
        
        if main == 0 {
            descriptElemLabel.text = currElement.name
            descriptElemImageView.image = currElement.imageDescription
        }
        if main == 1 {
            header?.text = currElement.name
        }
    }

    

    //2 клик по элементу в общей таблице всех элементов
    func doubleClickToElementInElValCell(currElement: SimpleCellElement) {
        if currentCell.imageViews == nil {
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            currentCell = cardTableView.cellForRowAtIndexPath(indexPath) as! MainCardTVCell
            reSelectCellInMainTable(currentCell)
            resetHighlight()
        }

        let indexPath = cardTableView.indexPathForCell(currentCell)
        if indexPath != nil {
            if currElement.imageName.hasPrefix("add_0_6") {
                let probelElem = SimpleCellElement(name: "", imName: currElement.imageName, imageCard: UIImage(named: "probel.png")!, imageDescr: nil, value: 0)
                
                if currentCell.addElement(probelElem, animatedTag: -1) {
                    allCardContent.content[indexPath!.row].addElement(probelElem)
                    cardPropertiesView.TotalValueLabel.text = allCardContent.totalValue.description
                }
            }
            else
            if currentCell.addElement(currElement, animatedTag: currentCell.elements.count()) {
                if currElement.imageName == "add_0_4" || currElement.imageName == "M_17" {
                    firstStepView.hidden = true
                    secondStepView.hidden = true
                    masterShowView.hidden = false
                }
                allCardContent.content[indexPath!.row].addElement(currElement)
                cardPropertiesView.TotalValueLabel.text = allCardContent.totalValue.description
            }
  
            else {
                let alert = UIAlertController(title: "Недостаточно места", message: "Границы строчек карточки не позволяют добавить элемент в данную строку", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "ОК", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            allCardContent.blocked = true
            
        //пересчет показателей карточки
            cardPropertiesView.recountProperties(allCardContent)
        }
    }
    
    
    //1 клик по элементу в таблице карточки
    func singleClickToElementInMainCell(index: Int, cell: MainCardTVCell) {
        currentCell = cell
        reSelectCellInMainTable(currentCell)
        resetHighlight()
        
        selectedElement = cell.elements.row[index]
        deleteElementButton.hidden = false
        
        for imView in cell.imageViews {
            if imView.tag == index {
                //imView.highlightedImage = imView.image!.imageWithTint(/*UIColor.redColor()*/"red")
                //imView.highlightedImage = imView.image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                    //[theImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            
                //[theImageView setTintColor:[UIColor redColor]];
                //imView.highlighted = true
                imView.image = imView.image!.imageWithRenderingMode(.AlwaysTemplate)
                imView.tintColor = UIColor.redColor()
            }
            else {
                imView.tintColor = UIColor.blackColor()
                //imView.highlightedImage = nil
            }
        }
        //!! взять индекс ячейки в общем списке, но только если она видимая
        //let indexPath = cardTableView.indexPathForCell(cell)
    }
    
    //передвижение элементов внутри ячейки
    var beginX: CGFloat = 0.0
    var beginY: CGFloat = 0.0
    
    var beginRect = CGRect()
    
    var choosenElem = SimpleCellElement()
    
    func dragElementInElValCell(recognizer: UIPanGestureRecognizer, currElement: SimpleCellElement, cell: MainCardTVCell) {
        currentCell = cell
        reSelectCellInMainTable(cell)

        
        let translation = recognizer.translationInView(recognizer.view!.superview!)
        let draggingView = recognizer.view! as! UIImageView
       
        
        if recognizer.state == UIGestureRecognizerState.Began {
            currentCell.contentView.bringSubviewToFront(recognizer.view!)
            
            beginX = recognizer.view!.center.x
            beginY = recognizer.view!.center.y
            beginRect = recognizer.view!.frame
            
        }
        
        if recognizer.state == UIGestureRecognizerState.Changed
        {
            if let view = recognizer.view {
                view.center = CGPoint(x:view.center.x + translation.x,
                    y:view.center.y + translation.y)
                
                for imView in currentCell.imageViews {
                    let intersectionRect = CGRectIntersection(imView.frame, draggingView.frame)
                    if imView.image != nil && imView.tag != draggingView.tag && (intersectionRect.width > draggingView.frame.width/2 || intersectionRect.width > imView.frame.width/2) {
                        //imView.highlightedImage = imView.image!.imageWithTint(/*UIColor.blueColor()*/"blue")
                        //imView.highlighted = true
                        imView.tintColor = UIColor(red: 186/255, green: 115/255, blue: 221/255, alpha: 1)
                        choosenElem = currentCell.elements.row[imView.tag]
                    }
                    else {
                        if draggingView.tag == imView.tag {
                            //imView.highlightedImage = imView.image!.imageWithTint(/*UIColor.blueColor()*/"blue")
                            imView.tintColor = UIColor(red: 186/255, green: 115/255, blue: 221/255, alpha: 1)
                            //imView.highlighted = true
                        }
                        else {
                            imView.tintColor = UIColor.blackColor()
                            //imView.highlighted = false
                            //imView.highlightedImage = nil
                        }
                    }
                }
            }
            recognizer.setTranslation(CGPointZero, inView: currentCell)
        }
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            for imView in currentCell.imageViews {
                if imView.image != nil && imView.tintColor != UIColor.blackColor() && currentCell.elements.row[imView.tag] == choosenElem {
                    currentCell.elements.row.removeAtIndex(draggingView.tag)
                    allCardContent.content[cardTableView.indexPathForCell(currentCell)!.row].row.removeAtIndex(draggingView.tag)
                    
                    currentCell.elements.row.insert(currElement, atIndex: imView.tag)
                    allCardContent.content[cardTableView.indexPathForCell(currentCell)!.row].row.insert(currElement, atIndex: imView.tag)
                    currentCell.reload(currentCell.elements, viewTag: draggingView.tag, rect: beginRect, animatedTag: imView.tag)
                    resetHighlight()
                    deleteElementButton.hidden = true
                    allCardContent.blocked = true
                    return
                }
            }
            recognizer.view!.center = CGPoint(x : beginX , y : beginY)
        }
        
    }
    
    func editingValueInCellDidEnd(cell: MainCardTVCell, value: Double) {
        allCardContent.content[cardTableView.indexPathForCell(cell)!.row].totalVal = value
    }
    
    @IBAction func deleteElementButtonClicked(sender: AnyObject) {
        deleteElementButton.hidden = true
        for imView in currentCell.imageViews {
            imView.tintColor = UIColor.blackColor()
            //imView.highlighted = false
            //imView.highlightedImage = nil
        }
        currentCell.removeElement(selectedElement)
        allCardContent.content[cardTableView.indexPathForCell(currentCell)!.row].removeElement(selectedElement)
        
        if selectedElement.imageName.hasPrefix("M_M") {
            firstStepView.hidden = true
            secondStepView.hidden = true
            masterShowView.hidden = false
        }
        
        allCardContent.blocked = true
        cardPropertiesView.recountProperties(allCardContent)
        
    }
    
    
    @IBOutlet weak var firstStepView: UIView!
    @IBOutlet weak var secondStepView: UIView!
    
    @IBOutlet weak var masterShowView: UIView!

    @IBAction func touchMasterAddButton(sender: UIButton) {
        masterShowView.hidden = true
        firstStepView.hidden = false
        secondStepView.hidden = false
        
        if currentCell.imageViews == nil {
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            currentCell = cardTableView.cellForRowAtIndexPath(indexPath) as! MainCardTVCell
            reSelectCellInMainTable(currentCell)
            resetHighlight()
        }
        
        let element = SimpleCellElement(name: "", imName: "M_M.png", imageCard: UIImage(named: "M_M.png")!, imageDescr: nil, value: 0.0)
        currentCell.addElement(element, animatedTag: currentCell.elements.count())
        allCardContent.content[cardTableView.indexPathForCell(currentCell)!.row].addElement(element)
        currentCell.value += 0.3
        cardPropertiesView.setM(++cardPropertiesView.countMaster)
        GA.screen("editor:masterPush")
    }
    

    
    @IBAction func saveButtonClick(sender: AnyObject) {
        allCardContent.countF = cardPropertiesView.countF
        allCardContent.countO = cardPropertiesView.countO
        allCardContent.countDiff = cardPropertiesView.countD
        allCardContent.countDER = cardPropertiesView.countDer
        allCardContent.countM = cardPropertiesView.countMaster
        
        let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fileAbsoluteUrl = documentsUrl.URLByAppendingPathComponent(allCardContent.getName() + ".card")
        NSKeyedArchiver.archiveRootObject(allCardContent, toFile: fileAbsoluteUrl.path!)
        
        let cardsNames = NSUserDefaults.standardUserDefaults()
        var namesArr = cardsNames.arrayForKey(names) as! [String]
        if namesArr.filter({ $0 == self.allCardContent.getName() }).count == 0 {
            namesArr.append(allCardContent.getName())
        }
        cardsNames.setObject(namesArr, forKey: names)
        
        checkRules()
        
        go()
    }
    
    func checkRules() {
        if cardPropertiesView.countMaster > 5 { showAlert("Нарушение правил", message: "Количество элементов мастерства превышает границу, установленную правилами художественной гимнастики(max 5).")
        }
        
        if cardPropertiesView.dance == 0 { showAlert("Нарушение правил", message: "В правилах художественной гимнастики предусмотрена как минимум одна дорожка танцевальных шагов в упражнении. В вашей программе ее нет.")
        }
        
        if cardPropertiesView.countD > 9 { showAlert("Нарушение правил", message: "Количество элементов трудности тела превышает границу, установленную правилами художественной гимнастики(max 9).")
        }
        
        if cardPropertiesView.countDer > 3 { showAlert("Нарушение правил", message: "Количество элементов риска превышает границу, установленную правилами художественной гимнастики(max 3 DER в упражнении).")
        }
        
        if cardPropertiesView.countDer < 6{ showAlert("Нарушение правил", message: "Добавлено недостаточно элементов типа «Трудность тела». По правилам их количество должно быть не менее 6.")
        }
        
    }
    
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Продолжить", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction) in self.go()}))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func go () {
        self.performSegueWithIdentifier("saveAndShow", sender: allCardContent)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "saveAndShow":
                if let controller = segue.destinationViewController as? CardPDFViewController {
                    controller.cardContent = sender as! CardContent
                    controller.openedFromEditor = true
                    GA.screen("editor->pdf")
                }
            case "editCardInfo":
            if let controller = segue.destinationViewController as? CreateCardViewController{
                controller.cardInf = sender as! CardInfo
                controller.openedFromEditor = true
                controller.cardContent = allCardContent
                GA.screen("editor->editInfo(createCard)")
                }
               default: break
                
            }
            

        }
    }
    
    //видимость того, что ячейка выбрана
    func reSelectCellInMainTable(selectedCell: MainCardTVCell) {
        var cel = MainCardTVCell()
        for cell in cardTableView.visibleCells {
            cel = cell as! MainCardTVCell
            if cel  == selectedCell {
                cel.hiddenBack.hidden = false
            }
            else {
                cel.hiddenBack.hidden = true
            }
        }
    }
    
    //делает изображения во всех ячейках обычными
    func resetHighlight() {
        for mainTableCell in cardTableView.visibleCells {
            let cell = mainTableCell as! MainCardTVCell
            for imageView in cell.imageViews {
                imageView.tintColor = UIColor.blackColor()
                //imageView.highlighted = false
            }
        }
    }
    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
    
    
    ///в метод подается строка "leap"(прыжжок) "bala"(равновесие) "rota"(поворот)
    ///на выходе готовый массив с распределенными элементами
    func loadDifficulty(difficultyType: String) -> [[[SimpleCellElement]]] {
        //нужно заполнить пустыми массивами
        //добавил только один
        var difficultyArray: [[[SimpleCellElement]]] = [[[]]]
        
        let bundleRoot: NSString = NSBundle .mainBundle().bundlePath
        let fm: NSFileManager = NSFileManager.defaultManager()
        let dirContent: NSArray = try! fm.contentsOfDirectoryAtPath(bundleRoot as String)

        for imageName in dirContent as! [String] {  //$$ если сразу написать as [String] - будет проще
            if imageName.hasPrefix(difficultyType) && !imageName.hasSuffix("_pic.png") {  //$$ и нужно убрать _pic
                //убираем из имени .png
                let imName = imageName.componentsSeparatedByString(".")
                let nameComponents = imName[0].componentsSeparatedByString("_")
                let simpElem: SimpleCellElement = SimpleCellElement()
                if nameComponents.count == 1 {continue}
                simpElem.imageName = imName[0]
                
                //здесь вообще некрасиво, но лучше придумать не могу
                simpElem.value = Double(Int(nameComponents[2])!) * 0.1
                
                //индексы по которым заполняем массивы
                let s = imageName[5] == "_" ? "" : imageName[5]
                let ind1 = Int((imageName[4] + s))! - 1 //изначально у String нет индексатора []
                let ind2 = Int(nameComponents[2])! - 1
                let ind3 = Int(nameComponents[1])!
                
                //это когда я заполню массив всеми определениями элементов
                simpElem.name = loadNameFromList(difficultyType, key: simpElem.imageName)
                
                let mainImage: UIImage = UIImage(named: imageName)!

                //TODO ПРОВЕРИТЬ НЕ ДОБАВЛЯЕТСЯ ЛИ ТЕПЕРЬ pic после .png. да так и будет:(
                let supImName = imName[0] + "_pic.png"
                let supportImage: UIImage? = UIImage(named: supImName)
                
                simpElem.imageForCard = mainImage
                simpElem.imageDescription = supportImage
                
                while difficultyArray.count < ind1 + 1 {
                    difficultyArray.append([[SimpleCellElement]]()) }
                
                while difficultyArray[ind1].count < ind2 + 1 { difficultyArray[ind1].append([SimpleCellElement]()) }
                
                if difficultyArray[ind1][ind2].count < ind3 + 1 { difficultyArray[ind1][ind2].append(simpElem) }
                else { difficultyArray[ind1][ind2].insert(simpElem, atIndex: ind3) }
            }
        }
        
        return difficultyArray
    }



func loadFandO() -> [[[SimpleCellElement]]] {
    var subjectGroupArray: [[[SimpleCellElement]]] = [[[]]]
    
    let bundleRoot: NSString = NSBundle .mainBundle().bundlePath
    let fm: NSFileManager = NSFileManager.defaultManager()
    let dirContent: NSArray = try! fm.contentsOfDirectoryAtPath(bundleRoot as String)
    
    for imageName in dirContent as! [String] {
        if imageName.hasPrefix("sub_") {
            //убираем из имени .png
            let imName = imageName.componentsSeparatedByString(".")
            let nameComponents = imName[0].componentsSeparatedByString("_")
            let simpElem: SimpleCellElement = SimpleCellElement()
            
            simpElem.imageName = imName[0]
            
            if imageName[8] == "F" {
                simpElem.functional = true
            }
            if imageName[8] == "O" {
                simpElem.functional = false
            }
            
            //индексы по которым заполняем массивы
            //номер предмета
            let ind1 = Int(nameComponents[1])!
            //functional or other
            let ind2 = nameComponents[3] == "O" ? 1: 0
            //номер элемента в строке (+1 тк первой будет другая картинка)
            let ind3 = Int(nameComponents[2])! + 1
            
            //это когда я заполню массив всеми определениями элементов
            simpElem.name = loadNameFromList("sub", key: simpElem.imageName)
            
            let mainImage: UIImage = UIImage(named: imageName)!
            simpElem.imageForCard = mainImage
            
            while subjectGroupArray.count < ind1 + 1 {
                subjectGroupArray.append([[SimpleCellElement]]()) }
            
            while subjectGroupArray[ind1].count < ind2 + 1 { subjectGroupArray[ind1].append([SimpleCellElement]()) }
            
            if subjectGroupArray[ind1][ind2].count < ind3 + 1 { subjectGroupArray[ind1][ind2].append(simpElem) }
            else { subjectGroupArray[ind1][ind2].insert(simpElem, atIndex: ind3) }
        }
    }
    
    return subjectGroupArray

}

func loadMaster() -> [[SimpleCellElement]] {
    var masterArray: [[SimpleCellElement]] = [[]]
    
    let bundleRoot: NSString = NSBundle .mainBundle().bundlePath
    let fm: NSFileManager = NSFileManager.defaultManager()
    let dirContent: NSArray = try! fm.contentsOfDirectoryAtPath(bundleRoot as String)
    
    for imageName in dirContent as! [String] {
        if imageName.hasPrefix("M_") && !imageName.hasSuffix("M.png"){
            //убираем из имени .png
            let imName = imageName.componentsSeparatedByString(".")
            let nameComponents = imName[0].componentsSeparatedByString("_")
            let simpElem: SimpleCellElement = SimpleCellElement()
            
            simpElem.imageName = imName[0]
            
            //индексы по которым заполняем массивы
            let ind = Int(nameComponents[1])!
            var ind1 = 0
            var ind2 = 0
            
            if ind > 8 {
                ind1 = 1
                ind2 = ind - 9
            }
            else {
                ind1 = 0
                ind2 = ind
            }
            
            //это когда я заполню массив всеми определениями элементов
            simpElem.name = loadNameFromList("M", key: simpElem.imageName)
            
            let mainImage: UIImage = UIImage(named: imageName)!
            simpElem.imageForCard = mainImage
            
            while masterArray.count < ind1 + 1 {
                masterArray.append([SimpleCellElement]())
            }
            
            if masterArray[ind1].count < ind2 + 1 { masterArray[ind1].append(simpElem) }
            else { masterArray[ind1].insert(simpElem, atIndex: ind2) }
        }
    }
    
    return masterArray
}

func loadRisks() -> [[SimpleCellElement]] {
    var riskArray: [[SimpleCellElement]] = [[]]
    
    let bundleRoot: NSString = NSBundle .mainBundle().bundlePath
    let fm: NSFileManager = NSFileManager.defaultManager()
    let dirContent: NSArray = try! fm.contentsOfDirectoryAtPath(bundleRoot as String)
    
    for imageName in dirContent as! [String] {
        if imageName.hasPrefix("DER_"){
            //убираем из имени .png
            let imName = imageName.componentsSeparatedByString(".")
            let nameComponents = imName[0].componentsSeparatedByString("_")
            let simpElem: SimpleCellElement = SimpleCellElement()
            
            simpElem.imageName = imName[0]
            
            //индексы по которым заполняем массив
            let ind1 = Int(nameComponents[1])!
            let ind2 = Int(nameComponents[2])!
            
            //это когда я заполню массив всеми определениями элементов
            simpElem.name = loadNameFromList("DER", key: simpElem.imageName)
            
            let mainImage: UIImage = UIImage(named: imageName)!
            simpElem.imageForCard = mainImage
            
            while riskArray.count < ind1 + 1 {
                riskArray.append([SimpleCellElement]())
            }
            
            if riskArray[ind1].count < ind2 + 1 { riskArray[ind1].append(simpElem) }
            else { riskArray[ind1].insert(simpElem, atIndex: ind2) }
        }
    }
    
    return riskArray
}

func loadAddings() -> [[SimpleCellElement]] {
    var addArray: [[SimpleCellElement]] = [[]]
    
    let bundleRoot: NSString = NSBundle .mainBundle().bundlePath
    let fm: NSFileManager = NSFileManager.defaultManager()
    let dirContent: NSArray = try! fm.contentsOfDirectoryAtPath(bundleRoot as String)
    
    for imageName in dirContent as! [String] {
        if imageName.hasPrefix("add_"){
            if imageName.hasPrefix("add_probel") {continue}
            //убираем из имени .png
            let imName = imageName.componentsSeparatedByString(".")
            let nameComponents = imName[0].componentsSeparatedByString("_")
            let simpElem: SimpleCellElement = SimpleCellElement()
            
            //индексы по которым заполняем массивы
            
            let ind1 = Int(nameComponents[1])!
            let ind2 = Int(nameComponents[2])!
            
            let mainImage: UIImage = UIImage(named: imageName)!
            simpElem.imageForCard = mainImage
            simpElem.imageName = imName[0]
            
            while addArray.count < ind1 + 1 {
                addArray.append([SimpleCellElement]())
            }
            
            if addArray[ind1].count < ind2 + 1 { addArray[ind1].append(simpElem) }
            else { addArray[ind1].insert(simpElem, atIndex: ind2) }
        }
    }
    
    return addArray
}
    
    func loadNameFromList (keyDictionary: String, key: String) -> String {
        if let path = NSBundle.mainBundle().pathForResource("DescriptionElementList", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
                var apDict = dict[keyDictionary] as! Dictionary<String, String>
                let name = apDict[key] as String?
                if name == nil {return ""}
                return name!
            }
        }
        return ""
    }

func sectionHeaders() -> [[String]] {
    var sectionHeaders: [[String]] = [[]]
    
    sectionHeaders.append([String]())
    
    sectionHeaders[0].append("1. Вертикальные прыжки с вращением всего тела на 180, а также на 360")
    sectionHeaders[0].append("2. \"Кабриоль\"(вперед, в сторону, назад), \"прогнувшись\"")
    sectionHeaders[0].append("3. Прыжки со сменой ног в различных положениях")
    sectionHeaders[0].append("4. \"Щука\", прыжок ноги врозь с наклоном туловища вперед")
    sectionHeaders[0].append( "5. \"Казак\" ноги в различных положениях, в кольцо")
    sectionHeaders[0].append( "6. Кольцо")
    sectionHeaders[0].append("7. \"Фуэте\" ноги в различных положениях")
    sectionHeaders[0].append("8. Перекидной ноги в различных положениях")
    sectionHeaders[0].append("9. Прыжки с шагом и подбивной: \nв кольцо, с наклоном туловища назад, с вращением туловища (толчком с 1 или 2 ног)")
    sectionHeaders[0].append("10. Прыжки жете ан турнан - ноги в различных положениях")
    sectionHeaders[0].append("11. \"Баттерфляй\"")
    
    sectionHeaders.append([String]())
    
    sectionHeaders[1].append("1. Свободная нога ниже горизонтали или пассе (с наклоном туловища вперед, назад или без)")
    sectionHeaders[1].append("2. Свободная нога горизонтально в различных направлениях;\n наклон туловища вперед, назад, в сторону")
    sectionHeaders[1].append("3. Свободная нога вверх в разных направлениях; наклон туловища вперед, назад, в сторону")
    sectionHeaders[1].append("4. \"Фуэте\" (мин 3 разные формы на релеве с мин 1 поворотом на 90 или 180)")
    sectionHeaders[1].append("5. \"Казак\" свободная нога горизонтально или выше; с изменением уровня гимнастки")
    sectionHeaders[1].append("6. Равновесие с опорой на различные части тела")
    sectionHeaders[1].append("7. Динамическое равновесие с полной волной телом")
    sectionHeaders[1].append("8. Динамическое равновесие с движением или без движения ног с опорой на различные части тела")
    
    sectionHeaders.append([String]())
    
    sectionHeaders[2].append("1. Свободная нога ниже горизонтали; пассе; наклон туловища вперед или назад; спиральный поворот с волной")
    sectionHeaders[2].append("2. Свободная нога выпрямлена или согнута горизонтально;\n наклон туловища горизонтально")
    sectionHeaders[2].append("3. Свободная нога вверх с помощью или без помощи рук; туловище горизонтально или выше")
    sectionHeaders[2].append("4. \"Казак\" (свободная нога горизонтально); наклон туловища")
    sectionHeaders[2].append("5. \"Фуэте\"")
    sectionHeaders[2].append("6. Циркуль вперед, в сторону, назад; спиральный поворот с полной волной; вращение \"penche\"")
    sectionHeaders[2].append("7. Вращения на различных частях тела")
    
    return sectionHeaders
}
}



//$$ лучше вынести отдельно в файл типа String+Subscript.swift
extension String {
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
    }
}
