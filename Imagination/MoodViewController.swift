//
//  MoodViewController.swift
//  Imagination
//
//  Created by Star on 16/1/2.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit
import CoreLocation
import MobileCoreServices
import AVFoundation
class MoodViewController: UIViewController,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AudioRecordViewDelegate {

    let dataCache = DataCache.shareInstance
    
    var keyBoardHeight:CGFloat = 216.0
    let keyboardDistance:CGFloat = 10
    var moodState = 0 {
        didSet{
            if moodState == 1 {
                self.noGoodBtn.backgroundColor = Item.defaultColor
                self.noGoodBtn.setTitleColor(UIColor.lightGray, for: UIControlState())
                self.goodBtn.backgroundColor = Item.coolColor
                self.goodBtn.setTitleColor(UIColor.white, for: UIControlState())
            }else if moodState == 2{
                self.noGoodBtn.backgroundColor = Item.justOkColor
                self.noGoodBtn.setTitleColor(UIColor.white, for: UIControlState())
                self.goodBtn.setTitleColor(UIColor.lightGray, for: UIControlState())
                self.goodBtn.backgroundColor = Item.defaultColor
            }else{
                self.noGoodBtn.backgroundColor = Item.defaultColor
                self.noGoodBtn.setTitleColor(UIColor.lightGray, for: UIControlState())
                self.goodBtn.backgroundColor = Item.defaultColor
                self.goodBtn.setTitleColor(UIColor.lightGray, for: UIControlState())
            }
        }
    }
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
    var multiMediaBufferDic:[Int:MultiMediaFile] = Dictionary()
    var multiMediaInsertBuffer:[NSTextAttachment:MultiMediaFile] = Dictionary()
    var font:UIFont!
    
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
        
