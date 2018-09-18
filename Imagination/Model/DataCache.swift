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
import RealmSwift

class DataCache {
    
    static let shareInstance = DataCache()
    var realm:Realm!
    
    let newline = "\r\n"
    
    fileprivate let FILENAME_INDEX = "index"
    //var isStart = true //启动标记 用于touchID
    let EMPTY_STRING = " "
    
    var fileState:(filename:String,lastDate:String)? = nil
  
    var currentDayName:String = ""
    var _currentMonthName:String = ""
    var currentMonthName:String {
        get{
            if _currentMonthName == "" && self.catalogue_month.count > 0 {
               _currentMonthName = self.catalogue_month.first!
            }
            return _currentMonthName
        }
        set{
            _currentMonthName = newValue
        }
    }
    var catalogue:[String] = []
    var catalogue_month:[String] = []
    
    var email:String? {
        set{
            if email != nil {
                UserDefaults.standard.set(newValue, forKey: "email")
            }
        }
        get{
            return UserDefaults.standard.object(forKey: "email") as? String
        }
    }
    
    init() {
        do{
            self.realm = try Realm()
            self.loadCategory()
        }catch{
            debugPrint(error.localizedDescription)
        }
    }
    
    func storeItem(_ item:Item) {
        let date = Date()
        item.timestamp = date.timeIntervalSince1970
        do{
            try realm.write {
                realm.add(item)
            }
        }catch{
            debugPrint(error.localizedDescription)
        }
    }

    func loadLastMonth(result:((Results<Item>) -> Void)) {
        if self.catalogue.count > 0 {
            self.loadMonth(monthString: self.catalogue.first!) { (items) in
                result(items)
            }
        }
    }
    
    func loadMonth(monthString:String, result:((Results<Item>) -> Void)){
        self.currentMonthName = monthString
        result(self.realm.objects(Item.self).filter("monthString == '\(monthString)'"))
    }
    //初始化显示数据
    func loadDay(dayString:String, result:((Results<Item>) -> Void)){
        result(self.realm.objects(Item.self).filter("dayString == '\(dayString)'"))
    }
    
    func loadCategory(){
        self.catalogue_month.removeAll()
        self.catalogue.removeAll()
        
        var items = self.realm.objects(Item.self)
        items = items.sorted(byKeyPath: "timestamp", ascending: false)
        var tmpDayString = ""
        var tmpMonthString = ""
        items.forEach { (it) in
            if it.dayString != tmpDayString {
                catalogue.append(it.dayString)
                tmpDayString = it.dayString
            }
            if it.monthString != tmpMonthString {
                catalogue_month.append(it.monthString)
                tmpMonthString = it.monthString
            }
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
    
    // 将多媒体文件压缩为zip
    fileprivate func createFilesWithZipAttachments(from:String,to:String,pathGetter:(_ from:String,_ to:String)->String)->[String]{
        let result = self.createFiles(from, to: to, pathGetter: pathGetter)
        let txt = result.first!
        let attaches = result.suffix(from: 1)
        let zipFilepath = pathGetter(from,to)+".zip"
        SSZipArchive.createZipFile(atPath: zipFilepath, withFilesAtPaths: Array(attaches))
        return [txt,zipFilepath]
    }
    
    // 将制定时间节点的数据中的文字信息和多媒体类型信息生成一个文件 返回包含了该文件路径和里面包含的多媒体文件的路径的数组
    fileprivate func createFiles(_ from:String,to:String,pathGetter:(_ from:String,_ to:String)->String)->[String]{
       
        let txtfile = pathGetter(from,to) + ".txt"
        var filePaths = [txtfile]
        let data = NSMutableData()
        for dd in catalogue {
            if dd >= from && dd <= to {
                //按天解析
                loadDay(dayString: dd) { (items) in
                    let thisday = dd + newline
                    data.append(thisday.data(using: String.Encoding.utf8)!)
                    let sortedItems = items.sorted(byKeyPath: "timestamp", ascending: false)    // 按时间排序当天的数据
                    for item in sortedItems {
                        let title = Time.clockOfDate(Date(timeIntervalSince1970: item.timestamp)) + newline
                        data.append(title.data(using: String.Encoding.utf8)!)   // 记录日期
                        
                        var content = item.content + newline
                        if item.moodType != .None {
                            // 有记录心情 解析保存心情
                            content += "心情:\(item.moodType.rawValue) "
                        }
                        if let place = item.location {
                            content += "位置:\(place.name),GPS(latitude:\(place.latitude),longtitude:\(place.longtitude))"
                        }
                     
                        if item.moodType != .None || item.location != nil{
                            // 有数据就回车换行
                            content += newline
                        }
                        data.append((content.data(using: String.Encoding.utf8))!)   // 记录内容
                        
                        var multimedia = ""
                        if item.medias.count > 0 {
                            for value in item.medias {
                                filePaths.append(value.path)   // 加入多媒体文件路径
                                multimedia += (value.path as NSString).lastPathComponent+" "
                            }
                        }
                        multimedia += newline;
                        data.append((multimedia.data(using: String.Encoding.utf8))!)    // 记录多媒体文件名称
                    }
                }
                let over = newline+newline
                data.append((over.data(using: String.Encoding.utf8))!)
            }
        }
        data.write(toFile: txtfile, atomically: true) // 写入本地文件
        
        return filePaths
    }
    
    //MARK: - 导出
    
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
    
    //MARK: - 备份
    
    //备份只有一个 要么是上次全部备份留下的 要么就是上次最近备份留下的 程序只关心这个备份截止日期
    func backupAll() -> [String] {
        checkFileExist()
        if fileState!.lastDate != EMPTY_STRING {
            let _ = deleteDay(fileState!.filename)
        }
        if catalogue.count > 0 {
            let start = catalogue[0]
            let end = catalogue[catalogue.count-1]
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
            if catalogue.count > 0 {
                let start = catalogue[0]
                let end = catalogue[catalogue.count-1]
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
}
