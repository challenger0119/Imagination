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
    static let keyForHour = "fireTimeHour"
    static let keyForMinute = "fireTimeMinute"
    static let keyForReminder = "noti_everyday"
    static let keyForNewMoodAdded = "newMoodAdded"
    static let keyForHitokoto = "keyForHitokoto"
    
    static var fireTime: (hour: Int, minute: Int)?{
        get{
            if let hour = UserDefaults.standard.object(forKey: Notification.keyForHour) as? Int, let minute = UserDefaults.standard.object(forKey: Notification.keyForMinute) as? Int {
                return (hour, minute)
            } else {
                return nil
            }
        }
        set{
            guard let value = newValue else { return }
            UserDefaults.standard.set(value.hour, forKey: Notification.keyForHour)
            UserDefaults.standard.set(value.minute, forKey: Notification.keyForMinute)
        }
    }
    
    static var isReminder: Bool {
        get{
            if let nn = UserDefaults.standard.object(forKey: Notification.keyForReminder) as? Bool {
                return nn
            } else {
                return false
            }
        }
        set{
            UserDefaults.standard.set(newValue, forKey: Notification.keyForReminder)
        }
    }
    
    static func createNotificaion(at hour: Int, minute: Int, identifier:String = "notification") {
        Notification.isReminder = true

        let notiContent = UNMutableNotificationContent()
        notiContent.sound = .default
        notiContent.badge = NSNumber(integerLiteral: 1)
        notiContent.body = hitokotoBody ?? notiBody
        notiContent.title = Notification.notiAction
        notiContent.userInfo = [Notification.notiKey:Notification.notiValue]

        let notiTrigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: hour, minute: minute), repeats: true)
        let notiRequest = UNNotificationRequest(identifier: identifier, content: notiContent, trigger: notiTrigger)
        UNUserNotificationCenter.current().add(notiRequest) { (error) in
            if error != nil  {
                Dlog(error?.localizedDescription)
            }
        }
        Notification.fireTime = (hour, minute)
    }
    
    static func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

extension Notification {

    static var hitokotoBody: String? {
        get {
            return UserDefaults.standard.string(forKey: keyForHitokoto)
        }
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: keyForHitokoto)
            } else {
                UserDefaults.standard.removeObject(forKey: keyForHitokoto)
            }
        }
    }

    class func getNewHitokotoBody() {
        let hitokotoAPI = "https://v1.hitokoto.cn?encode=text"
        if let url = URL(string: hitokotoAPI) {
            URLSession.shared.dataTask(with: url) { (data, _, _) in
                if let data = data, let hitokoto = String(data: data, encoding: .utf8) {
                    Dlog("hitokoto \(hitokoto)")
                    self.hitokotoBody = hitokoto
                }
            }.resume()
        }
    }
}
