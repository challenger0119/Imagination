//
//  MultiMediaFile.swift
//  Imagination
//
//  Created by Star on 2017/4/26.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit
import AVFoundation
enum MultiMediaType:String {
    case image = "Image",voice = "Voice",video = "Video",def = "multi"
}
class MultiMediaFile: NSObject {
    var type:MultiMediaType = .def
    var storePath:String = "" {
        didSet{
            Dlog(storePath)
            name = (storePath as NSString).lastPathComponent
            Dlog(name)
        }
    }
    var name:String = ""
    var obj:AnyObject?
    
    func nameWithPosition(pos:Int)->String{
        return name + Item.multiMediaNameSeparator + String(pos)
    }
    //圆角图
    class func roundCornerImage(_ image:UIImage,frame:CGRect)->UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        UIBezierPath(roundedRect: frame, cornerRadius: 5).addClip()
        image.draw(in: frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    //视频截图
    class func viedoShot(withURL url:URL)->UIImage?{
        let avasset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator.init(asset: avasset)
        generator.appliesPreferredTrackTransform = true //竖屏视频需要
        var image:UIImage?
        do{
            var actualTIme:CMTime = CMTime()
            let cimage = try generator.copyCGImage(at: CMTimeMakeWithSeconds(0.5, 10), actualTime: &actualTIme)
            
            //CMTimeShow(actualTIme)
            image = UIImage.init(cgImage: cimage)
        }catch{
            Dlog(error.localizedDescription)
        }
        return image
    }
}
