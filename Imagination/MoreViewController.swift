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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
        if (indexPath as NSIndexPath).row == 0 {
            sendBackupToMail(files: dCache.backupToNow())
            updateRecentDetail()
        } else if (indexPath as NSIndexPath).row == 1 {
            sendBackupToMail(files: dCache.backupAll())
            updateRecentDetail()
        } else if (indexPath as NSIndexPath).row == 2 {
            picker = DataPicker.init(frame: CGRect(x: 20, y: (self.view.frame.height-200)/2-50, width: self.view.frame.width-40, height: 200), dele: self)
            self.view.addSubview(picker!)
        } else if (indexPath as NSIndexPath).row == 3 {
            let alert = UIAlertController.init(title: "设置邮箱", message: "请输入邮箱地址", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField(configurationHandler: {
                (email:UITextField) -> Void in
                email.clearButtonMode = UITextFieldViewMode.whileEditing
                if let mail =  self.dCache.email {
                    email.placeholder = mail
                }
                })
            alert.addAction(UIAlertAction.init(title: "确定", style: UIAlertActionStyle.default, handler: {
                (confirm:UIAlertAction) -> Void in
                let emailField = (alert.textFields?.first)! as UITextField
                if self.isValidateEmail(emailField.text!) {
                    self.dCache.email = emailField.text
                    self.updateRecentDetail()
                } else {
                    let alert = UIAlertController.init(title: "提示", message: "邮箱地址格式不对", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction.init(title: "好的", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                }))
            alert.addAction(UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if (indexPath as NSIndexPath).row == 4 {
            if Notification.isReminder {
                Notification.isReminder = false
                Notification.cancelAllNotifications()
                updateReminder()
                return
            }
            
            let pickerBack = UIView.init(frame: CGRect(x: self.view.frame.width/2-150, y: self.view.frame.height/2-170, width: 300, height: 250))
            pickerBack.backgroundColor = UIColor.white
            pickerBack.layer.borderColor = UIColor.black.cgColor
            pickerBack.layer.borderWidth = 0.5
            pickerBack.layer.cornerRadius = 5
            pickerBack.layer.masksToBounds = true
            pickerBack.tag = 111
            let btn = UIButton.init(frame: CGRect(x: pickerBack.frame.width - 50, y: 0, width: 50, height: 34))
            btn.setTitle("完成", for: UIControlState())
            btn.setTitleColor(UIColor.black, for: UIControlState())
            btn.addTarget(self, action: #selector(didSelectTime), for: UIControlEvents.touchUpInside)
            pickerBack.addSubview(btn)
            let cancelBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 50, height: 34))
            cancelBtn.setTitle("取消", for: UIControlState())
            cancelBtn.setTitleColor(UIColor.black, for: UIControlState())
            cancelBtn.addTarget(self, action: #selector(cancelDatePicker), for: UIControlEvents.touchUpInside)
            pickerBack.addSubview(cancelBtn)
            
            datePicker = UIDatePicker.init(frame:CGRect(x: 0, y: 34, width: 300, height: 216))
            datePicker!.datePickerMode = UIDatePickerMode.time
            datePicker?.timeZone = TimeZone.current
            pickerBack.addSubview(datePicker!)
            self.view.addSubview(pickerBack)
        } else if (indexPath as NSIndexPath).row == 5 {
            let storeboad = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let vc = storeboad.instantiateViewController(withIdentifier: "authority") as! AuthorityViewController
            vc.vType = AuthorityViewController.type.changePass
            self.present(vc, animated: true, completion: nil)
        } else if (indexPath as NSIndexPath).row == 6 {
            sendByEmail(filePaths: [], addtional: "建议")
        }
    }
    
    func cancelDatePicker() {
        self.view.viewWithTag(111)?.removeFromSuperview()
    }
    func updateReminder() {
        if Notification.isReminder {
            reminder.textLabel?.text = "关闭每日提醒"
            if let clock = Notification.fireDate {
                reminder.detailTextLabel?.text = Time.clockOfDate(clock)
            }
        } else {
            reminder.textLabel?.text = "开启每日提醒"
            reminder.detailTextLabel?.text = "每天特定时段会提示更新心情"
        }
    }
    func didSelectTime(){
        self.view.viewWithTag(111)?.removeFromSuperview()
        Notification.createNotificaion(datePicker?.date)
        
        updateReminder()
    }
    func dataPickerResult(_ first: String, second: String) {
        sendBackupToMail(files: dCache.createExportDataFile(first, to: second))
    }
    
    func isValidateEmail(_ email:String) -> Bool {
        return true
    }
 
    func sendBackupToMail(files:[String])  {
        if files.count == 0 {
            let alert = UIAlertController.init(title: "提示", message: "无内容可备份", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction.init(title: "好的", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        sendByEmail(filePaths: files)
    }
    
    func sendByEmail(filePaths:[String],addtional:String = "") {
        let vc = MFMailComposeViewController.init()
        vc.mailComposeDelegate = self
        
        
        if filePaths.count == 0 && addtional != "" {
            vc.setToRecipients(["miaoqi0119@163.com"])
            vc.setSubject(addtional)
        }else{
            let txt = filePaths.first!
            vc.setSubject((txt as NSString).lastPathComponent)
            if let mail = self.dCache.email {
                vc.setToRecipients([mail])
            } else {
                vc.setToRecipients(nil)
            }
        }
        for file in filePaths {
            let senddata = try? Data.init(contentsOf: URL(fileURLWithPath: file))
            if let dd = senddata {
                vc.addAttachmentData(dd, mimeType: "", fileName: (file as NSString).lastPathComponent)
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK: - EmailDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self .dismiss(animated: true, completion: nil)
        if result == .sent {
            let alert = UIAlertController.init(title: "提示", message: "发送成功", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction.init(title: "好的", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}
