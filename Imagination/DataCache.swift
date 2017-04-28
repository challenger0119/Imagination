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
import CoreLocation
import UIKit
import SSZipArchive

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class DataCache: NSObject {
    
    static let shareInstance = DataCache()

    let newline = "\r\n"
    
    fileprivate let FILENAME_INDEX = "index"
    //var isStart = true //启动标记 用于touchID
    let EMPTY_STRING = " "
    var fileState:(filename:String,lastDate:String)?
  
    var currentDayName:String?
    var currentMonthName:String?
    var catalogue:[String]?
    var catalogue_month:[String]?
    
    var email:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "email")
        }
        get{
            return UserDefaults.standard.object(forKey: "email") as? String
        }
    }
    //[2015.11.20,2015.11.30,2015.12.2]
    var lastYear:Dictionary<String,Dictionary<String,String>>?
    //{[2015.11.20:{[9.30:sxx],[9.52]:dff]}],[2015.11.30:{[8.50:fdfd],[12.50:erre]}]}
    var lastDay:Dictionary<String,String>?
    var lastMonth:Dictionary<String,Dictionary<String,String>>?
    
    fileprivate func updateCatalogue() {
        if let cata = catalogue {
            if (cata.index(of: currentDayName!) == nil) {
                catalogue?.append(currentDayName!)
                storeCatalogue()
            }
        } else {
            catalogue = Array.init(arrayLiteral: currentDayName!)
            storeCatalogue()
        }
    }
    
    //文字，心情，地理位置，多媒体
    func newString(Content content:String, moodState:Int,GPSPlace:(name:String,coor:CLLocationCoordinate2D)?,multiMedia:Dictionary<Int,MultiMediaFile>?){
        
        if let mm = multiMedia {
            if let gps = GPSPlace {
                if Time.today() == self.currentDayName {
                    //今天的新的记录
                    let clock = Time.clock()
                    self.updateLastday(Item.itemString(Content: content, mood: moodState,GPSName: gps.name,latitude:gps.coor.latitude,longtitude:gps.coor.longitude,multiMedia: mm), key: clock)
                } else {
                    //新的一天记录
                    let clock = Time.clock()
                    let today = Time.today()
                    self.initLastday([clock:Item.itemString(Content: content, mood: moodState,GPSName: gps.name,latitude:gps.coor.latitude,longtitude:gps.coor.longitude,multiMedia: mm)], currentDayName: today)
                }
            }else{
                self.newString(Content: content, moodState: moodState, multiMedia: multiMedia)
            }
        }else{
            self.newStringContent(content, moodState: moodState, GPSPlace: GPSPlace)
        }
    }
    //文字，心情，多媒体
    func newString(Content content:String, moodState:Int,multiMedia:Dictionary<Int,MultiMediaFile>?){
        if let mm = multiMedia {
            if Time.today() == self.currentDayName {
                let clock = Time.clock()
                self.updateLastday(Item.itemString(Content: content, mood: moodState,multiMedia: mm), key: clock)
                
            } else {
                let clock = Time.clock()
                let today = Time.today()
                self.initLastday([clock:Item.itemString(Content: content, mood: moodState,multiMedia: mm)], currentDayName: today)
                
            }
        }else{
            self.newStringContent(content, moodState: moodState)
        }
    }
    //文字，心情，地理位置
    func newStringContent(_ content:String, moodState:Int,GPSPlace:(name:String,coor:CLLocationCoordinate2D)?){
        if let gps = GPSPlace {
            if Time.today() == self.currentDayName {
                self.updateLastday(Item.itemString(content, mood: moodState,GPSName: gps.name,latitude:gps.coor.latitude,longtitude:gps.coor.longitude), key: Time.clock())
            } else {
                self.initLastday([Time.clock():Item.itemString(content, mood: moodState,GPSName: gps.name,latitude:gps.coor.latitude,longtitude:gps.coor.longitude)], currentDayName: Time.today())
            }
        }else{
            self.newStringContent(content, moodState: moodState)
        }
    }
    //文字，心情
    func newStringContent(_ content:String, moodState:Int) {
        if Time.today() == self.currentDayName {
            self.updateLastday(Item.itemString(content, mood: moodState), key: Time.clock())
        } else {
            self.initLastday([Time.clock():Item.itemString(content, mood: moodState)], currentDayName: Time.today())
        }
    }
    
    //数据更新的两个方法
    func updateLastday(_ lastdayValue:String,key:String) {
        let _ = lastDay?.updateValue(lastdayValue, forKey: key)
        let myData = NSKeyedArchiver.archivedData(withRootObject: lastDay!)
        try? myData.write(to: URL(fileURLWithPath: FileManager.pathOfNameInLib(currentDayName!)), options: [.atomic])
        updateCatalogue()
    }
    
    func initLastday(_ lastdayDic:Dictionary<String,String>,currentDayName:String) {
        self.currentDayName = currentDayName
        lastDay = lastdayDic
        let myData = NSKeyedArchiver.archivedData(withRootObject: lastDay!)
        try? myData.write(to: URL(fileURLWithPath: FileManager.pathOfNameInLib(self.currentDayName!)), options: [.atomic])
        updateCatalogue()
    }

    //初始化显示数据
    func loadLastDay(){
        loadCatalogue()
        if let DAYS = catalogue {
            currentDayName = DAYS[DAYS.count-1]//lastDay
            lastDay = loadDay(currentDayName!)
        }
    }
    
    func loadLastMonth(){
        loadCatalogue_month()
        if let Months = catalogue_month {
            currentMonthName = Months[Months.count-1]//lastMonth
            lastMonth = loadMonth(currentMonthName!)
        }
        loadLastDay()
    }
    
    //载入特定时间
    func loadLastDayToDay(_ dd:String) {
        currentDayName = dd
        lastDay = loadDay(currentDayName!)
    }
    func loadLastMonthToMonth(_ mm:String) {
        currentMonthName = mm
        lastMonth = loadMonth(currentMonthName!)
    }
    
    fileprivate func loadDay(_ dd:String) -> Dictionary<String,String>? {
        if let mydata = try? Data.init(contentsOf: URL(fileURLWithPath: FileManager.pathOfNameInLib(dd))) {
            return (NSKeyedUnarchiver.unarchiveObject(with: mydata) as? Dictionary)!
        }
        return nil
    }
    
    fileprivate func loadMonth(_ mm:String) -> Dictionary<String,Dictionary<String,String>>? {
        if let cts = catalogue {
            var lMonth = Dictionary<String,Dictionary<String,String>>()
            for ct in cts {
                if isThisMonth(mm, dd: ct) {
                    lMonth.updateValue((self.loadDay(ct)!), forKey: ct)
                }
            }
            return lMonth
        } else {
            return nil
        }
    }
    
    fileprivate func isThisMonth(_ thismonth:String,dd:String) -> Bool {
        let arr = dd.components(separatedBy: "-")
        if arr.count == 3 {
            return (arr[0]+"-"+arr[1]) == thismonth
        }else{
            return false
        }
    }
    //存储目录
    fileprivate func storeCatalogue(){
        if catalogue != nil {
            let myData = NSKeyedArchiver.archivedData(withRootObject: catalogue!)
            try? myData.write(to: URL(fileURLWithPath: FileManager.pathOfNameInLib(FILENAME_INDEX)), options: [.atomic])
        }
    }

    //载入目录
    fileprivate func loadCatalogue(){
        catalogue?.removeAll()
        if let mydata = try? Data.init(contentsOf: URL(fileURLWithPath: FileManager.pathOfNameInLib(FILENAME_INDEX))) {
            catalogue = (NSKeyedUnarchiver.unarchiveObject(with: mydata) as? Array)
        }
    }
    
    fileprivate func loadCatalogue_month(){
        self.loadCatalogue()
        catalogue_month?.removeAll()
        var montharray = [Int]()
        if let cts = catalogue {
            for ct in cts {
                if isSameMonth(monthOfCatalogue(ct), arr: montharray)  {
                    continue;
                } else {
                    if catalogue_month == nil {
                        catalogue_month = Array.init(arrayLiteral: self.cutDateToMonth(ct))
                    } else {
                        catalogue_month?.append(self.cutDateToMonth(ct))
                    }
                    montharray.append(monthOfCatalogue(ct))
                }
                
            }
        }
    }
    fileprivate func isSameMonth(_ mm:Int,arr:[Int]) -> Bool {
        //字典没有顺序所以记录之前有的月份 然后比较
        for ii in arr {
            if mm == ii {
                return true
            }
        }
        return false
    }
    fileprivate func cutDateToMonth(_ ss:String) -> String {
        let arr = ss.components(separatedBy: "-")
        if arr.count == 3 {
            return arr[0]+"-"+arr[1]
        }else{
            return ss
        }
    }
    fileprivate func monthOfCatalogue(_ cata:String) -> Int {
        let arr = cata.components(separatedBy: "-")
        if arr.count == 3 {
            return Int(arr[1])!
        }else{
            return 0 //解析错误
        }
    }
    //创建文件

    fileprivate func createBackupFileWithAddtionalInfo(_ from:String,to:String) -> [String] {
        return createFilesWithZipAttachments(from: from, to: to, pathGetter: {
            f,t in
            return FileManager.backupFilePath(withName: "\(f)_\(t)")
        })
    }
    
    fileprivate func createFilesWithZipAttachments(from:String,to:String,pathGetter:(_ from:String,_ to:String)->String)->[String]{
        let result = self.createFiles(from, to: to, pathGetter: pathGetter)
        let txt = result.first!
        let attaches = result.suffix(from: 1)
        let zipFilepath = pathGetter(from,to)+".zip"
        SSZipArchive.createZipFile(atPath: zipFilepath, withFilesAtPaths: Array(attaches))
        return [txt,zipFilepath]
    }
    
    fileprivate func createFiles(_ from:String,to:String,pathGetter:(_ from:String,_ to:String)->String)->[String]{
       
        let txtfile = pathGetter(from,to) + ".txt"
        var filePaths = [txtfile]
        let data = NSMutableData()
        for dd in catalogue! {
            if dd >= from && dd <= to {
                //按天解析
                if let ddtmp = loadDay(dd) {
                    let thisday = dd + newline
                    data.append(thisday.data(using: String.Encoding.utf8)!)
                    var keys = Array(ddtmp.keys)
                    keys.sort(){$0 < $1}
                    for kk in keys {
                        //一天中不同时刻解析
                        let title = kk+newline
                        data.append(title.data(using: String.Encoding.utf8)!)
                        let item = Item(contentString:  ddtmp[kk]!)
                        var content = item.content + newline
                        if item.mood != 0 {
                            content += "心情:\(item.moodString) "
                        }
                        if item.place.latitude != 0 {
                            content += "位置:\(item.place.name),GPS(latitude:\(item.place.latitude),longtitude:\(item.place.longtitude))"
                        }
                        if item.mood != 0 || item.place.latitude != 0 {
                            content += newline
                        }
                        data.append((content.data(using: String.Encoding.utf8))!)
                        var multimedia = ""
                        if let mm = item.multiMedias {
                            for value in mm.values {
                                filePaths.append(value.storePath)
                                multimedia += (value.storePath as NSString).lastPathComponent+" "
                            }
                        }
                        multimedia += newline;
                        data.append((multimedia.data(using: String.Encoding.utf8))!)
                    }
                }
                let over = newline+newline
                data.append((over.data(using: String.Encoding.utf8))!)
            }
        }
        data.write(toFile: txtfile, atomically: true)
        
        return filePaths
    }
    //导出
    //导出和备份不在同一逻辑下 所以不在一个目录放
    func createExportDataFile(_ from:String,to:String) ->[String] {
        //删除原有的 导出文件只需要一份
        let mng = FileManager.default
        do {
            let files = try mng.contentsOfDirectory(atPath: FileManager.exportFilePath())
            if !files.isEmpty {
                for ff in files {
                    let ffarray = ff.components(separatedBy: ".")
                    if ffarray.count == 2 {
                        do{
                            try mng.removeItem(atPath: FileManager.exportFilePath(withName: ffarray[0]))
                        } catch {
                            
                        }
                    }
                }
            }
        } catch {
            
        }
        return createFilesWithZipAttachments(from: from, to: to, pathGetter: {
            f,t in
            return FileManager.exportFilePath(withName: "\(f)_\(t)")
        })
    }
    //备份
    //备份只有一个 要么是上次全部备份留下的 要么就是上次最近备份留下的 程序只关心这个备份截止日期
    func backupAll() -> [String] {
        checkFileExist()
        if fileState!.lastDate != EMPTY_STRING {
            let _ = deleteDay(fileState!.filename)
        }
        if let cc = catalogue {
            let start = cc[0]
            let end = cc[cc.count-1]
            return createBackupFileWithAddtionalInfo(start, to: end)
        }
        return []
    }
    
    func backupToNow() ->[String] {
        checkFileExist()
        if fileState!.lastDate != EMPTY_STRING {
            //如果之前有备份 就从之前备份到今天
            let _ = deleteDay(fileState!.filename)
            return createBackupFileWithAddtionalInfo(fileState!.lastDate, to: Time.today())
        } else {
            //如果之前没有备份 就全部备份
            if let cc = catalogue {
                let start = cc[0]
                let end = cc[cc.count-1]
                return createBackupFileWithAddtionalInfo(start, to: end)
            }
        }
        return []
    }
    
    func checkFileExist() {
        let mng = FileManager.default
        var lastTimeEnd = EMPTY_STRING
        var lastBackup = EMPTY_STRING
        do {
            let files = try mng.contentsOfDirectory(atPath: FileManager.backupFilePath())
            if !files.isEmpty {
                for ff in files {
                    let ffarray = ff.components(separatedBy: ".")
                    if ffarray.count == 2 {
                        let filename = ffarray[0]
                        lastBackup = filename+".txt"
                        let fnarray = filename.components(separatedBy: "_")
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
    
    fileprivate func deleteDay(_ dd:String) -> Bool{
        Dlog("deleteday:\(dd)")
        let txt = FileManager.pathOfNameInLib(dd)
        let attach = dd.replacingOccurrences(of: "txt", with: "zip")
        let mng = FileManager.default
        if mng.fileExists(atPath: txt) {
            do {
                
                try mng.removeItem(atPath: txt)
                return true
            } catch {
                Dlog("删除文件错误:\(txt)")
                return false
            }
        }
        if mng.fileExists(atPath: attach) {
            do {
                
                try mng.removeItem(atPath: attach)
                return true
            } catch {
                Dlog("删除文件错误:\(attach)")
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