        let backItem = UIBarButtonItem()
        backItem.title = "返回"
        self.navigationItem.backBarButtonItem = backItem
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(gesture:)))
        self.getLocBtn.addGestureRecognizer(longPress)
        
        self.font = self.content.font
    }
    
    
    @IBAction func noGoodBtnClicked() {
        if moodState == 2 {
            moodState = 0;
        }else{
            moodState = 2
        }
    }
    @IBAction func goodBtnClicked() {
        if moodState == 1 {
            moodState = 0;
        }else{
            moodState = 1
        }
    }
   
    @objc func longPressAction(gesture:UILongPressGestureRecognizer){
        if gesture.state == .began {
            removeLocation()
        }
    }
    func removeLocation(){
        self.place = nil
        self.getLocBtn.setTitle("获取地理位置", for: .normal)
    }
    @objc func closeKeyboard() {
        content.resignFirstResponder()
        self.bottomContraint.constant = self.keyboardDistance;
    }
    
    @objc func keyboardWillShow(_ notifi:Foundation.Notification){
        if let info = notifi.userInfo {
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
        if !(ttt!.isEmpty) {
            analysisTextStorage() //解析多媒体
            dataCache.newString(Content: ttt!, moodState: moodState, GPSPlace: self.place, multiMedia: self.multiMediaBufferDic.count == 0 ? nil:self.multiMediaBufferDic)

            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.keyForNewMoodAdded), object: nil)
            back()
        } else {
            if moodState != 0 {
                //自动填写
                switch moodState {
                case 1: content.text = "\"不言不语，毕竟言语无法表达我今天的快乐！！\""
                case 2: content.text = "\"可能，这就是平凡的一天。\""
                case 3: content.text = "\"生活不就是这样吗——开心与不开心交替出现。不是都说最有趣的路是曲曲折折的吗？加油!\""
                default: break
                }
                self.doneAction()
            }else{
                back()
            }
        }
    }
    @IBAction func didSwipDown(){
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
         self.content.textStorage.enumerateAttribute(NSAttributedStringKey.attachment, in: NSRange(location: 0,length: self.content.textStorage.length), options: NSAttributedString.EnumerationOptions(rawValue: 0), using:{
            (obj,range,pointor) in
            if let attache = obj as? NSTextAttachment {
                let mf = self.multiMediaInsertBuffer[attache]!  //提取最后保留的项目
                if mf.type == .image {
                    mf.storePath = FileManager.createImageFile(withImage: mf.obj as! UIImage)
                }else if mf.type == .voice {
                    mf.storePath = FileManager.createAudioFile(withPath: mf.storePath)
                }else if mf.type == .video {
                    mf.storePath = FileManager.createVideoFile(withPath: mf.storePath)
                }
                let _ = self.multiMediaBufferDic.updateValue(mf, forKey: range.location)
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
            self.imageVC.delegate = self
            self.imageVC.sourceType = .camera
            self.present(self.imageVC, animated: true, completion: {
                
            })
        }))
        queryVc.addAction(UIAlertAction(title: "相册", style: .default, handler: { (act) in
            self.imageVC = UIImagePickerController()
            self.imageVC.delegate = self
            self.imageVC.sourceType = .photoLibrary
            self.present(self.imageVC, animated: true, completion: {
                
            })
        }))
        queryVc.addAction(UIAlertAction(title: "取消", style: .destructive, handler: { (act) in
            queryVc.dismiss(animated: true, completion: nil)
        }))
        self.present(queryVc, animated: true, completion: nil)
        
    }
    @IBAction func getVideo(_ sender: UIButton) {
        closeKeyboard()
        let queryVc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        queryVc.addAction(UIAlertAction(title: "相机", style: .default, handler: { (act) in
            self.imageVC = UIImagePickerController()
            self.imageVC.sourceType = .camera
            self.imageVC.mediaTypes = [kUTTypeMovie as String]
            self.imageVC.videoQuality = .typeMedium
            self.imageVC.cameraCaptureMode = .video
            self.imageVC.delegate = self
            self.present(self.imageVC, animated: true, completion: {
                
            })
        }))
        queryVc.addAction(UIAlertAction(title: "取消", style: .destructive, handler: { (act) in
            queryVc.dismiss(animated: true, completion: nil)
        }))
        self.present(queryVc, animated: true, completion: nil)
    }
    
    func addMultimediaToTextView(multimedia:AnyObject) {
        let imageWidth = self.content.frame.width - 10;
        
        if multimedia.isKind(of: UIImage.self) {
            let image = multimedia as! UIImage
            let textAttach = NSTextAttachment(data:FileManager.imageData(image: image), ofType:MultiMediaType.image.rawValue)
            let imageHeight = image.size.height / image.size.width * imageWidth
            textAttach.image = MultiMediaFile.roundCornerImage(image, frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
            let imageAttributeString = NSAttributedString(attachment:textAttach)
            self.content.textStorage.insert(imageAttributeString, at: self.content.selectedRange.location)
            let mf = MultiMediaFile()
            mf.obj = image
            mf.type = .image
            self.multiMediaInsertBuffer.updateValue(mf, forKey:textAttach)
        }else if multimedia.isKind(of: AudioRecord.self) {
            let audio = multimedia as! AudioRecord
            do{
                let data = try Data.init(contentsOf: audio.recordFileURL)
                let textAttach = NSTextAttachment(data: data, ofType: MultiMediaType.voice.rawValue)
                let image = UIImage.init(named: "audio")!
                let imageHeight = image.size.height / image.size.width * imageWidth
                textAttach.image = MultiMediaFile.roundCornerImage(image, frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
                let imageAttributeString = NSAttributedString(attachment:textAttach)
                self.content.textStorage.insert(imageAttributeString, at: self.content.selectedRange.location)
                let mf = MultiMediaFile()
                mf.obj = audio
                mf.type = .voice
                mf.storePath = audio.recordFileURL.path
                self.multiMediaInsertBuffer.updateValue(mf, forKey:textAttach)
            }catch{
                Dlog(error.localizedDescription)
            }
        }else if multimedia.isKind(of: MultiMediaFile.self){
            let video = multimedia as! MultiMediaFile
            do{
                let url = URL.init(fileURLWithPath: video.storePath)
                let data = try Data.init(contentsOf: url)
                let textAttach = NSTextAttachment(data: data, ofType: MultiMediaType.video.rawValue)
                let image = MultiMediaFile.viedoShot(withURL: url)!
                Dlog("\(image.size.width) : \(image.size.height)")
                Dlog(image.imageOrientation)
                let imageHeight = image.size.height / image.size.width * imageWidth
                textAttach.image = MultiMediaFile.roundCornerImage(image, frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
                let imageAttributeString = NSAttributedString(attachment:textAttach)
                self.content.textStorage.insert(imageAttributeString, at: self.content.selectedRange.location)
                self.multiMediaInsertBuffer.updateValue(video, forKey:textAttach)
            }catch{
                Dlog(error.localizedDescription)
            }
        }
        self.content.font = font //插入媒体后字体会变，修正
    }
    
    //MARK: - AudioRecordViewDelegate
    func audioRecordViewStateChanged(state: RecordState,audioRecord:AudioRecord) {
        if state == .Save {
            addMultimediaToTextView(multimedia: audioRecord)
        }
    }
    
    //MARK: - UIImagePickerViewControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imageVC.dismiss(animated: true, completion: {
            
        })
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let type = info[UIImagePickerControllerMediaType] as? String {
            
            if type == kUTTypeImage as String {
                if let pimg = info[UIImagePickerControllerOriginalImage] as? UIImage{
                    addMultimediaToTextView(multimedia: pimg)
                }
            }else if type == kUTTypeMovie as String{
                if let url = info[UIImagePickerControllerMediaURL] as? URL {
                    let mf = MultiMediaFile()
                    mf.storePath = url.path
                    mf.type = .video
                    addMultimediaToTextView(multimedia: mf)
                }
            }else{
                Dlog("not excute image type:\(type)")
            }
        }
        imageVC.dismiss(animated: true, completion: {
            
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
