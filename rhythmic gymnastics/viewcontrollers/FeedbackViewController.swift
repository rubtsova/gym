//
//  FeedbackViewController.swift
//  rhythmic gymnastics
//
//  Created by Sergey Pronin on 10/23/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var labelPlaceholder: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textFieldEmail.delegate = self
        textView.delegate = self
        textView.contentInset.left = -4
    }

    @IBAction func tapCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func tapDone() {
        textView.resignFirstResponder()
        textFieldEmail.resignFirstResponder()
        
        guard let email = textFieldEmail.text, text = textView.text where email.characters.count > 0 && text.characters.count > 0 else {
            self.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        ServerHelper.sendFeedback(email, text: text)
        
        self.dismissViewControllerAnimated(true, completion: {
            UIAlertView(title: "Спасибо!", message: "Ваш отзыв был отправлен. Мы ответим вам в самое ближайшее время", delegate: nil, cancelButtonTitle: "ОК").show()
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textView.becomeFirstResponder()
        return false
    }
    
    func textViewDidChange(textView: UITextView) {
        labelPlaceholder.hidden = textView.text.characters.count > 0
    }
}
