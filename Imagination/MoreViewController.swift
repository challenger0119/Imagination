//
//  MoreViewController.swift
//  Imagination
//
//  Created by Star on 15/12/9.
//  Copyright © 2015年 Star. All rights reserved.
//

import UIKit
import MessageUI

class MoreViewController: UITableViewController,DataPickerDelegate,MFMailComposeViewControllerDelegate {
    let dCache = DataCache.shareInstance
    var picker:DataPicker?
    var datePicker:UIDatePicker?
    var isReminder:Bool{
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
    
    
    @IBOutlet weak var resent: UITableViewCell!
    @IBOutlet weak var setEmail: UITableViewCell!
    @IBOutlet weak var reminder: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        updateRecentDetail()
        updateReminder()
    }
    
    func updateRecentDetail() {
        dCache.checkFileExist()
        if let fs = dCache.fileState {
            if fs.lastDate != dCache.EMPTY_STRING {
                resent.detailTextLabel?.text = "上次备份于\(fs.lastDate) \n只备份上次备份日期至今天的内容并通过邮件导出"
            }
            if let mail = dCache.email {
                setEmail.detailTextLabel?.text = "当前接收邮箱:\(mail) "
            }
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView .deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0 {
            sendBackupToMail(dCache.backupToNow())
            updateRecentDetail()
        } else if indexPath.row == 1 {
            sendBackupToMail(dCache.backupAll())
            updateRecentDetail()
        } else if indexPath.row == 2 {
            picker = DataPicker.init(frame: CGRectMake(20, (self.view.frame.height-200)/2-50, self.view.frame.width-40, 200), dele: self)
            self.view.addSubview(picker!)
        } else if indexPath.row == 5 {
            sendByEmail("", fileName: "建议")
        } else if indexPath.row == 3 {
            let alert = UIAlertController.init(title: "设置邮箱", message: "请输入邮箱地址", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addTextFieldWithConfigurationHandler({
                (email:UITextField) -> Void in
                email.clearButtonMode = UITextFieldViewMode.WhileEditing
                if let mail =  self.dCache.email {
                    email.placeholder = mail
                }
                })
            alert.addAction(UIAlertAction.init(title: "确定", style: UIAlertActionStyle.Default, handler: {
                (confirm:UIAlertAction) -> Void in
                let emailField = (alert.textFields?.first)! as UITextField
                if self.isValidateEmail(emailField.text!) {
                    self.dCache.email = emailField.text
                    self.updateRecentDetail()
                } else {
                    let alert = UIAlertController.init(title: "提示", message: "邮箱地址格式不对", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction.init(title: "好的", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                }))
            alert.addAction(UIAlertAction.init(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else if indexPath.row == 4 {
            if isReminder {
                isReminder = false
                if let notis = UIApplication.sharedApplication().scheduledLocalNotifications {
                    print(notis)
                    UIApplication.sharedApplication().cancelAllLocalNotifications()
                }
                updateReminder()
                return
            }
            
            let pickerBack = UIView.init(frame: CGRectMake(self.view.frame.width/2-150, 130, 300, 250))
            pickerBack.backgroundColor = UIColor.whiteColor()
            pickerBack.layer.borderColor = UIColor.blueColor().CGColor
            pickerBack.layer.borderWidth = 0.5
            pickerBack.layer.cornerRadius = 5
            pickerBack.layer.masksToBounds = true
            pickerBack.tag = 111
            let btn = UIButton.init(frame: CGRectMake(pickerBack.frame.width - 50, 0, 50, 34))
            btn.setTitle("完成", forState: UIControlState.Normal)
            btn.backgroundColor = UIColor.blueColor()
            btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            btn.addTarget(self, action: "didSelectTime", forControlEvents: UIControlEvents.TouchUpInside)
            pickerBack.addSubview(btn)
            datePicker = UIDatePicker.init(frame:CGRectMake(0, 34, 300, 216))
            datePicker!.datePickerMode = UIDatePickerMode.DateAndTime
            datePicker?.timeZone = NSTimeZone.systemTimeZone()
            pickerBack.addSubview(datePicker!)
            self.view.addSubview(pickerBack)
        }
    }
    
    func updateReminder() {
        if isReminder {
            reminder.textLabel?.text = "关闭每日提醒"
        } else {
            reminder.textLabel?.text = "开启每日提醒"
        }
    }
    func didSelectTime(){
        self.view.viewWithTag(111)?.removeFromSuperview()
        
        print("noti_everyday set!")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "noti_everyday")
        let noti = UILocalNotification.init()
        noti.fireDate = datePicker?.date
        noti.repeatInterval = NSCalendarUnit.Day
        noti.timeZone = NSTimeZone.systemTimeZone()
        noti.soundName = UILocalNotificationDefaultSoundName
        noti.alertBody = "今天心情如何？还没有记录哦！"
        noti.alertAction = "记"
        noti.hasAction = true
        noti.applicationIconBadgeNumber = 1
        let info = ["noti":"imagination"]
        noti.userInfo = info
        UIApplication.sharedApplication().scheduleLocalNotification(noti)
        
        updateReminder()
    }
    func dataPickerResult(first: String, second: String) {
        sendExportToMail(dCache.createExportDataFile(first, to: second))
    }
    
    func isValidateEmail(email:String) -> Bool {
        return true
    }
    
    func sendBackupToMail(name:String) {
        if name == dCache.EMPTY_STRING {
            let alert = UIAlertController.init(title: "提示", message: "无内容可备份", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction.init(title: "好的", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        sendByEmail(FileManager.TxtFileInDocuments(name), fileName: name+".txt")
    }
    func sendExportToMail(name:String) {
        if name == dCache.EMPTY_STRING {
            let alert = UIAlertController.init(title: "提示", message: "无内容可备份", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction.init(title: "好的", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        sendByEmail(FileManager.TxtFileInCaches(name), fileName: name+".txt")
    }
    func sendByEmail(filePath:String,fileName:String) {
        let vc = MFMailComposeViewController.init()
        vc.mailComposeDelegate = self
        vc.setSubject(fileName)
        if let mail = self.dCache.email {
           vc.setToRecipients([mail])
        } else {
        vc.setToRecipients(nil)
        }
        
        
        let senddata = NSData.init(contentsOfFile: filePath)
        if let dd = senddata {
            vc.addAttachmentData(dd, mimeType: "text/plain", fileName: fileName)
        }
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self .dismissViewControllerAnimated(true, completion: nil)
        if result == MFMailComposeResultSent {
            let alert = UIAlertController.init(title: "提示", message: "发送成功", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction.init(title: "好的", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
