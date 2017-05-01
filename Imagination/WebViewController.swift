//
//  WebViewController.swift
//  Imagination
//
//  Created by Star on 2017/5/1.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    var web:UIWebView!
    var autoLoginState:Bool{
        get{
            if let state = UserDefaults.standard.object(forKey: "autoLoginState") as? Bool {
                return state
            }else{
                return false
            }
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "autoLoginState")
        }
    }
    var titlestring:String {
        get{
            if autoLoginState {
                return "关闭自动登录"
            }else{
                return "开启自动登录"
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.web = UIWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.view.addSubview(web)
        loadWeb()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: titlestring, style: .plain, target: self, action: #selector(autoLogin))
    }

    
    func loadWeb(){
        var request = URLRequest(url: URL.init(string: "https://wuzhi.me/note/add")!)
        if  autoLoginState {
            request.httpShouldHandleCookies = true
        }else{
            request.httpShouldHandleCookies = false
            if HTTPCookieStorage.shared.cookies(for: request.url!) != nil {
                for cookie in HTTPCookieStorage.shared.cookies(for: request.url!)! {
                    HTTPCookieStorage.shared.deleteCookie(cookie)
                }
            }
        }
        self.web.loadRequest(request)
    }
    func autoLogin(){
        autoLoginState = !autoLoginState
        if autoLoginState {
            let alert = UIAlertController(title: "提示", message: "如未登陆，请勾选密码框下的“记住我”", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好的", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        self.navigationItem.rightBarButtonItem?.title = titlestring
        loadWeb()
    }
}
