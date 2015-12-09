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
    private let FILENAME_INDEX = "index"
    var fileState:(filename:String,lastDate:String)?
    var lastDayName:String?
    var catalogue:[String]?
    //[2015.11.20,2015.11.30,2015.12.2]
    var lastYear:Dictionary<String,Dictionary<String,String>>?
    //{[2015.11.20:{[9.30:sxx],[9.52]:dff]}],[2015.11.30:{[8.50:fdfd],[12.50:erre]}]}
    var lastDay:Dictionary<String,String>?
    
    private func updateCatalogue() {
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
    
    //数据更新的两个方法
    func updateLastday(lastdayValue:String,key:String) {
        lastDay?.updateValue(lastdayValue, forKey: key)
        let myData = NSKeyedArchiver.archivedDataWithRootObject(lastDay!)
        myData.writeToFile(FileManager.pathOfNameInDocuments(lastDayName!), atomically: true)
        updateCatalogue()
    }
    
    func initLastday(lastdayDic:Dictionary<String,String>,lastdayName:String) {
        lastDayName = lastdayName
        lastDay = lastdayDic
        let myData = NSKeyedArchiver.archivedDataWithRootObject(lastDay!)
        myData.writeToFile(FileManager.pathOfNameInDocuments(lastDayName!), atomically: true)
        updateCatalogue()
    }
    
    
    //初始化显示数据
    func loadLastDay(){
        loadCatalogue()
        if let DAYS = catalogue {
            if lastDayName == nil {
                lastDayName = DAYS[DAYS.count-1]//lastDay
            }
            lastDay = loadDay(lastDayName!)
        }
    }
    
    //载入特定时间
    func loadLastDayToDay(dd:String) {
        lastDayName = dd
        lastDay = loadDay(lastDayName!)
    }
    private func loadDay(dd:String) -> Dictionary<String,String>? {
        if let mydata = NSData.init(contentsOfFile: FileManager.pathOfNameInDocuments(dd)) {
            return (NSKeyedUnarchiver.unarchiveObjectWithData(mydata) as? Dictionary)!
        }
        return nil
    }
    
    //存储目录
    private func storeCatalogue(){
        if catalogue != nil {
            let myData = NSKeyedArchiver.archivedDataWithRootObject(catalogue!)
            myData.writeToFile(FileManager.pathOfNameInDocuments(FILENAME_INDEX), atomically: true)
            print(catalogue)
        }
    }
    //载入目录
    private func loadCatalogue(){
        if let mydata = NSData.init(contentsOfFile: FileManager.pathOfNameInDocuments(FILENAME_INDEX)) {
            catalogue = (NSKeyedUnarchiver.unarchiveObjectWithData(mydata) as? Array)
            print(catalogue)
        }
    }
    
    //创建文件
    private func createDataFile(from:String,to:String) {
        print("fileName:\(from)_\(to)")
        let txtfile = FileManager.TxtFileInDocuments("\(from)_\(to)")
        let data = NSMutableData()
        for dd in catalogue! {
            if dd >= from && dd <= to {
                if let ddtmp = loadDay(dd) {
                    let thisday = dd+"\n"
                    data.appendData(thisday.dataUsingEncoding(NSUTF8StringEncoding)!)
                    var keys = Array(ddtmp.keys)
                    keys.sortInPlace(){$0 < $1}
                    for kk in keys {
                        let title = kk+"\n"
                        data.appendData(title.dataUsingEncoding(NSUTF8StringEncoding)!)
                        let content = ddtmp[kk]!+"\n"
                        data.appendData((content.dataUsingEncoding(NSUTF8StringEncoding))!)
                    }
                }
                let over = "\n\n"
                data.appendData((over.dataUsingEncoding(NSUTF8StringEncoding))!)
            }
        }
        data.writeToFile(txtfile, atomically: true)
    }
    
    //备份
    //备份只有一个txt 要么是上次全部备份留下的 要么就是上次最近备份留下的 程序只关心这个备份截止日期
    func backupAll() {
        checkFileExist()
        if fileState!.lastDate != " " {
            deleteDay(fileState!.filename)
        }
        if let cc = catalogue {
            let start = cc[0]
            let end = cc[cc.count-1]
            createDataFile(start, to: end)
        }
    }
    
    func backupToNow() {
        checkFileExist()
        if fileState!.lastDate != " " {
            //如果之前有备份 就从之前备份到今天
            deleteDay(fileState!.filename)
            createDataFile(fileState!.lastDate, to: Time.today())
        } else {
            //如果之前没有备份 就全部备份
            if let cc = catalogue {
                let start = cc[0]
                let end = cc[cc.count-1]
                createDataFile(start, to: end)
            }
        }
    }
    
    func checkFileExist() {
        let mng = FileManager.defaultManager()
        var lastTimeEnd = " "
        var lastBackup = " "
        do {
            let files = try mng.contentsOfDirectoryAtPath(FileManager.pathOfNameInDocuments(""))
            if !files.isEmpty {
                for ff in files {
                    let ffarray = ff.componentsSeparatedByString(".")
                    if ffarray.count == 2 {
                        let filename = ffarray[0]
                        lastBackup = filename+".txt"
                        let fnarray = filename.componentsSeparatedByString("_")
                        lastTimeEnd = fnarray[1]
                        break
                    }
                }
            }
        } catch {
            
        }
        fileState = (lastBackup,lastTimeEnd)
    }
    
    //删除方法保留 非特殊情况不使用
    
    private func deleteTest() {
        for ddd in catalogue! {
            if ddd < "2015-12-05" {
                if deleteDay(ddd) {
                    catalogue?.removeAtIndex((catalogue?.indexOf(ddd))!)
                    storeCatalogue()
                }
            }
        }
    }
    private func deleteDay(dd:String) -> Bool{
        print("deleteday:\(dd)")
        let filePath = FileManager.pathOfNameInDocuments(dd)
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
    
    
    //修正目录错误的临时方法
    /*
    func changeFileToDocuments() {
        if let cc = catalogue {
            let mng = FileManager.defaultManager()
            let ccpath = FileManager.pathOfName(FILENAME_INDEX)
            if mng.fileExistsAtPath(ccpath) {
                do {
                    try mng.copyItemAtPath(ccpath, toPath: FileManager.pathOfNameInDocuments(FILENAME_INDEX))
                } catch {
                    print("删除copyItemAtPath错误:\(ccpath)")
                }
            }
            for dd in cc  {
                let filePath = FileManager.pathOfName(dd)
                if mng.fileExistsAtPath(filePath) {
                    do {
                        try mng.copyItemAtPath(filePath, toPath: FileManager.pathOfNameInDocuments(dd))
                    } catch {
                        print("删除copyItemAtPath错误:\(filePath)")
                    }
                }
            }
        }
    }
    
    func deleteFileInLib() {
        let mng = FileManager.defaultManager()
        if let cc = catalogue {
            
            let ccpath = FileManager.pathOfName(FILENAME_INDEX)
            if mng.fileExistsAtPath(ccpath) {
                do {
                    try mng.removeItemAtPath(ccpath)
                } catch {
                    print("删除错误:\(ccpath)")
                }
            }
            for dd in cc  {
                let filePath = FileManager.pathOfName(dd)
                if mng.fileExistsAtPath(filePath) {
                    do {
                        try mng.removeItemAtPath(filePath)
                    } catch {
                        print("删除错误:\(filePath)")
                    }
                }
            }
        }
        var p1 = FileManager.pathOfName("2015-12-4_2015-12-10.txt")
        if mng.fileExistsAtPath(p1) {
            do {
                try mng.removeItemAtPath(p1)
            } catch {
            }
        }
        p1 = FileManager.pathOfName("2015-12-04_2015-12-10.txt")
        if mng.fileExistsAtPath(p1) {
            do {
                try mng.removeItemAtPath(p1)
            } catch {
            }
        }
    }
    */
}
