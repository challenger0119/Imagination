//
//  MoodViewController.swift
//  Imagination
//
//  Created by Star on 16/1/2.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit

class MoodViewController: UIViewController {

    let dataCache = DataCache.shareInstance
    var editMode = false
    var keyBoardHeight:CGFloat = 216.0
    var clockDic = Dictionary<String,String>()
    var text:String = " "
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var cool: UIImageView!
    @IBOutlet weak var ok: UIImageView!
    @IBOutlet weak var why: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: "closeKeyboard"))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        if editMode {
            self.navigationItem.rightBarButtonItem?.enabled = false
            content.text = text
        } else {
            self.cool.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: "coolClicked"))
            self.ok.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: "okClicked"))
            self.why.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: "whyClicked"))
        }
    }
    
    func coolClicked() {
        self.cool.image = UIImage.init(named: "cool")
        self.ok.image = UIImage.init(named: "ok_gray")
        self.why.image = UIImage.init(named: "why_gray")
    }
    func okClicked() {
        self.cool.image = UIImage.init(named: "cool_gray")
        self.ok.image = UIImage.init(named: "ok")
        self.why.image = UIImage.init(named: "why_gray")
    }
    func whyClicked() {
        self.cool.image = UIImage.init(named: "cool_gray")
        self.ok.image = UIImage.init(named: "ok_gray")
        self.why.image = UIImage.init(named: "why")
    }
    func closeKeyboard() {
        resumeScrollView()
        content.resignFirstResponder()
    }
    
    func keyboardWillShow(notifi:NSNotification){
        if let info = notifi.userInfo {
            if let kbd = info[UIKeyboardFrameEndUserInfoKey] {
                keyBoardHeight = kbd.CGRectValue.size.height
            
                if keyBoardHeight > self.cool.frame.height {
                    keyBoardHeight = keyBoardHeight - self.cool.frame.height + 30
                } else {
                    if self.cool.frame.height - keyBoardHeight > 30 {
                        keyBoardHeight = 0
                    } else {
                        keyBoardHeight = 30 - (self.cool.frame.height - keyBoardHeight)
                    }
                }
                updateTextView()
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
    
    func updateTextView() {
        let css = self.view.constraints
        for  cs in css {
            if cs.identifier == "keyboard" {
                NSLayoutConstraint.deactivateConstraints([cs])
                let new = NSLayoutConstraint.init(item: self.cool, attribute: NSLayoutAttribute.Top, relatedBy:NSLayoutRelation.Equal, toItem: self.content, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: keyBoardHeight)
                new.identifier = "keyboard"
                self.view.addConstraint(new)
            }
        }
    }
    
    func resumeScrollView() {
        let css = self.view.constraints
        for  cs in css {
            if cs.identifier == "keyboard" {
                NSLayoutConstraint.deactivateConstraints([cs])
                let new = NSLayoutConstraint.init(item: self.cool, attribute: NSLayoutAttribute.Top, relatedBy:NSLayoutRelation.Equal, toItem: self.content, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
                new.identifier = "keyboard"
                self.view.addConstraint(new)
            }
        }
    }
}
