//
//  AuthorityViewController.swift
//  Imagination
//
//  Created by Star on 15/11/18.
//  Copyright © 2015年 Star. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthorityViewController: UIViewController,UITextFieldDelegate {
    enum type{
        case Normal,ChangePass
    }
    @IBOutlet weak var password: UITextField!
    var vType = type.Normal
    static var pWord:String?{
        get{
            if let ss = NSUserDefaults.standardUserDefaults().objectForKey("password") as? String {
                return ss
            } else {
                return ""
            }
        }
        set{
            if newValue == nil {
                NSUserDefaults.standardUserDefaults().setObject("", forKey: "password")
            } else {
                NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "password")
            }
        }
    }
    @IBAction func ok() {
        if vType == type.ChangePass {
            AuthorityViewController.pWord = password.text
            password.resignFirstResponder()
            self.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        checkAuthority(password.text)
    }
    
    override func viewDidLoad() {
        self.password.delegate = self
        
        if vType == type.ChangePass {
            password.placeholder = "请输入新密码(留空删除密码)"
            password.secureTextEntry = false
        } else {
            self.useTouchId()
        }
    }
    
    func checkAuthority(passwd:String?){
        if passwd == AuthorityViewController.pWord {
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            let alert = UIAlertController.init(title: "提示", message: "抱歉，证据不足哦！（忘记密码不要怕，重新启动会有指纹识别）", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction.init(title: "好的", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        ok()
        return true
    }
    
    func useTouchId()
    {
        if DataCache.shareInstance.isStart {
            DataCache.shareInstance.isStart = false
            //有touchID的时候有杀不死app bug 尴尬！ 暂且这么处理
            let authenticationContext = LAContext()
            var error: NSError?
            
            let isTouchIdAvailable = authenticationContext.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics,
                error: &error)
            
            if isTouchIdAvailable
            {
                authenticationContext.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "需要验证指纹", reply: {
                    (success, error) -> Void in
                    if success
                    {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            }
        }
        
    }

}


