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
        case normal,changePass
    }
    @IBOutlet weak var password: UITextField!
    var vType = type.normal
    static var pWord:String?{
        get{
            if let ss = UserDefaults.standard.object(forKey: "password") as? String {
                return ss
            } else {
                return ""
            }
        }
        set{
            if newValue == nil {
                UserDefaults.standard.set("", forKey: "password")
            } else {
                UserDefaults.standard.set(newValue, forKey: "password")
            }
        }
    }
    @IBAction func ok() {
        if vType == type.changePass {
            AuthorityViewController.pWord = password.text
            password.resignFirstResponder()
            self.dismiss(animated: true, completion: nil)
            return
        }
        checkAuthority(password.text)
    }
    
    override func viewDidLoad() {
        self.password.delegate = self
        
        if vType == type.changePass {
            password.placeholder = "请输入新密码(留空删除密码)"
            password.isSecureTextEntry = false
        } else {
            self.useTouchId()
        }
    }
    
    func checkAuthority(_ passwd:String?){
        if passwd == AuthorityViewController.pWord {
            self.dismiss(animated: true, completion: nil)
        }else{
            let alert = UIAlertController.init(title: "提示", message: "抱歉，证据不足哦！（忘记密码不要怕，重新启动会有指纹识别）", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction.init(title: "好的", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
            
            let isTouchIdAvailable = authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                error: &error)
            
            if isTouchIdAvailable
            {
                authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "需要验证指纹", reply: {
                    (success, error) -> Void in
                    if success
                    {
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
        
    }

}


