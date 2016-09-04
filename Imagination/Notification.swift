//
//  Notifacation.swift
//  Imagination
//
//  Created by Star on 16/1/8.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit
/*
这里的notification 只适应于只有一个noti的情况（因为cancelAllNoti等操作） 这样写简化运算 对于这个软件没必要复杂 目前只需要一个
*/
class Notification: NSObject {
    static let notiKey = "noti"
    static let notiValue = "imagination"
    static let notiBody = "今天心情如何？记录了吗？"
    static let notiAction = "记"
    static let keyForFiredate = "firedate"
    static let keyForReminder = "noti_everyday"
    static let keyForNewMoodAdded = "newMoodAdded"
    
    static var fireDate:NSDate?{
        get{
            if let nn = NSUserDefaults.standardUserDefaults().objectForKey(Notification.keyForFiredate) as? NSDate {
                return nn
            } else {
                return nil
            }
        }
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Notification.keyForFiredate)
        }
    }
    
    static var isReminder:Bool{
        get{
            if let nn = NSUserDefaults.standardUserDefaults().objectForKey(Notification.keyForReminder) as? NSNumber {
                if nn.boolValue {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }
        set{
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: Notification.keyForReminder)
        }
    }
    
    static func createNotificaion(fire:NSDate?) {
        Notification.isReminder = true
        let noti = UILocalNotification.init()
        noti.fireDate = fire
        noti.repeatInterval = NSCalendarUnit.Day
        noti.timeZone = NSTimeZone.systemTimeZone()
        noti.soundName = UILocalNotificationDefaultSoundName
        noti.alertBody = Notification.notiBody
        noti.alertAction = Notification.notiAction
        noti.hasAction = true
        noti.applicationIconBadgeNumber = 1
        let info = [Notification.notiKey:Notification.notiValue]
        noti.userInfo = info
        UIApplication.sharedApplication().scheduleLocalNotification(noti)
        Notification.fireDate = fire
    }
    
    //逻辑：1，有通知（才有执行必要）；2，存储了firedate（必须有，容错）；4，firedate day<= today(未调整，一天中启动十次软件 未调整只会出现一次不通过)；3，firedate clock > clock（需要调整，一天中启动十次软件 需调整可能9次不通过，所以这个判断放在前面）5，调整（找到对应noti 调整 其实这里 可以不要info）
    
    static func testToRescheduleNotificationToNextDay() {
        if Notification.isReminder {
            if let dd = Notification.fireDate {
                if Time.clockOfDate(dd) > Time.clock() && Time.dayOfDate(dd) <= Time.today(){
                    UIApplication.sharedApplication().cancelAllLocalNotifications()
                    if let next = Time.dateFromString(Time.today()+" "+Time.clockOfDate(dd)) {
                        Notification.createNotificaion(NSDate.init(timeInterval: 24*60*60, sinceDate: next))
                    }
                }
            }
        }
    }
    
    static func cancelAllNotifications() {
        if let notis = UIApplication.sharedApplication().scheduledLocalNotifications {
            Dlog(notis)
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
    }
}
