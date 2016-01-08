//
//  Notifacation.swift
//  Imagination
//
//  Created by Star on 16/1/8.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit

class Notification: NSObject {
    static let notiKey = "noti"
    static let notiValue = "imagination"
    static let notiBody = "今天心情如何？记录了吗？"
    static let notiAction = "记"
    
    
    static var isReminder:Bool{
        get{
            if let nn = NSUserDefaults.standardUserDefaults().objectForKey("noti_everyday") as? NSNumber {
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
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "noti_everyday")
        }
    }
    
    static func createNotificaion(fire:NSDate) {
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
    }
}
