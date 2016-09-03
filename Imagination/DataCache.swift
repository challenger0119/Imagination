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
class DataCache: NSObject {
    
    static let shareInstance = DataCache()

    class Calculation {
        static let FILEPATH = "caculate"
        var calculateRecord:[String]?{//[2016-3-17:300:This month,2016-3-18:-100:Next month]
            didSet{
                //store to file
                let mydata = NSKeyedArchiver.archivedDataWithRootObject(self.calculateRecord!)
                mydata.writeToFile(FileManager.pathOfNameInDocuments(Calculation.FILEPATH), atomically: true)
            }
        }
        
        func storeCalculateRecord(record:String){
            if self.calculateRecord == nil{
                self.calculateRecord = [record]
            }else{
                self.calculateRecord?.append(record)
            }
        }
        
        func loadCalculateRecord(){
            if let data = NSKeyedUnarchiver.unarchiveObjectWithFile(FileManager.pathOfNameInDocuments(Calculation.FILEPATH)) {
                self.calculateRecord = data as? [String]
            }
        }
        
        
        func exportCalulateRecordToTableFile(){
            /*
            create table
            2016-4-5    300 nihao        //2 space at end
            2016-6-7                200 nihao   //2 space at beginning
            
            */
            if self.calculateRecord != nil {
                var result = ""
                for rec in self.calculateRecord! {
                    let recArray = rec.componentsSeparatedByString(":")
                    var str = recArray[0]
                    let intNum = Int(recArray[1])
                    if intNum > 0{
                        str += "    \(intNum)"
                        str += "    \(recArray[2])       \n"
                    }else{
                        str += "            \(intNum)"//2 tab
                        str += "    \(recArray[2])\n"
                    }
                    result += str
                }
                print(result)
                let data = result.dataUsingEncoding(NSUTF8StringEncoding)
                data?.writeToFile(FileManager.TxtFileInDocuments(Calculation.FILEPATH), atomically: true)
                
            }
        }
    }
        
    private let FILENAME_INDEX = "index"
    var isStart = true //启动标记 用于touchID
    let EMPTY_STRING = " "
    var fileState:(filename:String,lastDate:String)?
  
