//
//  ContentShowViewController.swift
//  Imagination
//
//  Created by Star on 2017/4/27.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit
import CoreLocation
import AVKit
import AVFoundation
import RealmSwift

class ContentShowViewController: UIViewController {
    var multiMedias:Results<Media>
    var text:String = ""
    var pInfo:Location?
    var exitAnimation:(() -> Void)?
    fileprivate var mapView:UIView?
    
    init(withItem item:Item) {
        self.multiMedias = item.medias.sorted(byKeyPath: "position", ascending: true)
        self.text = item.content
        self.pInfo = item.location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func closeVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func showMap(){
        if  mapView == nil {
            mapView = IndicatorMapView(frame: CGRect(x: 20, y: self.view.frame.height-50-200, width: self.view.frame.width-40, height: 200),coor:CLLocationCoordinate2D(latitude: pInfo!.latitude, longitude: pInfo!.longtitude))
            self.view.addSubview(mapView!)
        }else{
            mapView!.isHidden = !mapView!.isHidden
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeVC)))
        
        let textView = UIScrollView(frame: CGRect(x: 20, y: 50, width: self.view.frame.width-40, height: self.view.frame.height-70))
        textView.layer.cornerRadius = 5.0
        self.view.addSubview(textView)
        
        if pInfo != nil && pInfo!.latitude != 0 {
            var tframe = textView.frame
            tframe.size.height = tframe.size.height - 30
            textView.frame = tframe
            let locBtn = UIButton(frame: CGRect(x: 20, y: self.view.frame.height-50, width: textView.frame.width, height: 30))
            self.view.addSubview(locBtn)
            locBtn.layer.cornerRadius = 5.0
            locBtn.setTitle(pInfo!.name, for: .normal)
            locBtn.titleLabel?.adjustsFontSizeToFitWidth = true
            locBtn.addTarget(self, action: #selector(showMap), for: .touchUpInside)
        }
        
        var usedHeight:CGFloat = 0
        if self.multiMedias.count > 0{
            let medias = self.multiMedias
            var keyIndex = 0
            var lastMuliIndex = -1
            let contentend = (self.text.count > medias.last!.position) ? (self.text.count):medias.last!.position
            for drawIndex in 0...contentend {
                if keyIndex < medias.count && drawIndex == medias[keyIndex].position {
                    
                    let mf = medias[keyIndex]
                    let imageWidth = textView.frame.width - 10;
                    if mf.mediaType == .image {
                        
                        if let image = UIImage(contentsOfFile: mf.storePath) {
                            let imageHeight = image.size.height / image.size.width * imageWidth
                            textView.addSubview(
                                buttonFactory(frame: CGRect(x:0,y:usedHeight,width:textView.frame.width,height:imageHeight),
                                              backgroundImage: Media.roundCornerImage(image, frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)), tag: keyIndex)
                            )
                            usedHeight += imageHeight
                        }
                    }else if mf.mediaType == .voice {
                        let btn = UIButton(type: .roundedRect)
                        btn.frame = CGRect(x:0,y:usedHeight,width:textView.frame.width,height:50)
                        btn.tag = keyIndex
                        let audio = AudioRecord(withFile:mf.storePath)
                        let timeString = Time.timeIntervalToMMssString(timeInterval: audio.playerDuration())
                        btn.setTitle("录音 \(timeString)", for: .normal)
                        btn.addTarget(self, action: #selector(btnClicked), for: .touchUpInside)
                        textView.addSubview(btn)
                        usedHeight += 50
                    }else if mf.mediaType == .video {
                        let url = URL.init(fileURLWithPath: mf.storePath)
                        let image = Media.viedoShot(withURL: url)!
                        let imageHeight = image.size.height / image.size.width * imageWidth
                        textView.addSubview(
                            buttonFactory(frame: CGRect(x:0,y:usedHeight,width:textView.frame.width,height:imageHeight),
                                          backgroundImage: Media.roundCornerImage(image, frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)), tag: keyIndex)
                        )
                        usedHeight += imageHeight
                    }
                    
                    lastMuliIndex = drawIndex
                    keyIndex += 1
                }else if drawIndex == lastMuliIndex + 1 {
                    let start = self.text.index(text.startIndex, offsetBy: lastMuliIndex + 1)
                    var offset = 0
                    if keyIndex < medias.count {
                        offset = medias[keyIndex].position
                    }else{
                        offset = contentend
                    }
                    let end = self.text.index(text.startIndex, offsetBy: offset)
                    let substring = String(self.text[start..<end])
                    let height = (substring as NSString).boundingRect(with: CGSize(width:textView.frame.width,height:textView.frame.height), options: [NSStringDrawingOptions.usesLineFragmentOrigin,.usesFontLeading], attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15)], context: nil).size.height
                    textView.addSubview(
                        labelFactory(frame: CGRect(x:0,y:usedHeight,width:textView.frame.width,height:height), content: substring)
                    )
                    usedHeight += height
                }
            }
        }else{
            let height = (self.text as NSString).boundingRect(with: CGSize(width:textView.frame.width,height:textView.frame.height), options: [NSStringDrawingOptions.usesLineFragmentOrigin,.usesFontLeading], attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15)], context: nil).size.height
            textView.addSubview(labelFactory(frame: CGRect(x:0,y:usedHeight,width:textView.frame.width,height:height), content: self.text))
        }
        textView.contentSize = CGSize(width: textView.frame.size.width, height: usedHeight)
    }
    
    func buttonFactory(frame:CGRect,backgroundImage:UIImage,tag:Int)->UIButton{
        let btn = UIButton(type: .roundedRect)
        btn.frame = frame
        btn.setBackgroundImage(backgroundImage, for: .normal)
        btn.tag = tag
        btn.addTarget(self, action: #selector(btnClicked), for: .touchUpInside)
        return btn
    }
    
    func labelFactory(frame:CGRect, content:String)->UILabel{
        let label = UILabel(frame: frame)
        label.text = content
        label.textColor = UIColor(white: 0.3, alpha: 1.0)
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
    }

    @objc func btnClicked(sender:UIButton){
        
        let mf = self.multiMedias[sender.tag]
        switch mf.mediaType {
        case .image:
            let vc = ImageViewController(withImage: UIImage(contentsOfFile: mf.storePath)!)
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.isTranslucent = false
            self.present(nav, animated: true, completion:nil)
            
        case .video:
            let playView = AVPlayerViewController()
            let playitem = AVPlayerItem(asset: AVAsset(url: URL.init(fileURLWithPath: mf.storePath)))
            let player = AVPlayer(playerItem: playitem)
            playView.player = player
            self.present(playView, animated: true, completion: nil)
        case .voice:
            let vc = AudioViewController(withFile: mf.storePath)
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.isTranslucent = false
            self.present(nav, animated: true, completion: nil)
        default:
            break
        }
    }
}
