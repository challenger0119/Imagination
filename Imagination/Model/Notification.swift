//
//  Notifacation.swift
//  Imagination
//
//  Created by Star on 16/1/8.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit
import UserNotifications

/*
这里的notification 只适应于只有一个noti的情况（因为cancelAllNoti等操作） 这样写简化运算 对于这个软件没必要复杂 目前只需要一个
*/
class Notification {
    static let notiKey = "noti"
    static let notiValue = "imagination"
    static let notiBody = "今天心情如何？记录了吗？"
    static let notiAction = "记"
    static let keyForFiredate = "firedate"
    static let keyForReminder = "noti_everyday"
    static let keyForNewMoodAdded = "newMoodAdded"
    
    static var fireDate:Date?{
        get{
            if let nn = UserDefaults.standard.object(forKey: Notification.keyForFiredate) as? Date {
                return nn
            } else {
                return nil
            }
        }
        set{
            UserDefaults.standard.set(newValue, forKey: Notification.keyForFiredate)
        }
    }
    
    static var isReminder:Bool{
        get{
            if let nn = UserDefaults.standard.object(forKey: Notification.keyForReminder) as? NSNumber {
                return nn.boolValue
            } else {
                return false
            }
        }
        set{
            UserDefaults.standard.set(newValue, forKey: Notification.keyForReminder)
        }
    }
    
    static func createNotificaion(_ fireDate:Date?, identifier:String = "") {
        if let fire = fireDate {
            Notification.isReminder = true
            
            let notiContent = UNMutableNotificationContent()
            notiContent.sound = .default
            notiContent.badge = NSNumber(integerLiteral: 1)
            notiContent.body = Notification.notiBody
            notiContent.title = Notification.notiAction
            notiContent.userInfo = [Notification.notiKey:Notification.notiValue]
            
            let timeComponents = Calendar.current.dateComponents([.hour,.minute,.second], from: fire)
            let notiTrigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: true)
            let notiRequest = UNNotificationRequest(identifier: identifier, content: notiContent, trigger: notiTrigger)
            UNUserNotificationCenter.current().add(notiRequest) { (error) in
                if error != nil  {
                    Dlog(error?.localizedDescription)
                }
            }
            Notification.fireDate = fire
        }
    }
    
    //逻辑：1，有通知（才有执行必要）；2，存储了firedate（必须有，容错）；4，firedate day<= today(未调整，一天中启动十次软件 未调整只会出现一次不通过)；3，firedate clock > clock（需要调整，一天中启动十次软件 需调整可能9次不通过，所以这个判断放在前面）5，调整（找到对应noti 调整 其实这里 可以不要info）
    
    static func testToRescheduleNotificationToNextDay() {
        if Notification.isReminder {
            if let dd = Notification.fireDate {
                if Time.clockOfDate(dd) > Time.clock() && Time.dayOfDate(dd) <= Time.today(){
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    if let next = Time.dateFromString(Time.today() + " " + Time.clockOfDate(dd)) {
                        Notification.createNotificaion(Date(timeInterval: 24*60*60, since: next))
                    }
                }
            }
        }
    }
    
    static func cancelAllNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            if requests.count > 0 {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            }
        }
    }
}
