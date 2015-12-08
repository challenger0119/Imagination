//
//  AddNewMind.swift
//  Imagination
//
//  Created by Star on 15/11/14.
//  Copyright © 2015年 Star. All rights reserved.
//

import UIKit

class EditImagination: UIViewController,UITextViewDelegate {
    let dataCache = DataCache.shareInstance
    var editMode = false
    var keyBoardHeight:CGFloat = 216.0
    var clockDic = Dictionary<String,String>()
    var text:String = " "
    @IBOutlet weak var content: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: "closeKeyboard"))
        content.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        if editMode {
            self.navigationItem.rightBarButtonItem?.enabled = false
            content.text = text
        }
    }
    
    func closeKeyboard() {
        resumeScrollView()
        content.resignFirstResponder()
    }
    
    func keyboardWillShow(notifi:NSNotification){
        if let info = notifi.userInfo {
            print(info)
            if let kbd = info[UIKeyboardFrameEndUserInfoKey] {
                keyBoardHeight = kbd.CGRectValue.size.height
                print(keyBoardHeight)
            }
        }
        
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
 
        let ttt = content.text
        if !ttt.isEmpty {
            if Time.today() == dataCache.lastDayName {
                dataCache.updateLastday(ttt, key: Time.clock())
            } else {
                dataCache.initLastday([Time.clock():ttt], lastdayName: Time.today())
            }
        }
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        let css = self.view.constraints
        for  cs in css {
            if cs.identifier == "keyboard" {
                NSLayoutConstraint.deactivateConstraints([cs])
                let new = NSLayoutConstraint.init(item: self.view, attribute: NSLayoutAttribute.BottomMargin, relatedBy:NSLayoutRelation.Equal, toItem: self.content, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: keyBoardHeight+60)
                new.identifier = "keyboard"
                self.view.addConstraint(new)
            }
        }
        return true
    }
    
    func resumeScrollView() {
        let css = self.view.constraints
        for  cs in css {
            if cs.identifier == "keyboard" {
                NSLayoutConstraint.deactivateConstraints([cs])
                let new = NSLayoutConstraint.init(item: self.view, attribute: NSLayoutAttribute.BottomMargin, relatedBy:NSLayoutRelation.Equal, toItem: self.content, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
                new.identifier = "keyboard"
                self.view.addConstraint(new)
            }
        }
    }
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        resumeScrollView()
        return true
    }
}
