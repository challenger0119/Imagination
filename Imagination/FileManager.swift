//
//  FileManager.swift
//  Imagination
//
//  Created by Star on 15/11/22.
//  Copyright © 2015年 Star. All rights reserved.
//

import Foundation
import UIKit

extension FileManager {
    //MARK: - Base
    class func documentsPath()->String{
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
    }
    
    class func cachesPath()->String{
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory,FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
    }
    
    class func pathOfNameInCaches(_ name:String)->String{
        let path = self.cachesPath()
        return path + ("/"+name)
    }
    class func TxtFileInCaches(_ name:String) -> String {
        let file = FileManager.pathOfNameInCaches(name)
        return file + ".txt"
    }
    
    
    class func pathOfNameInDocuments(_ name:String)->String{
        let path = self.documentsPath()
        return path + ("/"+name)
    }
    
    class func TxtFileInDocuments(_ name:String) -> String {
        let file = FileManager.pathOfNameInDocuments(name)
        return file + ".txt"
    }
}

extension FileManager{
    class func multiMediaFilePath() ->String {
        return self.documentsPath() + "/Multimedia"
    }
}

extension FileManager{
    //MARK: - Image
    fileprivate class func imageFilePath() -> String{
        return self.multiMediaFilePath() + "/Pictures"
    }
    class func imageFilePathWithName(_ name:String)->String{
        do{
            try FileManager.default.createDirectory(atPath: FileManager.imageFilePath(), withIntermediateDirectories: true, attributes: nil)
        }catch{
            Dlog(error.localizedDescription)
        }
        let tname = name.replacingOccurrences(of: ":", with: Item.oldSeparator)
        return self.imageFilePath() + "/\(tname)"
    }
    //全局设置
    static var compression:CGFloat{
        get{
            return 0.5
        }
    }
    static var isPng:Bool {
        get{
            return false
        }
    }
    class func imageName(name:String)->String{
        if FileManager.isPng {
            return name+".png"
        }else{
            return name+".jpg"
        }
    }
    
    //文件操作
    class func imageData(image:UIImage) -> Data? {
        if FileManager.isPng {
            return UIImagePNGRepresentation(image)
        }else{
            return UIImageJPEGRepresentation(image, FileManager.compression)
        }
    }
    fileprivate class func imageFilePathWithTimestamp() -> String{
        return self.imageFilePathWithName(FileManager.imageName(name: "image\(Time.timestamp())"))
    }
    class func createImageFile(withImage image:UIImage)->String{
        let path:String = FileManager.imageFilePathWithTimestamp()
        let data = FileManager.imageData(image: image)
        if FileManager.default.createFile(atPath: path, contents: data, attributes: nil) {
            return path
        }else{
            return ""
        }
    }
}
extension FileManager{
    //MARK: - Audio
    fileprivate class func audioFilePath()->String{
        return self.multiMediaFilePath() + "/Audios"
    }
    class func audioFilePathWithName(name:String)->String{
        do{
            try FileManager.default.createDirectory(atPath: FileManager.audioFilePath(), withIntermediateDirectories: true, attributes: nil)
        }catch{
            Dlog(error.localizedDescription)
        }
        return self.audioFilePath() + "/\(name)"
    }
    class func audioFilePathWithTimstamp()->String{
        return self.audioFilePathWithName(name: "audio\(Time.timestamp()).wav")
    }
    class func createAudioFile(withPath path:String)->String{
        let topath:String = FileManager.audioFilePathWithTimstamp()
        do{
            try FileManager.default.copyItem(atPath: path, toPath: topath)
            try FileManager.default.removeItem(atPath: path)
        }catch{
            Dlog(error.localizedDescription)
        }
        return topath
    }
}

extension FileManager{
    // video
    fileprivate class func videoFilePath() -> String{
        return self.multiMediaFilePath() + "/Videos"
    }
    class func videoFilePathWithName(name:String)->String{
        do{
            try FileManager.default.createDirectory(atPath: FileManager.videoFilePath(), withIntermediateDirectories: true, attributes: nil)
        }catch{
            Dlog(error.localizedDescription)
        }
        return self.videoFilePath() + "/\(name)"
    }
    fileprivate class func videoFilePathWithTimestamp()->String{
        return self.videoFilePathWithName(name: "video\(Time.timestamp()).mp4")
    }
    class func createVideoFile(withPath path:String)->String{
        let topath:String = FileManager.videoFilePathWithTimestamp()
        do{
            try FileManager.default.copyItem(atPath: path, toPath: topath)
        }catch{
            Dlog(error.localizedDescription)
        }
        return topath
    }
}