    var currentDayName:String?
    var currentMonthName:String?
    var catalogue:[String]?
    var catalogue_month:[String]?
    var email:String?{
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "email")
        }
        get{
            return NSUserDefaults.standardUserDefaults().objectForKey("email") as? String
        }
    }
    //[2015.11.20,2015.11.30,2015.12.2]
    var lastYear:Dictionary<String,Dictionary<String,String>>?
    //{[2015.11.20:{[9.30:sxx],[9.52]:dff]}],[2015.11.30:{[8.50:fdfd],[12.50:erre]}]}
    var lastDay:Dictionary<String,String>?
    var lastMonth:Dictionary<String,Dictionary<String,String>>?
    
    private func updateCatalogue() {
        if let cata = catalogue {
            if (cata.indexOf(currentDayName!) == nil) {
                catalogue?.append(currentDayName!)
                storeCatalogue()
            }
        } else {
            catalogue = Array.init(arrayLiteral: currentDayName!)
            storeCatalogue()
        }
    }
    
    func newStringContent(content:String, moodState:Int,GPSPlace:CLPlacemark){
        if Time.today() == self.currentDayName {
            self.updateLastday(Item.ItemString(content, mood: moodState,GPSName: GPSPlace.name!,latitude:GPSPlace.location!.coordinate.latitude,longtitude:GPSPlace.location!.coordinate.longitude), key: Time.clock())
        } else {
            self.initLastday([Time.clock():Item.ItemString(content, mood: moodState,GPSName: GPSPlace.name!,latitude:GPSPlace.location!.coordinate.latitude,longtitude:GPSPlace.location!.coordinate.longitude)], currentDayName: Time.today())
        }
    }
    
    func newStringContent(content:String, moodState:Int) {
        if Time.today() == self.currentDayName {
            self.updateLastday(Item.ItemString(content, mood: moodState), key: Time.clock())
        } else {
            self.initLastday([Time.clock():Item.ItemString(content, mood: moodState)], currentDayName: Time.today())
        }
    }
    //数据更新的两个方法
    func updateLastday(lastdayValue:String,key:String) {
        lastDay?.updateValue(lastdayValue, forKey: key)
        let myData = NSKeyedArchiver.archivedDataWithRootObject(lastDay!)
        myData.writeToFile(FileManager.pathOfNameInDocuments(currentDayName!), atomically: true)
        updateCatalogue()
    }
    
    func initLastday(lastdayDic:Dictionary<String,String>,currentDayName:String) {
        self.currentDayName = currentDayName
        lastDay = lastdayDic
        let myData = NSKeyedArchiver.archivedDataWithRootObject(lastDay!)
        myData.writeToFile(FileManager.pathOfNameInDocuments(self.currentDayName!), atomically: true)
        updateCatalogue()
    }
    
    //初始化显示数据
    func loadLastDay(){
        loadCatalogue()
        if let DAYS = catalogue {
            if currentDayName == nil {
                currentDayName = DAYS[DAYS.count-1]//lastDay
            }
            lastDay = loadDay(currentDayName!)
        }
    }
    
    func loadLastMonth(){
        loadCatalogue_month()
        if let Months = catalogue_month {
            if currentMonthName == nil {
                currentMonthName = Months[Months.count-1]//lastMonth
            }
            lastMonth = loadMonth(currentMonthName!)
        }
        self.loadLastDay()
    }
    
    //载入特定时间
    func loadLastDayToDay(dd:String) {
        currentDayName = dd
        lastDay = loadDay(currentDayName!)
    }
    func loadLastMonthToMonth(mm:String) {
        currentMonthName = mm
        lastMonth = loadMonth(currentMonthName!)
    }
    private func loadDay(dd:String) -> Dictionary<String,String>? {
        if let mydata = NSData.init(contentsOfFile: FileManager.pathOfNameInDocuments(dd)) {
            return (NSKeyedUnarchiver.unarchiveObjectWithData(mydata) as? Dictionary)!
        }
        return nil
    }
    private func loadMonth(mm:String) -> Dictionary<String,Dictionary<String,String>>? {
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
    
    private func isThisMonth(thismonth:String,dd:String) -> Bool {
        let arr = dd.componentsSeparatedByString("-")
        if arr.count == 3 {
            return (arr[0]+"-"+arr[1]) == thismonth
        }else{
            return false
        }
    }
    //存储目录
    private func storeCatalogue(){
        if catalogue != nil {
            let myData = NSKeyedArchiver.archivedDataWithRootObject(catalogue!)
            myData.writeToFile(FileManager.pathOfNameInDocuments(FILENAME_INDEX), atomically: true)
        }
    }
    //载入目录
    private func loadCatalogue(){
        catalogue?.removeAll()
        if let mydata = NSData.init(contentsOfFile: FileManager.pathOfNameInDocuments(FILENAME_INDEX)) {
            catalogue = (NSKeyedUnarchiver.unarchiveObjectWithData(mydata) as? Array)
        }
    }
    
    private func loadCatalogue_month(){
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
    private func isSameMonth(mm:Int,arr:[Int]) -> Bool {
        //字典没有顺序所以记录之前有的月份 然后比较
        for ii in arr {
            if mm == ii {
                return true
            }
        }
        return false
    }
    private func cutDateToMonth(ss:String) -> String {
        let arr = ss.componentsSeparatedByString("-")
        if arr.count == 3 {
            return arr[0]+"-"+arr[1]
        }else{
            return ss
        }
    }
    private func monthOfCatalogue(cata:String) -> Int {
        let arr = cata.componentsSeparatedByString("-")
        if arr.count == 3 {
            return Int(arr[1])!
        }else{
            return 0 //解析错误
        }
        
    }
    //创建文件
    private func createBackupFileWithAddtionalInfo(from:String,to:String) -> String {
        return createFileAtPath(from, to: to, fileGetter: {
            f,t in
            return FileManager.TxtFileInDocuments("\(f)_\(t)")
        })
    }
    
    private func createFileAtPath(from:String,to:String,fileGetter:(from:String,to:String)->String)->String{
        let txtfile = fileGetter(from:from,to: to)
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
                        let item = Item(contentString:  ddtmp[kk]!)
                        let content = item.content + "\n" + "心情:\(item.moodString) 位置:\(item.place.name),GPS(latitude:\(item.place.latitude),longtitude:\(item.place.longtitude))\n"
                        data.appendData((content.dataUsingEncoding(NSUTF8StringEncoding))!)
                    }
                }
                let over = "\n\n"
                data.appendData((over.dataUsingEncoding(NSUTF8StringEncoding))!)
            }
        }
        data.writeToFile(txtfile, atomically: true)
        return txtfile
    }
    //导出
    //导出和备份不在同一逻辑下 所以不在一个目录放
    func createExportDataFile(from:String,to:String) ->String {
        //删除原有的 导出文件只需要一份
        let mng = FileManager.defaultManager()
        do {
            let files = try mng.contentsOfDirectoryAtPath(FileManager.pathOfNameInCaches(""))
            if !files.isEmpty {
                for ff in files {
                    let ffarray = ff.componentsSeparatedByString(".")
                    if ffarray.count == 2 {
                        do{
                            try mng.removeItemAtPath(FileManager.TxtFileInCaches(ffarray[0]))
                        } catch {
                            
                        }
                    }
                }
            }
        } catch {
            
        }
        return createFileAtPath(from, to: to, fileGetter: {
            f,t in
            return FileManager.TxtFileInCaches("\(f)_\(t)")
        })
    }

    //备份
    //备份只有一个txt 要么是上次全部备份留下的 要么就是上次最近备份留下的 程序只关心这个备份截止日期
    func backupAll() -> String{
        checkFileExist()
        if fileState!.lastDate != EMPTY_STRING {
            deleteDay(fileState!.filename)
        }
        if let cc = catalogue {
            let start = cc[0]
            let end = cc[cc.count-1]
            return createBackupFileWithAddtionalInfo(start, to: end)
        }
        return EMPTY_STRING
    }
    
    func backupToNow() ->String {
        checkFileExist()
        if fileState!.lastDate != EMPTY_STRING {
            //如果之前有备份 就从之前备份到今天
            deleteDay(fileState!.filename)
            return createBackupFileWithAddtionalInfo(fileState!.lastDate, to: Time.today())
        } else {
            //如果之前没有备份 就全部备份
            if let cc = catalogue {
                let start = cc[0]
                let end = cc[cc.count-1]
               return createBackupFileWithAddtionalInfo(start, to: end)
            }
        }
        return EMPTY_STRING
    }
    func checkFileExist() {
        let mng = FileManager.defaultManager()
        var lastTimeEnd = EMPTY_STRING
        var lastBackup = EMPTY_STRING
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
