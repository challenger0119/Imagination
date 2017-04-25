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
    //MARK: - Image
    fileprivate class func imageFile(withName name:String) -> UIImage? {
        let path = self.imagePathWithName(name)
        if let data =  UIImage.init(contentsOfFile: path) {
            return data
        }else{
            return nil
        }
    }
    fileprivate class func imageFilePath() -> String{
        return self.multiMediaFilePath() + "/Pictures"
    }
    fileprivate class func imagePathWithName(_ name:String)->String{
        let tname = name.replacingOccurrences(of: ":", with: Item.oldSeparator)
        return self.imageFilePath() + "/\(tname)"
    }
    
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
    private func createImageFileWithName(_ name:String,image:UIImage)->Bool{
        do{
            try self.createDirectory(atPath: FileManager.imageFilePath(), withIntermediateDirectories: true, attributes: nil)
        }catch{
            Dlog(error.localizedDescription)
        }
        
        var data:Data!
        let path:String = FileManager.imagePathWithName(name)
        data = FileManager.imageData(image: image)
        Dlog("image file at \(path)")
        return self.createFile(atPath: path, contents: data, attributes: nil)
    }
    
    private func deleteImageFileWithName(_ name:String)->Bool{
        do{
            try self.removeItem(atPath: FileManager.imagePathWithName(name))
            return true
        }catch{
            return false
        }
    }
    
    private class func allImageFilePaths()->[String]?{
        return FileManager.default.subpaths(atPath: self.documentsPath() + "/Pictures")
    }
}
extension FileManager{
    //MARK: - Audio
    fileprivate class func audioFilePath()->String{
        return self.multiMediaFilePath() + "/Audio"
    }
    class func audioFilePathWithName(name:String)->String{
        do{
            try FileManager.default.createDirectory(atPath: FileManager.audioFilePath(), withIntermediateDirectories: true, attributes: nil)
        }catch{
            Dlog(error.localizedDescription)
        }
        return self.audioFilePath() + "/\(name)"
    }
    class func audioFileDefaultPath()->String{
        return self.audioFilePathWithName(name: "default.wav")
    }
}

extension FileManager{
    //MARK: - DataCache
    class func imageData(image:UIImage) -> Data? {
        if FileManager.isPng {
            return UIImagePNGRepresentation(image)
        }else{
            return UIImageJPEGRepresentation(image, FileManager.compression)
        }
    }
    class func imageName(name:String)->String{
        if FileManager.isPng {
            return name+".png"
        }else{
            return name+".jpg"
        }
    }
    func create(Multimedia file:Any,name:String,type:Item.MutiMediaType) -> String{
        let filename = "\(type.rawValue)\(Item.multiMediaIndicator)\(name)"
        var path = ""
        var data:Data!
        switch type {
        case .image:
            do{
                try self.createDirectory(atPath: FileManager.imageFilePath(), withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("error createfile")
            }
            path = FileManager.imagePathWithName(filename)
            data = FileManager.imageData(image: file as! UIImage)
        default:
            do{
                try self.createDirectory(atPath: FileManager.multiMediaFilePath(), withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("error createfile")
            }
            path = FileManager.multiMediaFilePath(withName: filename)
            data = NSKeyedArchiver.archivedData(withRootObject: file)
        }
        if self.createFile(atPath: path, contents: data, attributes: nil) {
            return filename
        }else{
            return ""
        }
    }
    
    class func store(Multimedia mm:Dictionary<Int,AnyObject>,baseName:String)->[String]?{
        //考虑异步进行
        let fmng = FileManager.default
        let keys = Array(mm.keys)
        var names = [String]()
        for key in keys {
            if let obj = mm[key] {
                var name = "\(baseName)_\(key)"
                if obj.isKind(of: UIImage.self) {
                    name = fmng.create(Multimedia: obj,name:name, type: .image)
                }else{
                    let _ = fmng.createDefaultMultimediaFile(withName: name, object: obj)
                }
                names.append(name)
            }
        }
        if names.count == 0 {
            return nil
        }else{
            return names
        }
    }
    class func multimediaFileWith(Name nm:String) -> (name:String,type:Item.MutiMediaType,obj:AnyObject?) {
        let narray = nm.components(separatedBy: Item.multiMediaIndicator)
        
        switch narray[0] {
        case Item.MutiMediaType.image.rawValue:
            if let data = FileManager.imageFile(withName: nm) {
                return (nm,Item.MutiMediaType.image,data)
            }else{
                return (nm,Item.MutiMediaType.image,nil)
            }
        default:
            return (nm,Item.MutiMediaType.def,NSKeyedUnarchiver.unarchiveObject(withFile: FileManager.multiMediaFilePath(withName: nm)) as AnyObject?)
        }
    }
}

extension FileManager{
    //MARK: - Mutimedia file
    class func multiMediaFilePath() ->String {
        return self.documentsPath() + "/Multimedia"
    }
    
    class func multiMediaFilePath(withName name:String) -> String {
        let tname = name.replacingOccurrences(of: ":", with: Item.oldSeparator)
        let narray = tname.components(separatedBy: Item.multiMediaIndicator)
        var path = ""
        switch narray[0] {
        case Item.MutiMediaType.image.rawValue:
            path = self.imagePathWithName(tname)
        default:
            path = self.multiMediaFilePath() + "/\(tname)"
        }
        return path
    }
    
    class func multiMediaFile(withName name:String)->AnyObject{
        let path = self.multiMediaFilePath(withName: name)
        if let data = FileManager.default.contents(atPath: path) {
            return data as AnyObject;
        }else{
            return "" as AnyObject
        }
    }
    func createDefaultMultimediaFile(withName name:String,object:AnyObject) -> Bool{
        do{
            try self.createDirectory(atPath: FileManager.multiMediaFilePath(), withIntermediateDirectories: true, attributes: nil)
        }catch{
            print("error createfile")
        }
        let path = FileManager.multiMediaFilePath(withName: name)
        
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        Dlog("default multimedia file at \(path)")
        return self.createFile(atPath: path, contents: data, attributes: nil)
    }
    
    
}

