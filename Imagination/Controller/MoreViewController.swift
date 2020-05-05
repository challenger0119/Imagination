//
//  MoreViewController.swift
//  Imagination
//
//  Created by Star on 15/12/9.
//  Copyright © 2015年 Star. All rights reserved.
//

import UIKit
import MessageUI

class MoreViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    let dCache = DataCache.share
    let pickerViewTag = 111
    var datePicker: UIDatePicker?

    @IBOutlet weak var resent: UITableViewCell!
    @IBOutlet weak var setEmail: UITableViewCell!
    @IBOutlet weak var reminder: UITableViewCell!
    @IBOutlet weak var cloundSyncCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        updateRecentDetail()
        updateReminder()
        updateCloudSyncCell()
        let backItem = UIBarButtonItem()
        backItem.title = "返回"
        self.navigationItem.backBarButtonItem = backItem
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
    
    // MARK: - Method
    
    @objc func cancelDatePicker() {
        self.view.viewWithTag(pickerViewTag)?.removeFromSuperview()
    }
    
    func updateReminder() {
        if Notification.isReminder {
            reminder.textLabel?.text = "关闭每日提醒"
            if let clock = Notification.fireTime {
                reminder.detailTextLabel?.text = "\(clock.hour):\(clock.minute)"
            }
        } else {
            reminder.textLabel?.text = "开启每日提醒"
            reminder.detailTextLabel?.text = "每天特定时段会提示更新心情"
        }
    }

    func updateCloudSyncCell() {
        if let config = WebDAVConfig.recent() {
            cloundSyncCell.detailTextLabel?.text = config.serverName
        }
    }
    
    @objc func didSelectTime(){
        self.view.viewWithTag(111)?.removeFromSuperview()
        let time = Time.hourAndMinute(ofDate: datePicker!.date)
        Notification.createNotificaion(at: time.0, minute: time.1, identifier: "notification")
        updateReminder()
    }
    
    func isValidateEmail(_ email:String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate.init(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email, substitutionVariables: nil)
    }
 
    func syncBackup(files:[String])  {
        if files.count == 0 {
            let alert = UIAlertController.init(title: "提示", message: "无内容可备份", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction.init(title: "好的", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        WebDavSyncMananger.shared.synchronization()
        let canSyncCloud = !WebDavSyncMananger.shared.syncDirHref.isEmpty

        if !canSyncCloud {
            sendByEmail(filePaths: files)
        } else {
            let alert = UIAlertController(title: I18N.string("提示"), message: I18N.string("数据将同步WebDAV存储：\(WebDAV.shared.config.serverName)，可稍后查看，也可选择立即发送到邮箱"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: I18N.string("发送到邮箱"), style: .default, handler: { (_) in
                self.sendByEmail(filePaths: files)
            }))
            alert.addAction(UIAlertAction(title: I18N.string("不用了"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func sendTestEmail(toAddr mail:String){
        sendEmail(subject: "[Imagination] Hi,我在这！我将把备份文件发到这里", recipients: [mail])
    }
    
    @discardableResult
    func sendEmail(subject:String,recipients:[String]?,attachments:[String] = []) -> Bool {
        guard MFMailComposeViewController.canSendMail() else {
            return false
        }
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = self
        
        vc.setToRecipients(recipients)
        vc.setSubject(subject)
        
        for file in attachments {
            let senddata = try? Data.init(contentsOf: URL(fileURLWithPath: file))
            if let dd = senddata {
                vc.addAttachmentData(dd, mimeType: "", fileName: (file as NSString).lastPathComponent)
            }
        }
        self.present(vc, animated: true, completion: nil)
        return true
    }

    @discardableResult
    func sendByEmail(filePaths:[String],addtional:String = "") -> Bool {
        if filePaths.count == 0 && addtional != "" {
            return sendEmail(subject: addtional, recipients: ["miaoqi0119@163.com"])
        }else{
            let txt = filePaths.first!
            var recip:[String]?
            
            if let mail = self.dCache.email {
                recip = [mail]
            }
            return sendEmail(subject: (txt as NSString).lastPathComponent, recipients: recip, attachments: filePaths)
        }
    }
    
    //MARK: - EmailDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self .dismiss(animated: true, completion: nil)
        if result == .sent {
            let alert = UIAlertController.init(title: "提示", message: "发送成功", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction.init(title: "好的", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension MoreViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            syncBackup(files: dCache.backupToNow())
            updateRecentDetail()
        } else if indexPath.row == 1 {
            syncBackup(files: dCache.backupAll())
            updateRecentDetail()
        } else if indexPath.row == 2 {
            if let pickerVC = self.storyboard?.instantiateViewController(withIdentifier: "DataPickerViewController") as? DataPickerViewController {
                pickerVC.selected = {
                    from, to in
                    self.syncBackup(files: self.dCache.createExportDataFile(from, to: to))
                }
                pickerVC.modalPresentationStyle = .overCurrentContext
                self.tabBarController?.present(pickerVC, animated: false, completion: nil)
            }
        } else if indexPath.row == 3 {
            let alert = UIAlertController.init(title: "设置邮箱", message: "请输入邮箱地址", preferredStyle: UIAlertController.Style.alert)
            alert.addTextField(configurationHandler: {
                (email:UITextField) -> Void in
                email.clearButtonMode = UITextField.ViewMode.whileEditing
                if let mail =  self.dCache.email {
                    email.placeholder = mail
                }
            })
            alert.addAction(UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default, handler: {
                (confirm:UIAlertAction) -> Void in
                let emailField = (alert.textFields?.first)! as UITextField
                if self.isValidateEmail(emailField.text!) {
                    self.dCache.email = emailField.text
                    self.updateRecentDetail()

                    let alert = UIAlertController.init(title: "提示", message: "已设置！为了您的隐私，建议向该邮箱发送测试邮件😀", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "发送", style: .default, handler: {
                        al in
                        self.sendTestEmail(toAddr:self.dCache.email!)
                    }))
                    alert.addAction(UIAlertAction(title: "不用", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController.init(title: "提示", message: "邮箱地址格式不对", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction.init(title: "好的", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }))
            alert.addAction(UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if indexPath.row == 4 {
            if Notification.isReminder {
                Notification.isReminder = false
                Notification.cancelAllNotifications()
                updateReminder()
                return
            }

            let pickerBack = UIView(frame: CGRect(x: 20, y: self.view.frame.height/2-133, width: self.view.frame.width - 40, height: 266))
            pickerBack.backgroundColor = UIColor.white
            pickerBack.layer.cornerRadius = 10
            pickerBack.tag = pickerViewTag
            let btn = UIButton.init(frame: CGRect(x: pickerBack.frame.width - 52, y: 8, width: 40, height: 40))
            btn.setImage(UIImage(named: "check"), for: .normal)
            btn.addTarget(self, action: #selector(didSelectTime), for: UIControl.Event.touchUpInside)
            pickerBack.addSubview(btn)
            let cancelBtn = UIButton(frame: CGRect(x: 12, y: 8, width: 40, height: 40))
            cancelBtn.setImage(UIImage(named: "cancel"), for: .normal)
            cancelBtn.addTarget(self, action: #selector(cancelDatePicker), for: UIControl.Event.touchUpInside)
            pickerBack.addSubview(cancelBtn)

            datePicker = UIDatePicker(frame:CGRect(x: 0, y: 48, width: pickerBack.frame.width, height: 216))
            datePicker!.datePickerMode = UIDatePicker.Mode.time
            datePicker?.timeZone = TimeZone.current
            pickerBack.addSubview(datePicker!)
            self.view.addSubview(pickerBack)

        } else if indexPath.row == 5 {
            let storeboad = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let vc = storeboad.instantiateViewController(withIdentifier: "authority") as! AuthorityViewController
            vc.vType = AuthorityViewController.type.changePass
            self.present(vc, animated: true, completion: nil)
        } else if indexPath.row == 6 {
            sendByEmail(filePaths: [], addtional: "建议")
        } else if indexPath.row == 7 {
            // storyboard
        } else if indexPath.row == 8 {
            navigationController?.pushViewController(WebDAVViewController(), animated: true)
        } else if indexPath.row == 9 {
            // storyboard
        }
    }
}
