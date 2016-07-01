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
    var moodState = 0
    var keyBoardHeight:CGFloat = 216.0
    var clockDic = Dictionary<String,String>()
    var text:String = " "
    
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var cool: UIImageView!
    @IBOutlet weak var ok: UIImageView!
    @IBOutlet weak var why: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(closeKeyboard)))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        if editMode {
            self.navigationItem.rightBarButtonItem?.enabled = false
            content.text = text
        } else {
            self.cool.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(coolClicked)))
            self.ok.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(okClicked)))
            self.why.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(whyClicked)))
        }
        
        switch moodState {
        case 1:
            coolClicked()
        case 2:
            okClicked()
        case 3:
            whyClicked()
        default: break
        }
    }
    
    func coolClicked() {
        moodState = 1
        self.cool.image = UIImage.init(named: "cool")
        self.ok.image = UIImage.init(named: "ok_gray")
        self.why.image = UIImage.init(named: "why_gray")
    }
    func okClicked() {
        moodState = 2
        self.cool.image = UIImage.init(named: "cool_gray")
        self.ok.image = UIImage.init(named: "ok")
        self.why.image = UIImage.init(named: "why_gray")
    }
    func whyClicked() {
        moodState = 3
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
            
                keyBoardHeight += 30
                
                updateTextView()
            }
        }
        
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        self.content.endEditing(true)
        self.doneAction()
    }
    func doneAction() {
        let ttt = content.text
        if !ttt.isEmpty {
            dataCache.newStringContent(ttt, moodState: moodState)
        } else {
            if moodState != 0 {
                switch moodState {
                case 1: content.text = "\"不言不语，毕竟言语无法表达我今天的快乐！！\""
                case 2: content.text = "\"可能这就是平凡的一天，但我不愿这样,不甘心。\""
                case 3: content.text = "\"生活不就是这样吗——开心与不开心交替出现。不是都说最有趣的路是曲曲折折的吗？加油!\""
                default: break
                }
                self.doneAction()
            }
            
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateTextView() {
        let css = self.view.constraints
        for  cs in css {
            if cs.identifier == "keyboard" {
                NSLayoutConstraint.deactivateConstraints([cs])
                let new = NSLayoutConstraint.init(item: self.view, attribute: NSLayoutAttribute.Bottom, relatedBy:NSLayoutRelation.Equal, toItem: self.content, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: keyBoardHeight)
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
                let new = NSLayoutConstraint.init(item: self.view, attribute: NSLayoutAttribute.Bottom, relatedBy:NSLayoutRelation.Equal, toItem: self.content, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
                new.identifier = "keyboard"
                self.view.addConstraint(new)
            }
        }
    }
}
