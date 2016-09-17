//
//  FileManager.swift
//  Imagination
//
//  Created by Star on 15/11/22.
//  Copyright © 2015年 Star. All rights reserved.
//

import Foundation

class FileManager: Foundation.FileManager {
    
 
    class func pathOfNameInCaches(_ name:String)->String{
        let documetPaths = NSSearchPathForDirectoriesInDomains(Foundation.FileManager.SearchPathDirectory.cachesDirectory,Foundation.FileManager.SearchPathDomainMask.userDomainMask, true)
        let path = documetPaths[0] as String
        return path + ("/"+name)
    }
    class func TxtFileInCaches(_ name:String) -> String {
        let file = FileManager.pathOfNameInCaches(name)
        return file + ".txt"
    }
    
    
    class func pathOfNameInDocuments(_ name:String)->String{
        let documetPaths = NSSearchPathForDirectoriesInDomains(Foundation.FileManager.SearchPathDirectory.documentDirectory,Foundation.FileManager.SearchPathDomainMask.userDomainMask, true)
        let path = documetPaths[0] as String
        return path + ("/"+name)
    }
    
    class func TxtFileInDocuments(_ name:String) -> String {
        let file = FileManager.pathOfNameInDocuments(name)
        return file + ".txt"
    }
}
