//
//  MoodViewController.swift
//  Imagination
//
//  Created by Star on 16/1/2.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit
import CoreLocation
class MoodViewController: UIViewController,UIAlertViewDelegate {

    let dataCache = DataCache.shareInstance
    var editMode = false
    var moodState = 0
    var keyBoardHeight:CGFloat = 216.0
    var clockDic = Dictionary<String,String>()
    var text:String = " "
    let keyboardDistance:CGFloat = 20
    var place:CLPlacemark?{
        didSet{
            self.getLocBtn.setTitle(self.place!.name, forState: .Normal)
        }
    }
    
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var goodBtn: UIButton!
    @IBOutlet weak var noGoodBtn: UIButton!
    @IBOutlet weak var getLocBtn: UIButton!
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(closeKeyboard)))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        if editMode {
            self.navigationItem.rightBarButtonItem?.enabled = false
            content.text = text
        }
        
        switch moodState {
        case 1:
            noGoodBtnClicked()
        case 2:
            goodBtnClicked()
        default: break
        }
        self.content.becomeFirstResponder()
        let backItem = UIBarButtonItem()
        backItem.title = "返回"
        self.navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func noGoodBtnClicked() {
        moodState = 2
        self.noGoodBtn.backgroundColor = Item.justOkColor
        self.noGoodBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        self.goodBtn.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        self.goodBtn.backgroundColor = Item.defaultColor
    }
    @IBAction func goodBtnClicked() {
        moodState = 1
        self.noGoodBtn.backgroundColor = Item.defaultColor
        self.noGoodBtn.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        self.goodBtn.backgroundColor = Item.coolColor
        self.goodBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
   
    func closeKeyboard() {
        content.resignFirstResponder()
        self.bottomContraint.constant = self.keyboardDistance
    }
    
    func keyboardWillShow(notifi:NSNotification){
        if let info = notifi.userInfo {
            if let kbd = info[UIKeyboardFrameEndUserInfoKey] {
                keyBoardHeight = kbd.CGRectValue.size.height
                self.bottomContraint.constant = keyBoardHeight + self.keyboardDistance
            }
        }
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.closeKeyboard()
    }
    

    @IBAction func done(sender: UIBarButtonItem) {
        self.closeKeyboard()
        if !self.content.text.isEmpty && self.moodState == 0 {
            let alert = UIAlertController(title: "提示", message: "确定不选择状态？", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: {
                action in
                self.doneAction()
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .Default, handler: {
                action in
            }))
            self.presentViewController(alert, animated: true, completion: {
                
            })
            
        }else{
            self.doneAction()
        }
    }
    func doneAction() {
        let ttt = content.text
        if !ttt.isEmpty {
            if self.place != nil {
                dataCache.newStringContent(ttt, moodState: moodState,GPSPlace: self.place!)
            }else{
                dataCache.newStringContent(ttt, moodState: moodState)
            }
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
    /*
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
 */
    /*
    func resumeScrollView() {
        let css = self.view.constraints
        for  cs in css {
            if cs.identifier == "keyboard" {
                NSLayoutConstraint.deactivateConstraints([cs])
                let new = NSLayoutConstraint.init(item: self.view, attribute: NSLayoutAttribute.Bottom, relatedBy:NSLayoutRelation.Equal, toItem: self.content, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: keyboardDistance)
                new.identifier = "keyboard"
                self.view.addConstraint(new)
            }
        }
    }
 */
    //MARK: -segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "moodToLocation" {
            let vc = segue.destinationViewController as! LocationViewController
            vc.placeSelected = {
                pls in
                self.place = pls
            }
        }
    }
    
}
