//
//  DataCache.swift
//  Imagination
//
//  Created by Star on 15/11/14.
//  Copyright © 2015年 Star. All rights reserved.
//
/*
文件结构：
目录存一个文件 ： 快速的知道哪天有记录  catalogue
每天存一个文件 ： 快速查到当天内容
*/

import Foundation
class DataCache: NSObject {
    /***
     变量定义有歧义 这里的last 更多的用来作为“当前显示”使用 尤其是lastday lastDayname
     ***/
    
    static let shareInstance = DataCache()
    let FILENAME_INDEX = "index"
    var lastDayName:String?
    var catalogue:[String]?
    //[2015.11.20,2015.11.30,2015.12.2]
    var lastYear:Dictionary<String,Dictionary<String,String>>?
    //{[2015.11.20:{[9.30:sxx],[9.52]:dff]}],[2015.11.30:{[8.50:fdfd],[12.50:erre]}]}
    var lastDay:Dictionary<String,String>?
    
    func updateCatalogue() {
        if let cata = catalogue {
            if (cata.indexOf(lastDayName!) == nil) {
                catalogue?.append(lastDayName!)
                storeCatalogue()
            }
        } else {
            catalogue = Array.init(arrayLiteral: lastDayName!)
            storeCatalogue()
        }
    }
    
    func updateLastday(lastdayValue:String,key:String) {
        lastDay?.updateValue(lastdayValue, forKey: key)
        let myData = NSKeyedArchiver.archivedDataWithRootObject(lastDay!)
        myData.writeToFile(FileManager.pathOfName(lastDayName!), atomically: true)
        updateCatalogue()
    }
    
    func initLastday(lastdayDic:Dictionary<String,String>,lastdayName:String) {
        lastDayName = lastdayName
        lastDay = lastdayDic
        let myData = NSKeyedArchiver.archivedDataWithRootObject(lastDay!)
        myData.writeToFile(FileManager.pathOfName(lastDayName!), atomically: true)
        updateCatalogue()
    }
    
    

    func loadLastDay(){
        loadCatalogue()
        if let DAYS = catalogue {
            if lastDayName == nil {
                lastDayName = DAYS[DAYS.count-1]//lastDay
            }
            loadDay(lastDayName!)
        }
    }
    func loadLastDayToDay(dd:String) {
        lastDayName = dd
        loadDay(lastDayName!)
    }
    func loadDay(dd:String) {
        if let mydata = NSData.init(contentsOfFile: FileManager.pathOfName(dd)) {
            lastDay = (NSKeyedUnarchiver.unarchiveObjectWithData(mydata) as? Dictionary)
        }
    }
    
    func storeCatalogue(){
        if catalogue != nil {
            let myData = NSKeyedArchiver.archivedDataWithRootObject(catalogue!)
            myData.writeToFile(FileManager.pathOfName(FILENAME_INDEX), atomically: true)
            print(catalogue)
        }
    }
    func loadCatalogue(){
        if let mydata = NSData.init(contentsOfFile: FileManager.pathOfName(FILENAME_INDEX)) {
            catalogue = (NSKeyedUnarchiver.unarchiveObjectWithData(mydata) as? Array)
            print(catalogue)
        }
    }
    
    //删除方法保留 非特殊情况不适用
    func deleteTest() {
        for ddd in catalogue! {
            if ddd < "2015-12-05" {
                if deleteDay(ddd) {
                    catalogue?.removeAtIndex((catalogue?.indexOf(ddd))!)
                    storeCatalogue()
                }
            }
        }
    }
    func deleteDay(dd:String) -> Bool{
        print("deleteday\(dd)")
        let filePath = FileManager.pathOfName(dd)
        let mng = FileManager.defaultManager()
        if mng.fileExistsAtPath(filePath) {
            do {
                try mng.removeItemAtPath(filePath)
                return true
            } catch {
                print("删除文件错误:\(filePath)")
                return false
            }
        }
        return false
    }
    
        
}
