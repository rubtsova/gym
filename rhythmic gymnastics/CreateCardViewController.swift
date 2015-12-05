//
//  CreateCardViewController.swift
//  Rhythmic Gymnastics
//
//  Created by Наталья on 05.02.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//


import UIKit

class CreateCardViewController: UIViewController, UITextFieldDelegate{
    
    var cardContent: CardContent!
    
    var subject: Subject!
    var subjectChoosen = false
    var cardInf = CardInfo()
    var openedFromEditor: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Создание новой программы"
        createButton.setTitle("СОЗДАТЬ", forState: .Normal)
        
        for textF in fields {
            textF.delegate = self
        }
        if openedFromEditor {
            for button in buttons {
                if button.tag == cardInf.subject.rawValue {
                 button.selected = true
                    subjectChoosen = true
                }
            }
            if cardInf.musicVoice { musicSwitch.setOn(true, animated: true)}
            nameTextField.text = cardInf.cardName
            gymNameTextField.text = cardInf.gymName
            cityTextField.text = cardInf.city
            birthTextField.text = cardInf.birthyear.description
            coachTextField.text = cardInf.coach
            
            self.title = "Редактирование общей информации"
            createButton.setTitle("ГОТОВО", forState: .Normal)
            
            nameTextField.enabled = false
        }
        else {
            buttons[0].selected = true
            subject = Subject.getSubject(2)
            subjectChoosen = true
        }
    }
    
    @IBOutlet var fields: [UITextField]!
    
    @IBOutlet var buttons: [UIButton]!
    
    
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var musicSwitch: UISwitch!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var gymNameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var birthTextField: UITextField!
    @IBOutlet weak var coachTextField: UITextField!
    
    //чтобы клавиатура убралась
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func subjectButTouch(sender: UIButton) {
        for button in buttons {
                        if (button != sender) && button.selected == true {
                            UIView.animateWithDuration(0.1 , animations: {
                                sender.alpha = 0
                                }, completion: { finished in
                                    button.selected = false
                                    sender.selected = true
                                    UIView.animateWithDuration(0.3 , animations: {
                                        sender.alpha = 1
                                    })
                            })
            }
        }
        
        subject = Subject.getSubject(sender.tag)
        subjectChoosen = true
        }
    
    
    
    @IBAction func createButtonTouch(sender: UIButton) {
        var year: Int
        year = Int(birthTextField.text!) == nil ? -1 : Int(Int(birthTextField.text!)!)

        if cityTextField.text!.characters.count > 15 {
            showAlert("Измените поле", messageAlert: "Слишком длинное название города, в поле карточки не хватит места")
        }
        
        if nameTextField.text!.characters.count > 20 {
            showAlert("Измените поле", messageAlert: "Слишком длинное имя гимнастки, в поле карточки не хватит места")
        }
       
        //check text fields (empty or not)
        for textField in fields {
            if (textField.text == "") {
                showAlert("Заполните все поля", messageAlert: "Для продолжения создания карточки заполните все поля")
                textField.alpha = 0
                UIView.animateWithDuration(0.4 , animations: {
                    textField.backgroundColor = UIColor(red: 191.0/255, green: 154.0/255, blue: 208.0/255, alpha: 1)
                    textField.alpha = 1})
                GA.event("createCard_fieldIsEmpty")
                return
            }
            
            else {textField.backgroundColor = UIColor.whiteColor()}
        }
        
        for but in buttons {
            if but.selected == true {
                subjectChoosen = true
                subject = Subject.getSubject(but.tag) }
        }
        
        if (year < 0 || year > 2015)
        {
            birthTextField.alpha = 0
            UIView.animateWithDuration(0.4 , animations: {
                self.birthTextField.backgroundColor = UIColor(red: 191.0/255, green: 154.0/255, blue: 208.0/255, alpha: 1)
                
                self.birthTextField.alpha = 1
            })
            GA.event("createCard_yearNeOk")
            
            return
        }
        
        if !subjectChoosen {
            showAlert("Предмет не выбран", messageAlert: "Чтобы продолжить создание карточки, выберите предмет для программы выступления")
        }
        
        let cardsNames = NSUserDefaults.standardUserDefaults()
        let namesArr = cardsNames.arrayForKey(names) as! [String]
        
        if !openedFromEditor {
            for item in namesArr {
                if item == nameTextField.text {
                    showAlert("Измените название", messageAlert: "Карточка с таким названием уже существует, измените его на другое")
                }
            }
        }

        let musicVoice = musicSwitch.on
        cardInf = CardInfo(cardName: nameTextField.text!, gymName: gymNameTextField.text!, city: cityTextField.text!, birthyear: Int(birthTextField.text!)!, coach: coachTextField.text!, subject: subject, music: musicVoice)
        
        
        self.performSegueWithIdentifier("create", sender: cardInf)
        
        }
    
    func showAlert(titleAlert: String, messageAlert: String) {
        let alert = UIAlertController(title: titleAlert, message: messageAlert, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "ОК", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? CardEditorViewController {
            controller.card = sender as! CardInfo
            controller.allCardContent = cardContent
        }
        GA.event("createCard_editor")
    }
}
