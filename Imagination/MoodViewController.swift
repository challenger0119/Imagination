//
//  MoodViewController.swift
//  Imagination
//
//  Created by Star on 16/1/2.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit
import CoreLocation
class MoodViewController: UIViewController,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AudioRecordViewDelegate {

    let dataCache = DataCache.shareInstance
    //var editMode = false
    var moodState = 0
    var keyBoardHeight:CGFloat = 216.0
    var clockDic = Dictionary<String,String>()
    var text:String = " "
    let keyboardDistance:CGFloat = 10
    
    var place:(name:String,coor:CLLocationCoordinate2D)?{
        didSet{
            if self.place == nil {
                self.placeInfo = nil
            }else{
               self.placeInfo = (self.place!.name,self.place!.coor.latitude, self.place!.coor.longitude)
            }
        }
    }
    
    var placeInfo:(name:String,latitude:Double,longtitude:Double)?{
        didSet{
            if self.placeInfo != nil && self.getLocBtn != nil && self.getLocBtn.titleLabel != nil{
                self.getLocBtn.setTitle(self.placeInfo!.name, for: .normal)
            }
        }
    }
    
    
    var imageVC:UIImagePickerController!
    var multiMediaBufferDic:[Int:AnyObject]?
    
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var goodBtn: UIButton!
    @IBOutlet weak var noGoodBtn: UIButton!
    @IBOutlet weak var getLocBtn: UIButton!
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    
    @IBOutlet weak var getVideoBtn: UIButton!
    @IBOutlet weak var getVoiceBtn: UIButton!
    @IBOutlet weak var getImageBtn: UIButton!
    
    func hideFunctionBtns(){
        self.getVideoBtn.isHidden = true
        self.getVoiceBtn.isHidden = true
        self.getImageBtn.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(closeKeyboard)))
        let swipGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipDown))
        swipGesture.direction = .down
        self.view.addGestureRecognizer(swipGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        self.content.becomeFirstResponder()
        
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
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(gesture:)))
        self.getLocBtn.addGestureRecognizer(longPress)
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
   
    func longPressAction(gesture:UILongPressGestureRecognizer){
        if gesture.state == .began {
            removeLocation()
        }
    }
    func removeLocation(){
        self.place = nil
        self.getLocBtn.setTitle("获取地理位置", for: .normal)
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
            
            analysisTextStorage() //解析出附件 暂时只有图片
            
            dataCache.newString(Content: ttt!, moodState: moodState, GPSPlace: self.place, multiMedia: self.multiMediaBufferDic)
            
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
    func didSwipDown(){
        closeKeyboard()
        if !self.content.text.isEmpty {
            let alert = UIAlertController(title: "提示", message: "现在返回内容将丢失", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {
                action in
                self.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .default, handler: {
                action in
            }))
            self.present(alert, animated: true, completion: {
                
            })
        }else{
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    func back() {
        closeKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func analysisTextStorage(){
        //找到attachment  对比buffer 删除buffer中多余的attache 因为buffer只能增加
        self.content.textStorage.enumerateAttribute(NSAttachmentAttributeName, in: NSRange(location: 0,length: self.content.textStorage.length), options: NSAttributedString.EnumerationOptions(rawValue: 0), using:{
            (obj,range,pointor) in
            if let imageAttache = obj as? NSTextAttachment {
                if let image = imageAttache.image {
                    if self.multiMediaBufferDic == nil {
                        self.multiMediaBufferDic = [range.location:image]
                    }else{
                        let _ = self.multiMediaBufferDic?.updateValue(image, forKey: range.location)
                    }
                }
            }
        })
    }
    @IBAction func getAudio(_ sender: UIButton) {
        closeKeyboard()
        if let arView = AudioRecordView.getView() {
            arView.frame = CGRect(x: 20, y: self.view.frame.height - 160, width: self.view.frame.width-40, height: 100)
            arView.delegate = self
            self.view.addSubview(arView)
        }
    }
    @IBAction func getImage(_ sender: UIButton) {
        closeKeyboard()
        let queryVc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        queryVc.addAction(UIAlertAction(title: "相机", style: .default, handler: { (act) in
            self.imageVC = UIImagePickerController()
            self.imageVC.sourceType = .camera
            self.imageVC.delegate = self
            self.present(self.imageVC, animated: true, completion: {
                
            })
        }))
        queryVc.addAction(UIAlertAction(title: "相册", style: .default, handler: { (act) in
            self.imageVC = UIImagePickerController()
            self.imageVC.sourceType = .photoLibrary
            self.imageVC.delegate = self
            self.present(self.imageVC, animated: true, completion: {
                
            })
        }))
        queryVc.addAction(UIAlertAction(title: "取消", style: .destructive, handler: { (act) in
            queryVc.dismiss(animated: true, completion: nil)
        }))
        self.present(queryVc, animated: true, completion: nil)
        
    }
    
    func cutImage(_ image:UIImage,frame:CGRect)->UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        UIBezierPath(roundedRect: frame, cornerRadius: 5).addClip()
        image.draw(in: frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func addMultimediaToTextView(multimedia:AnyObject,at:Int = -1) {
        let imageWidth = self.content.frame.width - 10;
        
        if multimedia.isKind(of: UIImage.self) {
            let image = multimedia as! UIImage
            let textAttach = NSTextAttachment(data:nil, ofType: nil)
            let imageHeight = image.size.height / image.size.width * imageWidth
            textAttach.image = cutImage(image, frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
            let imageAttributeString = NSAttributedString(attachment:textAttach)
            
            if at == -1 {
                self.content.textStorage.insert(imageAttributeString, at: self.content.selectedRange.location)
            }else{
                //查看模式
                Dlog("add image at \(at)")
                self.content.textStorage.insert(imageAttributeString, at: at)
            }
        }else if multimedia.isKind(of: AudioRecord.self) {
            let audio = multimedia as! AudioRecord
            do{
                let data = try Data.init(contentsOf: audio.recordFileURL)
                let textAttach = NSTextAttachment(data: data, ofType: Item.MutiMediaType.voice.rawValue)
                let image = UIImage.init(named: "audio")!
                let imageHeight = image.size.height / image.size.width * imageWidth
                textAttach.image = cutImage(image, frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
                let imageAttributeString = NSAttributedString(attachment:textAttach)
                if at == -1 {
                    self.content.textStorage.insert(imageAttributeString, at: self.content.selectedRange.location)
                }else{
                    //查看模式
                    Dlog("add image at \(at)")
                    self.content.textStorage.insert(imageAttributeString, at: at)
                }
            }catch{
                Dlog(error.localizedDescription)
            }
            
        }
    }
    
    //MARK: - AudioRecordViewDelegate
    func audioRecordViewStateChanged(state: RecordState,audioRecord:AudioRecord) {
        if state == .Save {
            //以链接的形式添加
            addMultimediaToTextView(multimedia: audioRecord)
        }
    }
    
    //MARK: - UIImagePickerViewControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imageVC.dismiss(animated: true, completion: {
            
        })
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pimg = info[UIImagePickerControllerOriginalImage] as? UIImage{
            addMultimediaToTextView(multimedia: pimg)
        }
        imageVC.dismiss(animated: true, completion: {
            
        })
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if let keys = editingInfo?.keys {
            print(keys)
            for item in keys{
                print(editingInfo![item]!)
            }
        }
        imageVC.dismiss(animated: true, completion: {
            self.addMultimediaToTextView(multimedia:image)
        })
    }

    //MARK: -segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moodToLocation" {
            let vc = segue.destination as! LocationViewController
            vc.placeSelected = {
                pls in
                self.place = pls
            }
        }
    }
    
}
