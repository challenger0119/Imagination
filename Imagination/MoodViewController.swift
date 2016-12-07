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
            self.placeInfo = (self.place!.name!,self.place!.location!.coordinate.latitude, self.place!.location!.coordinate.longitude)
        }
    }
    
    var placeInfo:(name:String,latitude:Double,longtitude:Double)?{
        didSet{
            if self.getLocBtn != nil && self.getLocBtn.titleLabel != nil{
                self.getLocBtn.setTitle(self.placeInfo!.name, for: .normal)
            }
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        if editMode {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            content.text = text
            self.content.isEditable = false
            if self.placeInfo != nil {
                self.getLocBtn.setTitle(self.placeInfo!.name, for: .normal)
            }
        }else{
            self.content.becomeFirstResponder()
        }
        switch moodState {
        case 1:
            self.noGoodBtn.backgroundColor = Item.defaultColor
            self.noGoodBtn.setTitleColor(UIColor.lightGray, for: UIControlState())
            self.goodBtn.backgroundColor = Item.coolColor
            self.goodBtn.setTitleColor(UIColor.white, for: UIControlState())
        case 2:
            self.noGoodBtn.backgroundColor = Item.justOkColor
            self.noGoodBtn.setTitleColor(UIColor.white, for: UIControlState())
            
            self.goodBtn.setTitleColor(UIColor.lightGray, for: UIControlState())
            self.goodBtn.backgroundColor = Item.defaultColor
        default: break
        }
        
        
        let backItem = UIBarButtonItem()
        backItem.title = "返回"
        self.navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func noGoodBtnClicked() {
        if moodState == 2 {
            moodState = 0;
            self.noGoodBtn.backgroundColor = Item.defaultColor
            self.noGoodBtn.setTitleColor(UIColor.lightGray, for: UIControlState())
            return
        }
        moodState = 2
        self.noGoodBtn.backgroundColor = Item.justOkColor
        self.noGoodBtn.setTitleColor(UIColor.white, for: UIControlState())
        
        self.goodBtn.setTitleColor(UIColor.lightGray, for: UIControlState())
        self.goodBtn.backgroundColor = Item.defaultColor
    }
    @IBAction func goodBtnClicked() {
        if moodState == 1 {
            moodState = 0;
            self.goodBtn.backgroundColor = Item.defaultColor
            self.goodBtn.setTitleColor(UIColor.lightGray, for: UIControlState())
            return
        }
        moodState = 1
        self.noGoodBtn.backgroundColor = Item.defaultColor
        self.noGoodBtn.setTitleColor(UIColor.lightGray, for: UIControlState())
        self.goodBtn.backgroundColor = Item.coolColor
        self.goodBtn.setTitleColor(UIColor.white, for: UIControlState())
    }
   
    func closeKeyboard() {
        content.resignFirstResponder()
        self.bottomContraint.constant = self.keyboardDistance;
    }
    
    func keyboardWillShow(_ notifi:Foundation.Notification){
        if let info = (notifi as NSNotification).userInfo {
            if let kbd = info[UIKeyboardFrameEndUserInfoKey] {
                keyBoardHeight = (kbd as AnyObject).cgRectValue.size.height
                self.bottomContraint.constant = keyBoardHeight + self.keyboardDistance
            }
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.closeKeyboard()
    }
    

    @IBAction func done(_ sender: UIBarButtonItem) {
        self.closeKeyboard()
        if !self.content.text.isEmpty && self.moodState == 0 {
            let alert = UIAlertController(title: "提示", message: "确定不选择状态？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {
                action in
                self.doneAction()
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .default, handler: {
                action in
            }))
            self.present(alert, animated: true, completion: {
                
            })
        }else{
            self.doneAction()
        }
    }
    
    
    func doneAction() {
        let ttt = content.text
        if !(ttt?.isEmpty)! {
            //最终目的地 所有有能容更新的操作都在这里 无论是手动填写还是自动填写
            if self.place != nil {
                dataCache.newStringContent(ttt!, moodState: moodState,GPSPlace: self.place!)
            }else{
                dataCache.newStringContent(ttt!, moodState: moodState)
            }
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.keyForNewMoodAdded), object: nil)
            back()
        } else {
            if moodState != 0 {
                //自动填写
                switch moodState {
                case 1: content.text = "\"不言不语，毕竟言语无法表达我今天的快乐！！\""
                case 2: content.text = "\"可能这就是平凡的一天，但我不愿这样,不甘心。\""
                case 3: content.text = "\"生活不就是这样吗——开心与不开心交替出现。不是都说最有趣的路是曲曲折折的吗？加油!\""
                default: break
                }
                self.doneAction()
                
            }else{
                back()
            }
        }
    }
    func back() {
        self.dismiss(animated: true, completion: nil)
        /*
        if self.navigationController == nil {
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController!.popViewController(animated: true)
        }
 */
    }
    //MARK: -segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moodToLocation" {
            let vc = segue.destination as! LocationViewController
            if self.editMode && self.placeInfo != nil{
                vc.placeToShow = CLLocationCoordinate2D(latitude: self.placeInfo!.latitude, longitude: self.placeInfo!.longtitude)
            }else{
                vc.placeSelected = {
                    pls in
                    self.place = pls
                }
            }
        }
    }
    
}
